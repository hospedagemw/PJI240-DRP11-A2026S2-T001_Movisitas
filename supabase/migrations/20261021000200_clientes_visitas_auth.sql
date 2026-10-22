begin;
alter table public.clients add column seller_id uuid references public.profiles(id);
create index clients_seller_idx on public.clients(seller_id);
create function public.app_role() returns text language sql stable security definer set search_path='' as $$
 select role from public.profiles where id=auth.uid() and active;
$$;
revoke all on function public.app_role() from public,anon;
grant execute on function public.app_role() to authenticated;
grant select on public.profiles to authenticated;
create policy profiles_read on public.profiles for select to authenticated
 using (public.app_role()='administrator' or (id=auth.uid() and active));
grant select,insert,update on public.clients to authenticated;
create policy clients_read on public.clients for select to authenticated
 using (public.app_role()='administrator' or (public.app_role()='seller' and seller_id=auth.uid()));
create policy clients_insert on public.clients for insert to authenticated
 with check (public.app_role()='administrator' or (public.app_role()='seller' and seller_id=auth.uid()));
create policy clients_update on public.clients for update to authenticated
 using (public.app_role()='administrator' or (public.app_role()='seller' and seller_id=auth.uid()))
 with check (public.app_role()='administrator' or (public.app_role()='seller' and seller_id=auth.uid()));

create table public.app_visits (
 id uuid primary key default gen_random_uuid(),
 client_id uuid not null references public.clients(id),
 seller_id uuid not null references public.profiles(id),
 scheduled_at timestamptz not null,
 status text not null default 'agendada' check(status in ('agendada','em_andamento','concluida','cancelada')),
 started_at timestamptz,
 finished_at timestamptz,
 notes text not null default '',
 created_at timestamptz not null default now(),
 constraint visit_dates check (
 (status='agendada' and started_at is null and finished_at is null) or
 (status='em_andamento' and started_at is not null and finished_at is null) or
 (status='concluida' and started_at is not null and finished_at is not null and finished_at>=started_at) or
 (status='cancelada' and finished_at is null))
);
create index app_visits_client_idx on public.app_visits(client_id);
create index app_visits_seller_idx on public.app_visits(seller_id);
create unique index app_visits_one_running on public.app_visits(seller_id) where status='em_andamento';
alter table public.app_visits enable row level security;
revoke all on public.app_visits from public,anon,authenticated;
grant select on public.app_visits to authenticated;
create policy visits_read on public.app_visits for select to authenticated using
 (public.app_role()='administrator' or (public.app_role()='seller' and seller_id=auth.uid()));

create function public.create_app_visit(p_client uuid,p_when timestamptz,p_start boolean,p_notes text default '')
returns uuid language plpgsql security definer set search_path='' as $$
declare c public.clients; v_id uuid; v_role text;
begin
 v_role:=public.app_role();
 if v_role is null or v_role not in ('administrator','seller') then raise exception 'Acesso negado'; end if;
 select * into c from public.clients where id=p_client;
 if not found or not c.active or (v_role='seller' and c.seller_id is distinct from auth.uid()) then raise exception 'Cliente indisponível'; end if;
 if p_when is null or (not p_start and p_when<now()-interval '1 minute') then raise exception 'Escolha uma data futura'; end if;
 if length(coalesce(p_notes,''))>2000 then raise exception 'Observação excede 2000 caracteres'; end if;
 insert into public.app_visits(client_id,seller_id,scheduled_at,status,started_at,notes)
 values(p_client,auth.uid(),case when p_start then now() else p_when end,
 case when p_start then 'em_andamento' else 'agendada' end,case when p_start then now() end,coalesce(p_notes,'')) returning id into v_id;
 return v_id;
end; $$;
create function public.transition_app_visit(p_id uuid,p_action text,p_notes text default '')
returns void language plpgsql security definer set search_path='' as $$
declare v public.app_visits; v_role text;
begin
 v_role:=public.app_role();
 if v_role is null or v_role not in ('administrator','seller') then raise exception 'Acesso negado'; end if;
 select * into v from public.app_visits where id=p_id for update;
 if not found or (v_role='seller' and v.seller_id<>auth.uid()) then raise exception 'Visita indisponível'; end if;
 if length(coalesce(p_notes,''))>2000 then raise exception 'Observação excede 2000 caracteres'; end if;
 if p_action='iniciar' and v.status='agendada' then
   update public.app_visits set status='em_andamento',started_at=now() where id=p_id;
 elsif p_action='concluir' and v.status='em_andamento' then
   update public.app_visits set status='concluida',finished_at=now(),notes=coalesce(p_notes,'') where id=p_id;
 elsif p_action='cancelar' and v.status='agendada' then
   update public.app_visits set status='cancelada' where id=p_id;
 else raise exception 'Transição de visita inválida'; end if;
end; $$;
revoke all on function public.create_app_visit(uuid,timestamptz,boolean,text),public.transition_app_visit(uuid,text,text) from public,anon;
grant execute on function public.create_app_visit(uuid,timestamptz,boolean,text),public.transition_app_visit(uuid,text,text) to authenticated;
-- Contas e perfis provisionados separadamente pelo administrador do projeto.
-- Nenhuma chave administrativa é entregue ao aplicativo.
commit;
