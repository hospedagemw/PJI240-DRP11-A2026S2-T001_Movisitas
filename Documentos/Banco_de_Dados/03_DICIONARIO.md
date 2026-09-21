# Dicionário de dados

> Análise documental em 21/09/2026. Esquema reconstruído dos 13 scripts locais da origem; não é uma inspeção do banco remoto nem comprova que as migrations foram aplicadas. Nenhum SQL foi executado no Supabase.


PK = chave primária; FK = chave estrangeira; UNIQUE = unicidade. “Nulo” refere-se à coluna; ausência de NOT NULL não significa ausência de regras de negócio. Os tipos e a definição SQL são reproduzidos dos scripts, com as três colunas acrescentadas posteriormente.

## `public.profiles`

| Campo | Tipo | Nulo? | Definição/restrições da coluna | Significado |
| --- | --- | --- | --- | --- |
| `id` | `uuid` | Não | `primary key references auth.users(id) on delete cascade` | Identificador do registro. |
| `full_name` | `text` | Não | `not null` | Nome de apresentação do usuário. |
| `role` | `text` | Não | `not null default 'seller' check (role in ('administrator', 'manager', 'seller'))` | Papel de acesso da aplicação. |
| `active` | `boolean` | Não | `not null default true` | Indicador de atividade; não implica exclusão. |
| `created_at` | `timestamptz` | Não | `not null default now()` | Instante de criação. |
| `updated_at` | `timestamptz` | Não | `not null default now()` | Instante da última atualização via trigger. |
| `email` | `text` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | E-mail de contato; no perfil é cópia do Auth. |

Fontes: `202608110001_initial_schema.sql`, `202608110004_user_management.sql`.

## `public.sellers`

| Campo | Tipo | Nulo? | Definição/restrições da coluna | Significado |
| --- | --- | --- | --- | --- |
| `id` | `uuid` | Não | `primary key default gen_random_uuid()` | Identificador do registro. |
| `profile_id` | `uuid` | Não | `not null unique references public.profiles(id) on delete restrict` | Perfil associado ao vendedor. |
| `manager_profile_id` | `uuid` | Sim | `references public.profiles(id) on delete set null` | Perfil supervisor opcional. |
| `phone` | `text` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Telefone de contato. |
| `region` | `text` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Região de atuação, texto livre. |
| `active` | `boolean` | Não | `not null default true` | Indicador de atividade; não implica exclusão. |
| `created_at` | `timestamptz` | Não | `not null default now()` | Instante de criação. |

Fontes: `202608110001_initial_schema.sql`.

## `public.clients`

| Campo | Tipo | Nulo? | Definição/restrições da coluna | Significado |
| --- | --- | --- | --- | --- |
| `id` | `uuid` | Não | `primary key default gen_random_uuid()` | Identificador do registro. |
| `legal_name` | `text` | Não | `not null` | Razão social/nome cadastral. |
| `trade_name` | `text` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Nome fantasia. |
| `document` | `text` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Documento do cliente, sem unicidade declarada. |
| `email` | `text` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | E-mail de contato; no perfil é cópia do Auth. |
| `phone` | `text` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Telefone de contato. |
| `contact_name` | `text` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Nome do contato principal. |
| `postal_code` | `text` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | CEP em texto. |
| `street` | `text` | Não | `not null` | Logradouro. |
| `street_number` | `text` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Número do endereço. |
| `complement` | `text` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Complemento do endereço. |
| `district` | `text` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Bairro. |
| `city` | `text` | Não | `not null` | Município. |
| `state` | `char(2)` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | UF, até dois caracteres; sem lista de UFs. |
| `latitude` | `double precision` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Latitude em graus. |
| `longitude` | `double precision` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Longitude em graus. |
| `notes` | `text` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Observações em texto livre. |
| `active` | `boolean` | Não | `not null default true` | Indicador de atividade; não implica exclusão. |
| `created_at` | `timestamptz` | Não | `not null default now()` | Instante de criação. |
| `updated_at` | `timestamptz` | Não | `not null default now()` | Instante da última atualização via trigger. |
| `internal_code` | `text` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Código do cliente no ERP. |
| `website` | `text` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Site institucional. |

Regra adicional: índice UNIQUE parcial em `lower(trim(internal_code))`, excluindo nulos e textos vazios. O documento do cliente não tem validação de formato ou unicidade no SQL.

Fontes: `202608110001_initial_schema.sql`, `202608130008_client_internal_code.sql`.

## `public.portfolios`

| Campo | Tipo | Nulo? | Definição/restrições da coluna | Significado |
| --- | --- | --- | --- | --- |
| `id` | `uuid` | Não | `primary key default gen_random_uuid()` | Identificador do registro. |
| `name` | `text` | Não | `not null` | Nome da carteira. |
| `seller_id` | `uuid` | Não | `not null references public.sellers(id) on delete restrict` | Vendedor responsável. |
| `active` | `boolean` | Não | `not null default true` | Indicador de atividade; não implica exclusão. |
| `created_at` | `timestamptz` | Não | `not null default now()` | Instante de criação. |

Fontes: `202608110001_initial_schema.sql`.

## `public.portfolio_clients`

| Campo | Tipo | Nulo? | Definição/restrições da coluna | Significado |
| --- | --- | --- | --- | --- |
| `portfolio_id` | `uuid` | Não | `not null references public.portfolios(id) on delete cascade` | Carteira associada. |
| `client_id` | `uuid` | Não | `not null references public.clients(id) on delete cascade` | Cliente associado. |
| `assigned_at` | `timestamptz` | Não | `not null default now()` | Instante de atribuição à carteira. |

Restrição de tabela: `PRIMARY KEY (portfolio_id, client_id)`.

Fontes: `202608110001_initial_schema.sql`.

## `public.visits`

| Campo | Tipo | Nulo? | Definição/restrições da coluna | Significado |
| --- | --- | --- | --- | --- |
| `id` | `uuid` | Não | `primary key default gen_random_uuid()` | Identificador do registro. |
| `client_id` | `uuid` | Não | `not null references public.clients(id) on delete restrict` | Cliente associado. |
| `seller_id` | `uuid` | Não | `not null references public.sellers(id) on delete restrict` | Vendedor responsável. |
| `status` | `text` | Não | `not null default 'scheduled' check (status in ('scheduled', 'started', 'confirmed', 'cancelled'))` | Estado da visita. |
| `scheduled_at` | `timestamptz` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Instante agendado. |
| `started_at` | `timestamptz` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Instante de início. |
| `confirmed_at` | `timestamptz` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Instante de confirmação/conclusão. |
| `result` | `text` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Resultado livre do atendimento. |
| `notes` | `text` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Observações em texto livre. |
| `next_visit_at` | `timestamptz` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Previsão de próxima visita; não cria outra visita. |
| `created_at` | `timestamptz` | Não | `not null default now()` | Instante de criação. |
| `updated_at` | `timestamptz` | Não | `not null default now()` | Instante da última atualização via trigger. |

Fontes: `202608110001_initial_schema.sql`.

## `public.visit_locations`

| Campo | Tipo | Nulo? | Definição/restrições da coluna | Significado |
| --- | --- | --- | --- | --- |
| `id` | `bigint` | Não | `generated always as identity primary key` | Identificador do registro. |
| `visit_id` | `uuid` | Não | `not null references public.visits(id) on delete cascade` | Visita que originou o evento. |
| `event_type` | `text` | Não | `not null check (event_type in ('start', 'confirmation'))` | Tipo do evento de localização. |
| `latitude` | `double precision` | Não | `not null check (latitude between -90 and 90)` | Latitude em graus. |
| `longitude` | `double precision` | Não | `not null check (longitude between -180 and 180)` | Longitude em graus. |
| `accuracy_meters` | `double precision` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Precisão informada pelo dispositivo em metros. |
| `distance_to_client_meters` | `double precision` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Distância informada em relação ao cliente, em metros. |
| `captured_at` | `timestamptz` | Não | `not null default now()` | Instante da captura. |

Fontes: `202608110001_initial_schema.sql`.

## `public.sales_orders`

| Campo | Tipo | Nulo? | Definição/restrições da coluna | Significado |
| --- | --- | --- | --- | --- |
| `id` | `uuid` | Não | `primary key default gen_random_uuid()` | Identificador do registro. |
| `client_id` | `uuid` | Não | `not null references public.clients(id) on delete restrict` | Cliente associado. |
| `internal_code` | `text` | Não | `not null` | Código do cliente no ERP. |
| `customer_name` | `text` | Não | `not null` | Nome preservado na importação do ERP. |
| `issued_at` | `date` | Não | `not null` | Data de emissão do pedido. |
| `base_value` | `numeric(14, 2)` | Não | `not null check (base_value >= 0)` | Valor-base do relatório ERP; não equivale necessariamente ao total da venda. |
| `source_title` | `text` | Não | `not null` | Identificação/título do registro de origem. |
| `source_file` | `text` | Sim | `Sem DEFAULT ou restrição de coluna explícita` | Nome/referência do arquivo de origem. |
| `import_key` | `text` | Não | `not null` | Chave determinística para deduplicação. |
| `imported_by` | `uuid` | Não | `not null default auth.uid() references public.profiles(id)` | Perfil responsável pela importação. |
| `created_at` | `timestamptz` | Não | `not null default now()` | Instante de criação. |

Restrição de tabela: `UNIQUE (import_key)`. `imported_by` usa `auth.uid()` por padrão, mas a FK e o NOT NULL continuam obrigatórios.

Fontes: `202608140001_sales_orders.sql`.

## Convenções e limites

- UUIDs são gerados por `gen_random_uuid()`, exceto `profiles.id`, que recebe a identidade Auth. Localizações usam identidade bigint.
- `timestamptz` representa instantes; a interface deve exibir o fuso escolhido. `issued_at` é uma data sem hora.
- NOT NULL em campos textuais não rejeita uma string vazia.
- Não foram identificadas tabelas próprias de contatos múltiplos, endereços múltiplos, anexos ou auditoria.
- `auth.users` é gerenciada pelo Supabase e não é integralmente reproduzida neste dicionário.
