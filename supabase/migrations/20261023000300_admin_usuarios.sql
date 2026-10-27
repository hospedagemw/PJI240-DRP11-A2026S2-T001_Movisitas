begin;
create function public.admin_update_profile(p_id uuid,p_name text,p_role text,p_active boolean)
returns void language plpgsql security definer set search_path='' as $$
begin
 perform pg_advisory_xact_lock(724001);
 if public.app_role() is distinct from 'administrator' then raise exception 'Somente o administrador pode gerenciar usuários'; end if;
 if p_name is null or length(btrim(p_name)) not between 2 and 120 or p_role is null or p_role not in ('administrator','seller','manager') or p_active is null then raise exception 'Dados de usuário inválidos'; end if;
 if p_id=auth.uid() and (p_role<>'administrator' or not p_active) then raise exception 'Você não pode remover seu próprio acesso administrativo'; end if;
 if not p_active and exists(select 1 from public.app_visits where seller_id=p_id and status='em_andamento') then raise exception 'Conclua a visita em andamento antes de desativar este usuário'; end if;
 update public.profiles set full_name=btrim(p_name),role=p_role,active=p_active where id=p_id;
 if not found then raise exception 'Usuário não encontrado'; end if;
end; $$;
revoke all on function public.admin_update_profile(uuid,text,text,boolean) from public,anon;
grant execute on function public.admin_update_profile(uuid,text,text,boolean) to authenticated;
commit;
