-- Conferência SOMENTE DE LEITURA. Não executado nesta entrega.
-- Executar com operador autorizado no projeto correto. Não consulta linhas de negócio.
BEGIN TRANSACTION READ ONLY;

SELECT table_name, ordinal_position, column_name, data_type, udt_name,
       is_nullable, column_default, character_maximum_length,
       numeric_precision, numeric_scale, is_identity, identity_generation
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('profiles','sellers','clients','portfolios',
                     'portfolio_clients','visits','visit_locations','sales_orders')
ORDER BY table_name, ordinal_position;

SELECT c.relname AS table_name, con.conname, con.contype,
       pg_get_constraintdef(con.oid) AS definition
FROM pg_constraint con
JOIN pg_class c ON c.oid = con.conrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relname IN ('profiles','sellers','clients','portfolios',
                    'portfolio_clients','visits','visit_locations','sales_orders')
ORDER BY c.relname, con.conname;

SELECT tablename, indexname, indexdef FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('profiles','sellers','clients','portfolios',
                    'portfolio_clients','visits','visit_locations','sales_orders')
ORDER BY tablename, indexname;

SELECT c.relname, c.relrowsecurity, c.relforcerowsecurity
FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relname IN ('profiles','sellers','clients','portfolios',
                    'portfolio_clients','visits','visit_locations','sales_orders');

SELECT tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies WHERE schemaname = 'public'
  AND tablename IN ('profiles','sellers','clients','portfolios',
                    'portfolio_clients','visits','visit_locations','sales_orders')
ORDER BY tablename, policyname;

SELECT table_name, grantee, privilege_type
FROM information_schema.table_privileges
WHERE table_schema = 'public'
  AND table_name IN ('profiles','sellers','clients','portfolios',
                     'portfolio_clients','visits','visit_locations','sales_orders')
ORDER BY table_name, grantee, privilege_type;

SELECT n.nspname AS schema_name, c.relname AS table_name,
       t.tgname, pg_get_triggerdef(t.oid) AS definition
FROM pg_trigger t
JOIN pg_class c ON c.oid = t.tgrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE NOT t.tgisinternal
  AND ((n.nspname = 'public' AND c.relname IN
       ('profiles','sellers','clients','portfolios','portfolio_clients',
        'visits','visit_locations','sales_orders'))
       OR (n.nspname = 'auth' AND c.relname = 'users'))
ORDER BY n.nspname, c.relname, t.tgname;

SELECT p.proname, pg_get_function_identity_arguments(p.oid) AS arguments,
       p.prosecdef AS security_definer, p.proconfig, p.proacl,
       pg_get_functiondef(p.oid) AS definition
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public'
  AND p.proname IN ('set_updated_at','handle_new_user','sync_seller_from_profile',
      'current_app_role','current_seller_id','can_manage','manage_user_profile',
      'assign_new_client_to_current_seller')
ORDER BY p.proname;

COMMIT;
