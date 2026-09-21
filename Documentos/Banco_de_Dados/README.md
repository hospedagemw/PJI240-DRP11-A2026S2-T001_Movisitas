# Banco de dados do Movisitas

> Análise documental em 21/09/2026. Esquema reconstruído dos 13 scripts locais da origem; não é uma inspeção do banco remoto nem comprova que as migrations foram aplicadas. Nenhum SQL foi executado no Supabase.

Este conjunto descreve o banco do projeto Visitas usado como base da migração acadêmica. O destino Movisitas ainda não recebeu o código nem as migrations. A inclusão destes documentos registra análise e planejamento, não implantação.

## Roteiro de leitura

| Documento | Conteúdo |
| --- | --- |
| [MER](01_MER.md) | Entidades, relações, cardinalidades e regras de negócio |
| [DER e modelo físico](02_DER.md) | Diagrama com chaves, vínculos, exclusões e índices |
| [Dicionário de dados](03_DICIONARIO.md) | Todas as colunas das oito tabelas da aplicação |
| [Integridade e normalização](04_ANALISE.md) | Dependências, normalização, limitações e melhorias propostas |
| [Supabase e segurança](05_SUPABASE.md) | Arquitetura, autenticação, RLS, funções e operação |
| [Rastreabilidade e validação](06_VALIDACAO.md) | Inventário das migrations, critérios de teste e implantação |
| [Consulta de metadados](consultar_metadados.sql) | Consultas somente de leitura para futura conferência remota |
| [Manifesto das fontes](fontes.json) | Caminhos relativos e hashes SHA-256 dos arquivos analisados |

## Limites e evidências

- Base local identificada pelo commit `9abc65a63c4d0bfde67d5550f8ac74b121d9f63a` do projeto `dmsystem/Visitas`; hashes em `fontes.json` identificam os arquivos efetivamente lidos.
- A documentação antiga relata a aplicação da migration inicial em 11/08/2026. Isso é registro histórico, não validação das 13 migrations no ambiente atual.
- Não há conector Supabase de inspeção do banco disponível nesta sessão. O esquema remoto, as configurações de Auth, os grants efetivos e as funções publicadas precisam de conferência posterior.
- O núcleo tem sete tabelas em `public`. `sales_orders` é uma oitava tabela, de integração com o ERP, documentada como extensão fora da primeira entrega funcional.
- `auth.users` pertence ao Supabase Auth; aparece somente como referência de identidade.
- Diagramas em Mermaid ficam versionados junto com o texto. Os nomes conceituais em português correspondem aos identificadores físicos em inglês.

As análises não afirmam que todos os controles descritos estão implementados: fatos dos scripts, comportamento da aplicação e propostas são identificados separadamente.
