-- Carga fictícia de 23/10/2026. Reexecutável sem sobrescrever registros.
-- Não cria contas Auth, senhas ou permissões.
begin;
do $$
declare
 base_seller uuid; owner_id uuid; client_id uuid; visit_id uuid;
 names text[] := array['Mercado Sol Nascente','Empório das Flores','Loja Estrela Azul','Distribuidora Vale Verde','Bazar Vila Serena','Armazém Nova Aurora','Mercado Boa Praça','Empório Casa Clara','Loja Jardim do Lago','Distribuidora Ponte Nova','Bazar Horizonte Sul','Armazém Monte Belo','Mercado Estação Norte','Empório Terra Nova','Loja Brisa do Campo','Distribuidora Bela Vista','Bazar Recanto Feliz','Armazém Portal Azul','Mercado Quinta do Sol','Empório Caminho Verde','Loja Praça Serena','Distribuidora Lago Dourado','Bazar Alameda Nova','Armazém Vila das Cores'];
 cities text[] := array['Cidade Exemplo','Vila Modelo','Jardim Fictício','Vale Demonstrativo'];
 emails text[] := array['vendedor@academico.com.br','ana.vendas@example.com','bruno.vendas@example.com','carla.vendas@example.com'];
 contacts text[] := array['Alex Exemplo','Bia Modelo','Caio Exemplo','Dora Modelo','Eva Exemplo','Fábio Modelo'];
 n int; j int; seq int; state_value text; scheduled timestamptz;
begin
 select p.id into base_seller from public.profiles p join auth.users u on u.id=p.id where u.email=emails[1] and p.active and p.role='seller';
 if base_seller is null then raise exception 'Vendedor acadêmico ativo não encontrado'; end if;
 for n in 1..24 loop
   client_id := ('41000000-0000-4000-8000-' || lpad(n::text,12,'0'))::uuid;
   select p.id into owner_id from public.profiles p join auth.users u on u.id=p.id where u.email=emails[1+((n-1)%4)] and p.active and p.role='seller';
   owner_id := coalesce(owner_id,base_seller);
   insert into public.clients(id,trade_name,legal_name,internal_code,city,state,contact_name,email,street,street_number,notes,seller_id)
   values(client_id,names[n],names[n]||' — Empresa Fictícia','VOLUME-'||lpad(n::text,3,'0'),cities[1+((n-1)%4)],'SP',contacts[1+((n-1)%6)],'cliente'||n||'@example.com','Rua Demonstrativa',n::text,'Cadastro fictício para apresentação acadêmica. Não corresponde a empresa real.',owner_id)
   on conflict(id) do nothing;
   -- Preserva o responsável de registros já existentes numa reexecução.
   select seller_id into owner_id from public.clients where id=client_id;
   for j in 1..3 loop
     seq := (n-1)*3+j;
     visit_id := ('42000000-0000-4000-8000-'||lpad(seq::text,12,'0'))::uuid;
     state_value := case when j<3 then 'concluida' when n%4=0 then 'cancelada' else 'agendada' end;
     scheduled := case when j=1 then timestamptz '2026-10-23 10:00:00-03' - make_interval(days=>25+n%12)
       when j=2 then timestamptz '2026-10-23 10:00:00-03' - make_interval(days=>1+n%18)
       else timestamptz '2026-10-23 10:00:00-03' + make_interval(days=>1+n%8,hours=>n%5) end;
     insert into public.app_visits(id,client_id,seller_id,scheduled_at,status,started_at,finished_at,notes)
     values(visit_id,client_id,owner_id,scheduled,state_value,
       case when state_value='concluida' then scheduled end,
       case when state_value='concluida' then scheduled+interval '35 minutes' end,
       case state_value when 'concluida' then 'Demonstração: apresentação de catálogo e acompanhamento do cliente fictício.'
         when 'cancelada' then 'Demonstração: agendamento cancelado por indisponibilidade fictícia.'
         else 'Demonstração: visita planejada para conhecer as necessidades do cliente fictício.' end)
     on conflict(id) do nothing;
   end loop;
 end loop;
end $$;
commit;
select (select count(*) from public.clients where id::text like '41000000-%') as clientes_da_carga,
 (select count(*) from public.app_visits where id::text like '42000000-%') as visitas_da_carga;
