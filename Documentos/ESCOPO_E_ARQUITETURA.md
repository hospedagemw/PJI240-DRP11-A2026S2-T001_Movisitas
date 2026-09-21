# Escopo e arquitetura previstos

## Objetivo

Organizar a gestão das visitas comerciais da Movipress, centralizando clientes, vendedores, agenda e histórico de atendimento, conforme o plano de ação do Grupo 17.

## Escopo inicial proposto

- Identificação do usuário e acesso conforme seu perfil.
- Cadastro e consulta de clientes e vendedores.
- Organização da carteira de clientes.
- Agendamento e registro de visitas.
- Consulta do histórico de atendimento.

Geolocalização, indicadores e relatórios serão priorizados conforme a necessidade da comunidade externa e a evolução da solução inicial. Importação de pedidos do ERP, recursos offline e notificações ficam fora da primeira entrega.

## Arquitetura de referência

A arquitetura abaixo foi identificada na documentação e nos arquivos do projeto de origem. Sua configuração no Movisitas ocorrerá nas fases de implementação.

| Camada | Tecnologia prevista | Finalidade |
| --- | --- | --- |
| Interface | Flutter Web/PWA | Acesso por computador e celular |
| API e autenticação | Supabase | Sessões e acesso aos dados |
| Banco | PostgreSQL | Persistência de clientes, vendedores, carteiras e visitas |
| Autorização | Políticas RLS do Supabase | Controle de acesso por perfil e carteira |
| Hospedagem | Cloudflare Pages, conforme a origem | Publicação web; ambiente acadêmico ainda a definir |
| Versionamento | Git e GitHub | Entregas por branch e Pull Request |

## Modelo conceitual inicial

Um vendedor possui uma carteira de clientes. Cada cliente pode ter visitas agendadas e atendimentos registrados. Usuários acessam as funcionalidades segundo o perfil atribuído. A modelagem física e as regras de transferência de carteira serão revisadas nos scripts existentes antes da migração do banco.

## Critérios transversais

- Validar as permissões no banco, além da interface.
- Usar dados fictícios nas demonstrações e evidências acadêmicas.
- Verificar uso por teclado, identificação dos campos, contraste e apresentação em telas pequenas nas etapas de interface.
- Executar análise, testes pertinentes e compilação web quando o código Flutter for incorporado.
- Manter os scripts do banco versionados e registrar quais foram aplicados no ambiente de destino.
- Documentar o uso de API, nuvem, banco, acessibilidade, versionamento e testes para apoiar os requisitos do tema norteador.

## Pendências para a fase de implementação

- Selecionar os arquivos mínimos para a fundação Flutter.
- Revisar o esquema existente e suas dependências.
- Definir o ambiente de banco e hospedagem do projeto acadêmico.
- Detalhar os critérios de aceitação com o grupo e a comunidade externa.

## Detalhamento do banco de dados

A análise documental de 21/09/2026 está em [Banco de Dados](Banco_de_Dados/README.md), com MER, DER, dicionário das oito tabelas da aplicação, normalização, integridade, matriz de acesso e arquitetura do Supabase. O conjunto distingue o núcleo de visitas da extensão de pedidos ERP e registra propostas de melhoria e testes pendentes.

O esquema foi reconstruído a partir de 13 migrations locais da origem; ainda não foi confrontado com o banco remoto. A relação carteira-cliente permite múltiplas carteiras por cliente no SQL existente. As migrations e o código continuam fora desta etapa de documentação.
