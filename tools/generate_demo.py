"""Gera fixtures reproduzíveis; não lê dados da aplicação profissional."""
import json
from pathlib import Path
from html import escape

ROOT = Path(__file__).resolve().parents[1]
users = [dict(id=f'U{i+1:03}', name=n, role=r, email=f'usuario{i+1}@example.com') for i,(n,r) in enumerate([
    ('Ana Exemplo','Administradora'),('Bruno Modelo','Gestor'),('Carla Demonstração','Vendedora'),('Diego Exemplo','Vendedor'),('Elisa Modelo','Vendedora')])]
clients = [dict(id=f'C{i+1:03}', code=f'900{i+1:03}', name=n, city=c, email=f'cliente{i+1}@example.com', seller=users[2+i%3]['id']) for i,(n,c) in enumerate([
    ('Mercado Horizonte','Cidade Exemplo'),('Empório Jardim','Cidade Exemplo'),('Distribuidora Aurora','Vila Modelo'),('Loja Estrela','Vila Modelo'),('Comercial Primavera','Cidade Ilustração'),('Armazém das Nuvens','Cidade Ilustração')])]
visits = [dict(id=f'V{i+1:03}', client=clients[i%6]['id'], user=clients[i%6]['seller'], date=f'2026-10-{19+i//3:02}', time=['09:00','11:00','14:30'][i%3], status=['Concluída','Agendada','Cancelada'][i%3], notes=['Apresentação fictícia do catálogo.','Revisão fictícia de necessidades.','Reagendamento demonstrativo.'][i%3]) for i in range(12)]
orders = [dict(id=f'DEMO-{i+1:04}', client=clients[i%6]['id'], date=f'2026-10-{1+i:02}', cents=125050+i*13725) for i in range(18)]
data = dict(users=users, clients=clients, visits=visits, orders=orders)
(ROOT/'assets').mkdir(exist_ok=True)
(ROOT/'assets/demo.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
money=lambda n: f'{n//100:,}'.replace(',','.')+f',{n%100:02}'
rows=[]
for o in orders:
    c=next(c for c in clients if c['id']==o['client'])
    cells=[o['id'],'/'.join(reversed(o['date'].split('-'))),'DEMONSTRAÇÃO',c['code'],c['name'],money(o['cents'])]
    rows.append('<tr>'+''.join('<td>'+escape(x)+'</td>' for x in cells)+'</tr>')
html='''<!doctype html><html lang="pt-BR"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Vendas fictícias — Movisitas</title>
<style>body{font:16px system-ui;background:#f7f7f8;color:#383838;max-width:1100px;margin:40px auto;padding:20px}h1{border-left:6px solid #ed3237;padding-left:16px}section{overflow:auto;background:white;border-radius:12px;padding:16px}table{border-collapse:collapse;width:100%}th,td{padding:12px;border-bottom:1px solid #ddd;text-align:left}th{background:#383838;color:white}.badge{color:#a51218;font-weight:bold}</style>
<h1>Relatório de vendas / comissão</h1><p class="badge">DEMONSTRAÇÃO ACADÊMICA • TODOS OS DADOS SÃO FICTÍCIOS</p><p>Outubro de 2026 • 18 lançamentos. Arquivo para importação de pedidos, sem cálculo de comissão.</p><section><table><thead><tr><th>Título</th><th>Emissão</th><th>Referência</th><th>Código</th><th>Cliente</th><th>Valor base</th></tr></thead><tbody>'''+''.join(rows)+f'</tbody></table></section><p>Total dos pedidos: R$ {money(sum(o["cents"] for o in orders))}. Não representa comissão.</p></html>\n'
(ROOT/'assets/vendas-ficticias.html').write_text(html,encoding='utf-8')
(ROOT/'web/exemplos').mkdir(parents=True,exist_ok=True)
(ROOT/'web/exemplos/vendas-ficticias.html').write_text(html,encoding='utf-8')

schema='''begin;
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
'''
(ROOT/'supabase/migrations').mkdir(parents=True,exist_ok=True)
(ROOT/'supabase/seeds').mkdir(parents=True,exist_ok=True)
(ROOT/'supabase/migrations/20261021000100_demonstracao.sql').write_text(schema,encoding='utf-8')
quote=lambda v: str(v) if isinstance(v,int) else "'"+v.replace("'","''")+"'"
sql='begin;\n-- Repetível: os IDs fixos evitam duplicação e preservam registros existentes.\n'
for name,records in data.items():
    columns=','.join('"'+k+'"' for k in records[0])
    values=',\n'.join('('+','.join(quote(v) for v in row.values())+')' for row in records)
    sql+=f'insert into academic_demo.{name} ({columns}) values\n{values}\non conflict (id) do nothing;\n'
sql+='commit;\n'
(ROOT/'supabase/seeds/demonstracao.sql').write_text(sql,encoding='utf-8')
print('5 usuários, 6 clientes, 12 visitas, 18 vendas; total R$',money(sum(o['cents'] for o in orders)))
