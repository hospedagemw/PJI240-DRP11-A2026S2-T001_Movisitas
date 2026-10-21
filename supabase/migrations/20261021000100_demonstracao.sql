begin;
-- Área de demonstração sem contas Auth e sem exposição ao aplicativo público.
create schema academic_demo;
revoke all on schema academic_demo from public, anon, authenticated;
create table academic_demo.users (id text primary key, name text not null, role text not null, email text not null check(email like '%@example.com'));
create table academic_demo.clients (id text primary key, code text not null unique, name text not null, city text not null, email text not null check(email like '%@example.com'), seller text not null references academic_demo.users(id));
create table academic_demo.visits (id text primary key, client text not null references academic_demo.clients(id), "user" text not null references academic_demo.users(id), date date not null, time time not null, status text not null check(status in ('Concluída','Agendada','Cancelada')), notes text not null);
create table academic_demo.orders (id text primary key, client text not null references academic_demo.clients(id), date date not null, cents bigint not null check(cents > 0));
alter table academic_demo.users enable row level security;
alter table academic_demo.clients enable row level security;
alter table academic_demo.visits enable row level security;
alter table academic_demo.orders enable row level security;
revoke all on all tables in schema academic_demo from public, anon, authenticated;
comment on schema academic_demo is 'Fixtures fictícias da apresentação acadêmica. Sem autenticação e sem acesso público.';
commit;
