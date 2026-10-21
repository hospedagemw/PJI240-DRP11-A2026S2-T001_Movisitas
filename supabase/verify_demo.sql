-- Somente leitura: confirma carga, integridade e isolamento.
select
 (select count(*) from academic_demo.users) as usuarios,
 (select count(*) from academic_demo.clients) as clientes,
 (select count(*) from academic_demo.visits) as visitas,
 (select count(*) from academic_demo.orders) as pedidos,
 (select sum(cents) from academic_demo.orders) as total_centavos,
 (select count(*) from pg_class c join pg_namespace n on n.oid=c.relnamespace
  where n.nspname='academic_demo' and c.relkind='r' and c.relrowsecurity) as tabelas_rls,
 has_schema_privilege('anon','academic_demo','USAGE') as anon_acesso,
 has_schema_privilege('authenticated','academic_demo','USAGE') as authenticated_acesso,
 (select count(*) from academic_demo.visits v left join academic_demo.clients c on c.id=v.client
  left join academic_demo.users u on u.id=v."user" where c.id is null or u.id is null) as visitas_orfas,
 (select count(*) from academic_demo.orders o left join academic_demo.clients c on c.id=o.client where c.id is null) as pedidos_orfaos;
