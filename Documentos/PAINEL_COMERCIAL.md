# Painel comercial

Entrega de 22/10/2026, branch `codex/painel-comercial`.

O início autenticado segue a organização do dashboard do projeto de origem `dmsystem/Visitas`: período, responsável e situação dos atendimentos. A apresentação usa vermelho e cinza, cartões brancos, indicadores com ícones e barras proporcionais, adaptando as colunas ao espaço disponível.

- Períodos: hoje, semana atual (segunda a domingo), mês atual e histórico completo, no horário local.
- Administrador pode filtrar o responsável; vendedor mantém a visão permitida pelas políticas do banco.
- Clientes contabiliza a carteira completa do responsável, independentemente do período.
- Visitas concluídas são filtradas pela conclusão; em andamento pelo início; agendadas e canceladas pela data agendada.
- Panorama inclui os quatro estados. O percentual concluído usa todas as visitas do período, incluindo canceladas.
- Acompanhamento por responsável apresenta concluídas / total no período.
- Próximos atendimentos exibe até seis pendências de todo o histórico, ordenadas pela data agendada, respeitando o responsável. Essa seção não é limitada ao período dos indicadores.
- Nova visita e Ver clientes abrem a carteira, onde se escolhe o cliente. O histórico abre a listagem de visitas.

Não foram adicionados indicadores de contatos comerciais ou faturamento. A importação segue como demonstração separada. Nenhuma alteração de banco ou permissão é necessária nesta entrega.

Validação: análise estática sem apontamentos; dois testes de layout e filtro em larguras de 390 e 1280 pixels. Os testes usam uma visita histórica e confirmam sua inclusão somente quando selecionado o histórico completo.

No vídeo, apresente os cartões, altere o período, explique o filtro por responsável e use Nova visita para acessar as ações do cliente. Os totais vêm dos registros visíveis ao usuário autenticado.
