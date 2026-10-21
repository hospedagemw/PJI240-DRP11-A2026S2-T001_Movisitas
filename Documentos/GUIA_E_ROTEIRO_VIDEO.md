# Guia do sistema e roteiro de vídeo

Referência: versão demonstrativa publicada em 21/10/2026, código `9c0370e`. Duração sugerida: 5 a 7 minutos; adaptar ao limite exigido pela disciplina. Este roteiro não substitui as orientações do AVA.

## O que está funcionando nesta versão

| Área | Disponível para demonstrar | Ainda falta implementar |
| --- | --- | --- |
| Início | Menu responsivo, identidade visual, três visitas de exemplo e aviso de demonstração | Indicadores e agenda consultados do banco |
| Usuários | Consulta de cinco personagens fictícios com perfil e e-mail | Login, criação de contas, edição, ativação e autorização |
| Clientes | Consulta de seis clientes, códigos, cidades e responsáveis | Formulário, validações, gravação e edição no banco |
| Visitas | Consulta de doze exemplos com data, responsável e situação | Agendar, iniciar, concluir e salvar atendimentos |
| Importação | Baixar HTML, selecionar arquivo, ler 18 exemplos, rejeitar alterações e evitar duplicação em memória | Importação autenticada e persistência dos pedidos pelo aplicativo |
| Supabase | Carga independente de 5 usuários demonstrativos, 6 clientes, 12 visitas e 18 pedidos no schema academic_demo | Integração dessas operações com o site e regras de acesso por usuário |
| Publicação | Aplicação Flutter web no Cloudflare Pages | Publicação automática pelo Git |

Os usuários demonstrativos não são contas Auth. As listagens não são formulários de cadastro. A carga já gravada no Supabase não significa que a importação do navegador salva no banco. A página inicial usa uma agenda fixa de 14/10/2026, separada dos doze exemplos da listagem de visitas; não é uma consulta da agenda do dia.

## Documentação relacionada

- [Dados fictícios, HTML, carga e verificações](DADOS_FICTICIOS.md).
- [Estrutura e menu principal — registro histórico da primeira entrega](MENU_PRINCIPAL.md).
- [Publicação no Cloudflare e atualização manual](DEPLOY_CLOUDFLARE.md).
- [MER, DER, dicionário e análise do banco de origem](Banco_de_Dados/README.md).
- [Protótipo e escopo planejado das telas](Prototipacao/README.md).

O protótipo documenta o planejamento de telas. Não deve ser apresentado como prova de que todos os módulos já foram implementados. A modelagem da origem e o schema academic_demo têm finalidades diferentes: o segundo é uma carga isolada para demonstração.

## Preparar a gravação

1. Abrir https://movisitas-academico.pages.dev/ e usar uma janela que mostre o menu e os textos com boa legibilidade.
2. Fechar notificações e abas pessoais. Gravar apenas a janela da aplicação, com microfone; fazer um teste curto de áudio.
3. Baixar https://movisitas-academico.pages.dev/exemplos/vendas-ficticias.html e deixá-lo em uma pasta fácil de localizar.
4. Recarregar a aplicação antes do ensaio. A importação deve começar com 6 pedidos e R$ 9.561,75.
5. Manter este roteiro em outra janela ou dispositivo para consulta. Não mostrar senhas, chaves ou painéis de conta no vídeo.
6. Gravar por blocos curtos permite corrigir uma fala sem refazer tudo. Fazer um ensaio antes da versão final.

## Roteiro falado da versão atual

As falas abaixo podem ser adaptadas à voz do apresentador. Identificar o grupo e os participantes conforme a entrega acadêmica.

### 1. Apresentação — 0:00 a 0:40

**Na tela:** página inicial.

**Fala:** “Este é o Movisitas, um projeto acadêmico voltado à organização de visitas comerciais. A proposta é centralizar informações de clientes, equipe, agenda e pedidos para facilitar o acompanhamento dos atendimentos. Nesta apresentação, todos os nomes e lançamentos são fictícios. Vou mostrar a versão demonstrativa que já está publicada e explicar as funcionalidades previstas para as próximas etapas.”

### 2. Análise da página inicial — 0:40 a 1:30

**Na tela:** apontar o nome do sistema, o aviso de dados fictícios, o menu e os cartões de visitas. Abrir o botão de informação e fechar.

**Fala:** “A página inicial reúne os acessos aos módulos de clientes, usuários, visitas e importação. A identidade visual utiliza vermelho e cinza, mantendo o padrão da aplicação de referência. Os cartões mostram horário, cliente e cidade para facilitar a leitura do roteiro de atendimento. Nesta etapa, a agenda é fixa e ilustrativa, com a data de 14 de outubro de 2026. Ela ainda não consulta automaticamente o banco. O aviso de demonstração deixa explícito que os dados são exemplos.”

**Análise:** a hierarquia destaca navegação e roteiro; os rótulos ajudam a identificar os módulos. A adaptação da navegação para telas pequenas foi testada em widgets, mas isso não substitui avaliação de usabilidade com usuários. Ainda faltam agenda dinâmica, busca e ações de atendimento.

### 3. Usuários — 1:30 a 2:10

**Na tela:** abrir Usuários e mostrar alguns registros.

**Fala:** “Aqui temos cinco usuários fictícios, com nomes, e-mails de exemplo e papéis de administradora, gestor e vendedores. Isso permite apresentar a organização prevista da equipe. Por enquanto, esta tela consulta os exemplos; os registros não têm login nem senha. O cadastro de contas e as permissões serão implementados em uma etapa própria.”

### 4. Clientes — 2:10 a 2:50

**Na tela:** abrir Clientes; destacar um código e o responsável.

**Fala:** “A listagem reúne seis clientes fictícios. Cada um apresenta um código interno, cidade, e-mail e responsável. O código é importante para relacionar os pedidos importados ao cliente correspondente. Esta entrega permite consultar a carteira demonstrativa. A inclusão e a edição por formulário, com gravação no banco, ainda serão desenvolvidas.”

### 5. Visitas — 2:50 a 3:30

**Na tela:** abrir Visitas e mostrar situações diferentes.

**Fala:** “O módulo de visitas apresenta doze exemplos, relacionando o cliente ao integrante da equipe, à data, ao horário e à situação do atendimento. Existem visitas agendadas, concluídas e canceladas para ilustrar diferentes cenários. Nesta versão, as situações são dados de exemplo; ainda não são alteradas por ações de iniciar ou concluir uma visita.”

### 6. Importação de vendas — 3:30 a 5:10

**Na tela:** abrir Importação. Mostrar os seis pedidos iniciais. Clicar em Baixar HTML fictício, depois em Selecionar HTML e escolher o arquivo baixado. Aguardar a mensagem de resultado. Repetir usando Importar exemplo incluído.

**Fala antes da carga:** “Esta área lê um relatório HTML no formato utilizado para importar pedidos. O arquivo preparado contém dezoito vendas fictícias. O sistema não calcula comissão: ele utiliza os dados do relatório para representar os pedidos. A demonstração começa com seis registros.”

**Fala após a carga:** “O resultado mostra doze pedidos acrescentados e seis já existentes. Agora temos dezoito pedidos, somando quarenta e três mil, quinhentos e oito reais e vinte e cinco centavos em vendas fictícias. Esse total não é um valor de comissão.”

**Fala após repetir:** “Ao importar novamente, nenhum pedido é acrescentado e os dezoito existentes são identificados. Isso demonstra a prevenção de duplicação. Nesta versão pública, a operação aceita apenas o conjunto fictício fornecido e fica na memória do navegador. Ao recarregar a página, voltamos aos seis registros iniciais.”

**Se ocorrer falha:** parar e verificar o arquivo e a mensagem. Não narrar sucesso sem o resultado aparecer. O botão Importar exemplo incluído permite demonstrar a leitura do mesmo conteúdo sem selecionar um arquivo; explicar essa alternativa se usá-la.

### 7. Banco, documentação e evolução — 5:10 a 6:10

**Na tela:** mostrar a documentação no repositório, sem abrir configurações ou credenciais.

**Fala:** “A documentação registra o escopo, a modelagem de dados, os protótipos, as etapas implementadas e as verificações. Também foi preparada e carregada no Supabase acadêmico uma base independente com os mesmos exemplos. Essa base está isolada e ainda não é sincronizada com a interface. O código é desenvolvido em branches e enviado para revisão, permitindo acompanhar as entregas reais. Os próximos passos são autenticação, formulários de cadastro, operações de visitas e importação persistida no banco.”

### 8. Encerramento — 6:10 a 6:30

**Na tela:** voltar ao início.

**Fala:** “Esta entrega demonstra a navegação, a consulta de exemplos e a leitura do relatório de vendas com prevenção de duplicação. A evolução será validada módulo a módulo até que o fluxo completo possa ser utilizado e avaliado pelos usuários.”

## Para gravar o sistema completo com cadastros reais

O vídeo acima serve à entrega demonstrativa atual. Para o vídeo final, implementar e verificar primeiro:

1. **Autenticação e usuários:** login, encerramento de sessão e criação de usuários por pessoa autorizada, com perfis e regras de acesso no banco. Não confundir registro de personagem com conta de acesso.
2. **Clientes:** incluir um cliente fictício pelo formulário, validar campos, salvar, consultar, editar e confirmar que o registro permanece após recarregar.
3. **Visitas:** agendar para o cliente e vendedor, atualizar situação e confirmar persistência. Definir as regras para cancelamento e conclusão antes da implementação.
4. **Importação persistida:** ler o HTML, validar vínculo do cliente, gravar os pedidos uma única vez, repetir a importação e comprovar que não duplica. Continuar sem cálculo de comissão.
5. **Página inicial integrada:** consultar a agenda e os dados do banco, com estados de carregamento, erro e lista vazia.
6. **Ensaio completo:** usar apenas ambiente acadêmico e dados fictícios, verificar isolamento de usuários e reexecutar o percurso após uma nova sessão.

### Sequência do vídeo final, após implementação

Login autorizado → criação de usuário de exemplo → cadastro de cliente → agendamento de visita → consulta na página inicial → atualização da visita → importação do relatório → repetição sem duplicação → recarregamento comprovando persistência → explicação da documentação e dos resultados.

O roteiro falado deverá ser revisado quando essas funcionalidades existirem. Até lá, não narrar criação, edição, autenticação ou gravação pelo site como operações disponíveis.

## Checklist da entrega do vídeo

- Os resultados narrados aparecem na tela e correspondem à versão gravada.
- Todas as informações exibidas são fictícias.
- Áudio compreensível e textos legíveis.
- Abertura identifica projeto e grupo conforme a disciplina.
- Limites da versão e próximos passos são explicados.
- Duração, formato, link e permissões de visualização atendem às orientações do AVA.
- Uma pessoa do grupo assiste ao arquivo final antes da entrega.
