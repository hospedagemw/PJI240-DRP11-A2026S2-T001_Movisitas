# Rastreabilidade, migração e validação

> Análise documental em 21/09/2026. Esquema reconstruído dos 13 scripts locais da origem; não é uma inspeção do banco remoto nem comprova que as migrations foram aplicadas. Nenhum SQL foi executado no Supabase.

## Inventário das fontes SQL

Ordem lexical observada, não comprovação da ordem de execução no banco remoto.

| Ordem | Arquivo da origem | Contribuição |
| --- | --- | --- |
| 1 | `202608110001_initial_schema.sql` | Esquema inicial, índices, triggers, auxiliares, RLS e grants |
| 2 | `202608110002_seller_profiles.sql` | Sincronização de perfil e vendedor |
| 3 | `202608110003_portfolio_reassignment.sql` | Permissão DELETE na associação de carteira |
| 4 | `202608110004_user_management.sql` | E-mail no perfil e revisão do trigger Auth |
| 5 | `202608110005_bootstrap_administrator.sql` | Bootstrap administrativo específico da origem |
| 6 | `202608110006_manage_user_profile.sql` | RPC de gestão do perfil |
| 7 | `202608110007_visit_agenda.sql` | Índices parciais da agenda |
| 8 | `202608130001_sellers_update_own_clients.sql` | Atualização de clientes da carteira pelo vendedor |
| 9 | `202608130008_client_internal_code.sql` | Código ERP, site e índice único parcial |
| 10 | `202608140001_sales_orders.sql` | Pedidos ERP e políticas iniciais |
| 11 | `202608240001_portfolio_admin_only.sql` | Escrita direta de carteiras restrita ao administrador |
| 12 | `202608260001_sales_orders_portfolio_read.sql` | Leitura de pedidos por carteira |
| 13 | `202608260002_sellers_create_own_clients.sql` | Cadastro de cliente pelo vendedor e atribuição automática |

Os arquivos estão em `supabase/migrations/` na origem. O [manifesto](fontes.json) registra SHA-256 e referência de cada fonte, incluindo o repositório Flutter e as três Edge Functions. Não foram copiados SQLs de implantação para a raiz executável do Movisitas.

## Requisitos e entidades

| Requisito | Entidades | Evidência futura |
| --- | --- | --- |
| Identificar usuário e perfil | Auth, profiles, sellers | Login e autorização por perfil |
| Centralizar clientes e carteira | clients, portfolios, portfolio_clients | Cadastro e visibilidade por vendedor |
| Organizar agenda e atendimento | visits | Agendamento, início, conclusão e cancelamento |
| Registrar localização | visit_locations | Captura permitida, recusada e indisponível |
| Consultar histórico | visits, clients, sellers | Filtro por período e responsável |
| Relacionar pedidos (extensão) | sales_orders | Importação e deduplicação |

## Plano de testes do banco

Todos os testes desta tabela estão **planejados, não executados**. As expectativas marcadas como proposta exigem correção/decisão antes de serem critérios finais. Utilizar ambiente de teste com duas contas de vendedor, um gestor, um administrador e clientes fictícios de carteiras distintas.

| ID | Cenário | Resultado esperado |
| --- | --- | --- |
| T01 | Inserir visita com cliente inexistente | FK rejeita |
| T02 | Repetir o mesmo par carteira-cliente | PK composta rejeita |
| T03 | Repetir cliente em outra carteira | Esquema atual aceita; validar decisão do negócio |
| T04 | Repetir código ERP variando caixa/espaços | Índice único rejeita para código não vazio |
| T05 | Repetir `import_key` | UNIQUE rejeita |
| T06 | Latitude de localização fora de -90 a 90 | CHECK rejeita |
| T07 | Valor-base negativo | CHECK rejeita |
| T08 | Vendedor consultar cliente de outra carteira | RLS não retorna a linha |
| T09 | Vendedor inserir visita com cliente alheio | Proposta: rejeitar; falta validação de vínculo nos scripts |
| T10 | Gestor alterar associação de carteira via API | Políticas atuais rejeitam |
| T11 | Vendedor cadastrar cliente | Trigger associa a carteira ativa ou cria uma |
| T12 | Perfil desativado usar sessão ainda válida | Proposta: negar operação; revisar atividade em auxiliares |
| T13 | RPC de gestão chamada por identidade sem papel ativo | Proposta: rejeitar explicitamente NULL |
| T14 | Cadastro público enviar papel administrator em metadados | Proposta: não conceder privilégio; revisar configuração e trigger |
| T15 | Excluir cliente com visita existente | FK RESTRICT rejeita em conexão autorizada |
| T16 | Cadastro concorrente de clientes sem carteira inicial | Validar número de carteiras e atomicidade |
| T17 | Falha entre atualização de perfil e atualização Auth | Identificar estado parcial e procedimento de recuperação |
| T18 | Cancelar visita agendada | Registro permanece com estado cancelled |
| T19 | Redefinir senha pela Edge Function | Proposta: nova senha funciona; corrigir `isNotEmpty` antes |

Testes de FK/CHECK podem usar conexão administrativa de teste. Testes de RLS precisam de sessões dos perfis indicados, sem credencial que contorne RLS. Resultado vazio em SELECT pode ser a negação esperada, sem erro explícito.

## Conferência remota somente de leitura

O arquivo [consultar_metadados.sql](consultar_metadados.sql) consulta colunas, constraints, índices, políticas, grants, funções e gatilhos das tabelas da aplicação, sem ler cadastros de clientes ou executar migrations. Deve ser usado por operador autorizado no projeto correto. Não foi executado nesta análise.

Comparar o resultado com estes documentos e conferir separadamente: histórico de migrations, configurações de cadastro público, versões das Edge Functions, segredos do servidor e opções de backup. Não divulgar definições que eventualmente contenham dados sensíveis antes de revisar o resultado.

## Sequência proposta para implantação futura

1. Confirmar ambiente acadêmico de destino e decisões pendentes.
2. Conferir o esquema remoto e o histórico de aplicação.
3. Revisar/corrigir os achados prioritários antes de transportar os scripts.
4. Adaptar o bootstrap administrativo sem identificações fixas da origem.
5. Aplicar a sequência revisada em ambiente isolado e executar os testes.
6. Publicar funções e configurar o frontend no ambiente definido.
7. Registrar evidências, limitações e aprovação da entrega.

## Validação desta entrega documental

Foram revisadas as 13 migrations locais e as três Edge Functions. O dicionário e o DER foram montados a partir das definições de tabela e das adições de colunas encontradas. A matriz considera a substituição das políticas nas migrations posteriores. A conferência automatizada verifica contagem de tabelas/colunas, presença dos campos no DER, links locais e hashes das fontes.

Não houve execução do esquema, teste de integração, teste de RLS ou auditoria completa de segurança. Os diagramas são representações do modelo documentado, não exportações do painel Supabase.
