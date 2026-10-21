# Dados fictícios e importação demonstrativa

Entrega de 21/10/2026, branch `codex/dados-ficticios-importacao`.

## Conjunto da apresentação

| Registros | Quantidade |
| --- | ---: |
| Usuários fictícios (sem login) | 5 |
| Clientes | 6 |
| Visitas | 12 |
| Pedidos de vendas | 18 |

Total das vendas: **R$ 43.508,25**. Não representa comissão; nenhum cálculo de comissão é realizado. Os nomes, cidades, códigos e lançamentos foram criados para a demonstração. E-mails usam somente `example.com`; não há CPF, CNPJ, telefone, senha ou localização de pessoas reais.

## Apresentar no site

1. Navegar em Clientes, Usuários e Visitas para visualizar os exemplos e seus vínculos.
2. Em Importação, a sessão começa com seis pedidos (R$ 9.561,75).
3. Baixar o HTML fictício e selecioná-lo no botão Selecionar HTML; alternativamente usar Importar exemplo incluído.
4. A primeira carga adiciona 12 pedidos e ignora os seis existentes. Uma nova carga adiciona zero e identifica os 18 existentes.
5. Recarregar a página restaura os seis pedidos iniciais, permitindo repetir o vídeo.

A importação da interface ocorre em memória no navegador, sem enviar arquivo ou alterar o Supabase. O banco guarda uma cópia independente dos 18 exemplos. A sincronização autenticada é uma próxima etapa. Os cinco usuários são personagens de demonstração, não contas do Supabase Auth, e não possuem senha nem permissões de login. Os cadastros nesta entrega são consultas de exemplos, sem edição.

## Arquivo de vendas

[HTML fictício](../web/exemplos/vendas-ficticias.html). Depois de baixar pelo GitHub, abra o arquivo localmente; o GitHub mostra o código.

Colunas, na ordem compatível com o parser da aplicação de origem: título, emissão (`dd/mm/aaaa`), referência, código numérico do cliente, nome do cliente e valor base no formato brasileiro. IDs `DEMO-0001` a `DEMO-0018`; códigos dos clientes `900001` a `900006`.

O parser original foi incorporado de `lib/data/order_html_parser.dart` e validado com este HTML. Isso valida a leitura; importar em outra instalação exige os mesmos códigos de cliente e as regras de acesso daquela instalação. Não se deve importar estes exemplos no ambiente profissional.

Para esta tela pública, a validação aceita apenas os 18 exemplos fornecidos, sem alterações e com até 200 KB. Arquivos incompletos, códigos, nomes, datas ou valores diferentes são rejeitados antes de alterar a lista. O HTML é lido como dados, nunca executado na página.

## Supabase acadêmico

O schema `academic_demo` contém `users`, `clients`, `visits` e `orders`, com chaves estrangeiras e valores monetários em centavos inteiros. Não modifica `public.profiles`, `public.clients` ou `auth.users`. As tabelas da fundação continuam destinadas à futura integração autenticada.

- Estrutura: `supabase/migrations/20261021000100_demonstracao.sql` (aplicar uma única vez).
- Carga repetível: `supabase/seeds/demonstracao.sql` (`ON CONFLICT (id) DO NOTHING`; preserva registros existentes).
- Conferência: `supabase/verify_demo.sql`.

Aplicado pelo SQL Editor em 21/10/2026 após retomar o projeto pausado. A carga foi executada novamente para verificar que não duplica. Resultado: 5 usuários, 6 clientes, 12 visitas, 18 pedidos, 4.350.825 centavos, quatro tabelas com RLS e sem acesso de schema para `anon` ou `authenticated`. Nenhuma policy ou acesso público foi criado. Aplicação manual não registra o histórico da CLI: reconciliar antes de usar `supabase db push`.

## Reprodução e verificações

`python tools/generate_demo.py` gera JSON, HTML e SQL a partir das mesmas definições, sem ler dados externos. Os artefatos gerados são versionados para revisão. Mudanças no conjunto exigem atualização das expectativas dos testes.

Validações: análise Flutter sem apontamentos; cinco testes aprovados (leitura e total do HTML, rejeição atômica, duplicação, vínculos e navegação em 390/1280 pixels); compilação web concluída. Inspeção em navegador: seleção real do HTML adicionou 12 registros e a repetição adicionou zero. O build mantém o aviso de CupertinoIcons já existente; a interface usa MaterialIcons.
