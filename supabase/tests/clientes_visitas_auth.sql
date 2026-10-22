begin;
-- Identidades temporárias apenas para verificar RLS; toda alteração é revertida.
insert into auth.users(id) values ('20000000-0000-4000-8000-000000000001'),('20000000-0000-4000-8000-000000000002'),('20000000-0000-4000-8000-000000000003');
insert into public.profiles(id,full_name,role,active) values
 ('20000000-0000-4000-8000-000000000001','Administrador teste','administrator',true),
 ('20000000-0000-4000-8000-000000000002','Vendedor teste','seller',true),
 ('20000000-0000-4000-8000-000000000003','Vendedor outro','seller',true);
insert into public.clients(id,trade_name,city,seller_id) values
 ('30000000-0000-4000-8000-000000000001','Cliente teste A','Cidade Exemplo','20000000-0000-4000-8000-000000000002'),
 ('30000000-0000-4000-8000-000000000002','Cliente teste B','Cidade Exemplo','20000000-0000-4000-8000-000000000003');
set local role authenticated;
select set_config('request.jwt.claim.sub','20000000-0000-4000-8000-000000000002',true);
do $$ declare n int; v uuid; begin
 if public.app_role()<>'seller' then raise exception 'Perfil incorreto'; end if;
 select count(*) into n from public.clients where id in ('30000000-0000-4000-8000-000000000001','30000000-0000-4000-8000-000000000002');
 if n<>1 then raise exception 'Falha isolamento de clientes'; end if;
 update public.clients set city='Outra cidade fictícia' where id='30000000-0000-4000-8000-000000000002';
 get diagnostics n=row_count;
 if n<>0 then raise exception 'Vendedor alterou outro cliente'; end if;
 begin
  update public.profiles set role='administrator' where id=auth.uid();
  raise exception 'Escalada de perfil permitida';
 exception when insufficient_privilege then null; end;
 begin
  perform public.create_app_visit('30000000-0000-4000-8000-000000000002',now(),true,'');
  raise exception 'Visita de outro cliente permitida';
 exception when raise_exception then if sqlerrm<>'Cliente indisponível' then raise; end if; end;
 v:=public.create_app_visit('30000000-0000-4000-8000-000000000001',now()+interval '1 day',false,'Teste fictício');
 perform public.transition_app_visit(v,'iniciar','');
 perform public.transition_app_visit(v,'concluir','Atendimento de teste');
 if not exists(select 1 from public.app_visits where id=v and status='concluida' and finished_at is not null) then raise exception 'Conclusão não persistida'; end if;
 begin
  perform public.transition_app_visit(v,'iniciar','');
  raise exception 'Transição inválida permitida';
 exception when raise_exception then if sqlerrm<>'Transição de visita inválida' then raise; end if; end;
end $$;
select set_config('request.jwt.claim.sub','20000000-0000-4000-8000-000000000001',true);
do $$ begin
 if (select count(*) from public.clients where id in ('30000000-0000-4000-8000-000000000001','30000000-0000-4000-8000-000000000002'))<>2 then raise exception 'Administrador sem visão completa'; end if;
end $$;
reset role;
update public.profiles set active=false where id='20000000-0000-4000-8000-000000000002';
set local role authenticated;
select set_config('request.jwt.claim.sub','20000000-0000-4000-8000-000000000002',true);
do $$ begin
 if exists(select 1 from public.clients) then raise exception 'Conta inativa acessou clientes'; end if;
end $$;
reset role;
set local role anon;
do $$ begin
 begin perform 1 from public.clients limit 1; raise exception 'Anônimo acessou clientes'; exception when insufficient_privilege then null; end;
end $$;
reset role;
select 'PASSOU: isolamento, edição, visita, transições, perfil inativo e acesso anônimo' as resultado;
rollback;
