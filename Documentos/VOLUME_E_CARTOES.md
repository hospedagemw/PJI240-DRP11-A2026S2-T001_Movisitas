# Volume fictício e consulta pelos indicadores

Entrega de 23/10/2026, branch `codex/volume-demonstracao-cartoes`.

Os quatro cartões do painel são clicáveis. Clientes mostra a carteira do responsável selecionado; agendadas, em andamento e concluídas mostram somente os registros contabilizados no período e responsável selecionados. A janela permite consultar os itens e acessar a área de gerenciamento; ao abrir o gerenciamento, a listagem geral do módulo é exibida.

## Carga de apresentação

O script `supabase/seeds/volume_academico.sql` acrescenta 24 clientes e 72 visitas: 48 concluídas, 18 agendadas e 6 canceladas. Datas de referência fixas em setembro/outubro de 2026, com agendamentos até o fim de outubro. São dados fictícios, sem documentos pessoais e sem telefones que possam direcionar contatos a terceiros. E-mails usam example.com.

IDs fixos e `ON CONFLICT DO NOTHING` permitem repetir a carga sem duplicar ou sobrescrever cadastros e atendimentos alterados posteriormente. Nenhuma visita em andamento é inserida, preservando atendimentos iniciados pelo usuário.

A atribuição utiliza os vendedores ativos encontrados: vendedor acadêmico e Ana Exemplo. Na ausência dos futuros perfis Bruno e Carla, as respectivas carteiras ficam com o vendedor acadêmico. Reexecutar a carga não redistribui registros existentes.

A conta Auth de Ana foi criada pelo responsável do projeto, com senha definida diretamente no Supabase. Seu perfil de vendedora foi ativado após confirmação, com as políticas existentes de carteira e visitas próprias. Bruno e Carla ainda dependem de criação com senha pelo responsável; não são contas disponíveis para login nesta entrega.

## Validação

Análise estática aprovada e testes de abertura dos cartões, resultado vazio e filtro de período em 390 e 1280 pixels. Não há alteração nas políticas de acesso ou no cálculo dos indicadores.
