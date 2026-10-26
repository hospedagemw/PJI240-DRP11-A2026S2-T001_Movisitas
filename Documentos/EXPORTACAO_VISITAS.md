# Exportação de visitas em HTML

Na página **Início**, o botão **Exportar visitas** abre um formulário para gerar um arquivo HTML formatado, pronto para consulta e impressão no navegador.

## Filtros

- Status: todos, agendada, em andamento, concluída ou cancelada.
- Equipe ou responsável: toda a equipe ou um responsável, somente para administrador.
- Período: intervalo personalizado com primeiro e último dia incluídos, ou todo o histórico.

O formulário inicia com o período e responsável selecionados no painel. O filtro do relatório considera sempre a **data agendada**, independentemente do status. O painel mantém seu critério de data por situação; por isso, seus totais podem diferir dos totais exportados para um período.

## Conteúdo

Cabeçalho com os filtros e data de geração, total de visitas, contagem por situação e tabela com cliente, responsável, status, agendamento, início, conclusão e observações. Sem resultados, o arquivo apresenta uma mensagem explícita. É possível imprimir ou salvar em PDF pelo navegador.

## Acesso e integridade

Antes de gerar o arquivo, o aplicativo consulta novamente o perfil ativo e os registros no Supabase. Administradores exportam os registros permitidos à equipe; vendedores exportam exclusivamente suas próprias visitas. A segurança continua amparada nas policies existentes, sem ampliação de permissões ou mudança de esquema.

A consulta é paginada em lotes de até mil visitas, com ordenação por agendamento e identificador. Nomes são consultados em lotes. Dados de texto são escapados no HTML, impedindo que observações sejam interpretadas como marcação ou scripts. O arquivo não utiliza recursos externos.

Datas são apresentadas no horário local do dispositivo que gera o relatório. O documento é uma cópia estática dos dados consultados; mudanças simultâneas durante uma exportação longa podem alterar os registros entre lotes.

## Uso

1. Abra Início e clique em Exportar visitas.
2. Escolha o status, o responsável quando disponível e o período.
3. Clique em Baixar HTML e abra o arquivo salvo nos downloads do navegador.
4. Utilize a impressão do navegador se desejar uma cópia em papel ou PDF.

## Validação técnica

Análise Flutter sem problemas; cinco testes aprovados para HTML escapado, resultado vazio, seletor restrito ao administrador e painel em larguras de celular e computador. Compilação web release concluída. A exportação utiliza as permissões já existentes no banco.
