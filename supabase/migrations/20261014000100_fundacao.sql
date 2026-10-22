begin;

-- Fundação acadêmica. Aplicar uma única vez em banco sem estas tabelas.
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null check (length(btrim(full_name)) > 0),
  role text not null default 'seller' check (role in ('administrator','manager','seller')),
  active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.clients (
  id uuid primary key default gen_random_uuid(),
  legal_name text,
  trade_name text not null check (length(btrim(trade_name)) > 0),
  document text,
  email text,
  phone text,
  contact_name text,
  postal_code text,
  street text,
  street_number text,
  complement text,
  district text,
  city text not null check (length(btrim(city)) > 0),
  state text check (state is null or state ~ '^[A-Z]{2}$'),
  latitude double precision check (latitude between -90 and 90),
  longitude double precision check (longitude between -180 and 180),
  notes text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  internal_code text check (internal_code is null or length(btrim(internal_code)) > 0),
  website text,
  constraint clients_coordinates_pair check ((latitude is null) = (longitude is null))
);
create unique index clients_internal_code_unique_idx on public.clients (lower(btrim(internal_code))) where internal_code is not null;
create index clients_city_idx on public.clients(city);

create function public.movisitas_set_updated_at() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.updated_at = now();
  return new;
end;
$$;
revoke all on function public.movisitas_set_updated_at() from public, anon, authenticated;
create trigger profiles_updated_at before update on public.profiles
for each row execute function public.movisitas_set_updated_at();
create trigger clients_updated_at before update on public.clients
for each row execute function public.movisitas_set_updated_at();

alter table public.profiles enable row level security;
alter table public.clients enable row level security;
revoke all on table public.profiles, public.clients from public, anon, authenticated;
-- Sem policies ou acesso do aplicativo nesta etapa. Login e carteiras virão depois.
comment on table public.profiles is 'Perfis acadêmicos vinculados ao Supabase Auth; provisionamento pendente.';
comment on table public.clients is 'Clientes do ambiente acadêmico; utilizar somente dados fictícios.';
commit;
