begin;
insert into public.clients (id, trade_name, legal_name, internal_code, city, state, email, notes)
values
 ('10000000-0000-4000-8000-000000000001','Mercado Horizonte','Mercado Horizonte Demonstração','DEMO-001','Cidade Exemplo','SP','horizonte@example.com','Registro fictício para apresentação acadêmica.'),
 ('10000000-0000-4000-8000-000000000002','Empório Jardim','Empório Jardim Demonstração','DEMO-002','Cidade Exemplo','SP','jardim@example.com','Registro fictício para apresentação acadêmica.'),
 ('10000000-0000-4000-8000-000000000003','Distribuidora Aurora','Distribuidora Aurora Demonstração','DEMO-003','Vila Modelo','SP','aurora@example.com','Registro fictício para apresentação acadêmica.')
on conflict (id) do nothing;
commit;
