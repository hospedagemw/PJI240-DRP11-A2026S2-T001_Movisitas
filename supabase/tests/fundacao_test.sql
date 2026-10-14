begin;
do $$
begin
  if (select count(*) from pg_class c join pg_namespace n on n.oid=c.relnamespace
      where n.nspname='public' and c.relname in ('profiles','clients') and c.relrowsecurity) <> 2 then
    raise exception 'RLS ausente';
  end if;
  if exists (select 1 from pg_policies where schemaname='public' and tablename in ('profiles','clients')) then
    raise exception 'Policies não previstas nesta fase';
  end if;
  if exists (select 1 from information_schema.role_table_grants
    where table_schema='public' and table_name in ('profiles','clients') and grantee in ('anon','authenticated','PUBLIC')) then
    raise exception 'Privilégios não previstos';
  end if;
  begin
    insert into public.clients(trade_name,city) values (' ','Cidade Exemplo');
    raise exception 'Nome vazio aceito';
  exception when check_violation then null;
  end;
  begin
    insert into public.clients(trade_name,city,latitude,longitude) values ('Teste','Cidade',91,0);
    raise exception 'Latitude inválida aceita';
  exception when check_violation then null;
  end;
  begin
    insert into public.clients(trade_name,city,latitude) values ('Teste','Cidade',10);
    raise exception 'Coordenadas incompletas aceitas';
  exception when check_violation then null;
  end;
  insert into public.clients(trade_name,city,internal_code) values ('Teste temporário','Cidade','TEST-UNIQUE');
  begin
    insert into public.clients(trade_name,city,internal_code) values ('Duplicado','Cidade',' test-unique ');
    raise exception 'Código duplicado aceito';
  exception when unique_violation then null;
  end;
  begin
    insert into public.profiles(id,full_name) values ('20000000-0000-4000-8000-000000000099','Perfil sem Auth');
    raise exception 'Perfil sem Auth aceito';
  exception when foreign_key_violation then null;
  end;
end;
$$;
set local role anon;
do $$
begin
  begin
    perform 1 from public.clients;
    raise exception 'anon leu clientes';
  exception when insufficient_privilege then null;
  end;
end;
$$;
reset role;
set local role authenticated;
do $$
begin
  begin
    perform 1 from public.profiles;
    raise exception 'authenticated leu perfis';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.clients(trade_name,city) values ('Não autorizado','Teste');
    raise exception 'authenticated inseriu cliente';
  exception when insufficient_privilege then null;
  end;
end;
$$;
reset role;
rollback;
select 'PASSOU: integridade e bloqueios verificados; dados de teste revertidos' as resultado;
