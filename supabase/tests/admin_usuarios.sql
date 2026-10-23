begin;
insert into auth.users(id) values ('21000000-0000-4000-8000-000000000001'),('21000000-0000-4000-8000-000000000002');
insert into public.profiles(id,full_name,role,active) values
('21000000-0000-4000-8000-000000000001','Admin teste','administrator',true),
('21000000-0000-4000-8000-000000000002','Vendedor teste','seller',true);
set local role authenticated;
select set_config('request.jwt.claim.sub','21000000-0000-4000-8000-000000000002',true);
do $$ begin
 begin
  perform public.admin_update_profile(auth.uid(),'Invasor','administrator',true);
  raise exception 'Falha: vendedor alterou perfil';
 exception when raise_exception then if sqlerrm<>'Somente o administrador pode gerenciar usuários' then raise; end if; end;
end $$;
select set_config('request.jwt.claim.sub','21000000-0000-4000-8000-000000000001',true);
do $$ begin
 begin
  perform public.admin_update_profile(auth.uid(),'Admin teste','seller',true);
  raise exception 'Falha: administrador removeu próprio acesso';
 exception when raise_exception then if sqlerrm<>'Você não pode remover seu próprio acesso administrativo' then raise; end if; end;
 perform public.admin_update_profile('21000000-0000-4000-8000-000000000002','Nome editado','seller',false);
 if not exists(select 1 from public.profiles where id='21000000-0000-4000-8000-000000000002' and full_name='Nome editado' and not active) then raise exception 'Falha de edição'; end if;
end $$;
select set_config('request.jwt.claim.sub','21000000-0000-4000-8000-000000000002',true);
do $$ begin
 if public.app_role() is not null then raise exception 'Falha: inativo com acesso'; end if;
 if exists(select 1 from public.clients) then raise exception 'Falha: inativo acessou clientes'; end if;
end $$;
select set_config('request.jwt.claim.sub','21000000-0000-4000-8000-000000000001',true);
select public.admin_update_profile('21000000-0000-4000-8000-000000000002','Nome editado','seller',true);
reset role;
set local role anon;
do $$ begin
 begin perform public.admin_update_profile('21000000-0000-4000-8000-000000000002','Anonimo','seller',true); raise exception 'Falha: anônimo alterou perfil'; exception when insufficient_privilege then null; end;
end $$;
reset role;
select 'PASSOU: administrador edita e reativa; vendedor e anônimo bloqueados; próprio acesso protegido; inativo sem dados' as resultado;
rollback;
