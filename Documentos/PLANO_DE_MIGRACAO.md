# Plano de migração por fases

## Referências e procedência

Este planejamento se baseia no plano de ação do Grupo 17 e nas orientações de `PI.txt`. A divisão técnica abaixo é uma proposta de execução para atender às entregas acadêmicas; não modifica os responsáveis ou o cronograma do plano original.

Origem: projeto Visitas, cópia local `visitas-publish`, associado ao repositório `dmsystem/Visitas`. Referência inspecionada: commit `d106776`, de 01/09/2026. O projeto existente será incorporado por módulos, preservando a identificação de sua origem e distinguindo adaptações e funcionalidades novas.

Destino: repositório `hospedagemw/PJI240-DRP11-A2026S2-T001_Movisitas`.

## Cronograma acadêmico

| Quinzena | Período de 2026 | Objetivo previsto no plano do grupo |
| --- | --- | --- |
| 1 | 10/08 a 23/08 | Análise do cenário e levantamento bibliográfico |
| 2 | 24/08 a 06/09 | Comunidade externa, definição do problema e plano de ação |
| 3 | 07/09 a 20/09 | Título, visita ao local e desenvolvimento |
| 4 | 21/09 a 04/10 | Solução inicial, sugestões da comunidade e relatório parcial |
| 5 | 05/10 a 18/10 | Solução final a partir das sugestões |
| 6 | 19/10 a 01/11 | Análise dos resultados, finalização do protótipo e preparação do vídeo |
| 7 | 02/11 a 15/11 | Relatório final e vídeo |

O TXT também prevê avaliação colaborativa na sétima quinzena. Os prazos de envio no AVA devem ser conferidos pelo grupo; os períodos acima são os registrados no PDF.

## Entregas técnicas propostas

| Fase | Conteúdo | Critério de conclusão | Alinhamento |
| --- | --- | --- | --- |
| 1 — Estrutura e documentação | Apresentação, escopo, arquitetura e plano de migração | Documentação revisada e origem identificada | Quinzena 3 |
| 2 — Modelagem do banco | MER, DER, dicionário, integridade e arquitetura Supabase | Documentação rastreável aos scripts; limitações e testes pendentes identificados | Quinzena 4 |
| 3 — Fundação da aplicação | Estrutura Flutter, identidade visual, navegação e demonstração com dados fictícios | Aplicação executa e navegação principal é validada | Quinzena 4 (replanejada) |
| 4 — Solução inicial | Clientes, vendedores, agenda e registro básico de visitas; banco e autenticação necessários a esses fluxos | Fluxo principal validado, permissões verificadas e evidências para o relatório parcial | Quinzena 4 |
| 5 — Melhorias da solução | Sugestões da comunidade, histórico, geolocalização e indicadores priorizados | Ajustes registrados e critérios de aceitação atendidos | Quinzena 5 |
| 6 — Validação | Testes, acessibilidade, análise dos resultados e preparação da demonstração | Resultados documentados e limitações identificadas | Quinzena 6 |
| 7 — Entrega final | Apoio técnico ao relatório, roteiro e evidências para o vídeo | Materiais revisados pelo grupo e versão final identificada | Quinzena 7 |

As fases técnicas não correspondem uma a uma às quinzenas. Pedidos do ERP e outras funções da origem serão avaliados separadamente, pois não são necessários ao escopo inicial de visitas.

## Procedimento por entrega

1. Delimitar o módulo e seus critérios de aceitação.
2. Criar uma branch por fase. Preferir a `main` atualizada após a integração da etapa anterior; quando houver dependência ainda em revisão, partir da branch anterior e registrar essa dependência no Pull Request.
3. Selecionar os arquivos da origem e revisar dependências antes da incorporação.
4. Adaptar a identificação do projeto, as configurações e os testes necessários.
5. Registrar o que foi migrado, alterado e validado, inclusive limitações.
6. Fazer commits descritivos e enviar a branch para revisão por Pull Request.
7. Integrar a entrega aprovada à `main`.

## Banco de dados

Os scripts da origem têm dependências e devem ser revisados na ordem antes de sua seleção. Não serão executados nesta fase. A configuração do ambiente acadêmico será definida antes de qualquer aplicação de scripts. Credenciais, dados reais de clientes e cópias de banco não integram esta entrega.

## Estado da fase 1

- Branch `fase-1/estrutura-inicial` enviada ao GitHub com o commit `30882fd`.
- Documentação inicial preparada para revisão.
- Código da aplicação e scripts do banco ainda não incorporados.
- Integração à `main` pendente.

## Atualização de 21/09/2026 — fase 2

A modelagem do banco foi separada em `fase-2/modelagem-banco`, baseada na fase 1, com o commit `3e3d17b`. A análise usa a revisão `9abc65a63c4d0bfde67d5550f8ac74b121d9f63a` da origem e está detalhada em [Banco de Dados](Banco_de_Dados/README.md).

A fundação da aplicação passa a ser a fase 3, planejada para a quarta quinzena juntamente com a solução inicial. Essa revisão do planejamento técnico não altera as datas de entrega da faculdade. O esquema remoto e os testes do banco continuam pendentes.