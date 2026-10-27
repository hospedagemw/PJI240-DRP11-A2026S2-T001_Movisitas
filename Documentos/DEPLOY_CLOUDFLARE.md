# Publicação no Cloudflare Pages

## Estado atual — revisão documental de 27/10/2026

A versão publicada possui autenticação e integração ao Supabase, painel, clientes, visitas, administração de usuários e exportação HTML agrupada. Os relatos da publicação inicial e de 21/10 abaixo são históricos. A última melhoria de exportação foi publicada em 26/10/2026, commit d4e223f.

Para entender cada serviço, consulte [tecnologias e funcionamento](TECNOLOGIAS_E_FUNCIONAMENTO.md).

Site acadêmico: https://movisitas-academico.pages.dev/

Projeto Pages: `movisitas-academico`. Publicação inicial em 14/10/2026, verificada no navegador em 16/10/2026. Código publicado: commit `680843c`, da etapa do menu principal.

## Conteúdo da publicação inicial — histórico

Aplicação Flutter web com navegação entre Início, Clientes, Usuários, Visitas e Importação. A página inicial contém somente visitas fictícias. Os demais módulos apresentam o escopo previsto. Esta versão não possui login nem conexão com Supabase.

## Atualizar a publicação

O projeto utiliza **Direct Upload**. Um commit ou merge no GitHub não publica automaticamente uma nova versão.

1. Selecionar a versão revisada do código. Preparar o arquivo local ignorado pelo Git com a URL e a chave pública do Supabase, conforme o guia de tecnologias. Executar na raiz:

```sh
flutter pub get
flutter analyze
flutter test
flutter build web --release --dart-define-from-file=config.local.json
```

2. Compactar o conteúdo de `build/web` em ZIP, com `index.html` na raiz do arquivo, sem incluir a pasta `web` como nível adicional.
3. No painel Cloudflare, abrir Workers & Pages e o projeto existente `movisitas-academico`.
4. Criar uma nova implantação de produção e enviar o ZIP.
5. Aguardar a confirmação, abrir o endereço público e conferir login, tela inicial, navegação e a funcionalidade modificada.
6. Registrar o commit publicado, a data e o resultado da verificação na documentação da entrega.

Não incluir arquivos `.env`, credenciais, dados profissionais ou arquivos de trabalho no pacote. O pacote contém apenas a saída web compilada. Não foi configurado domínio personalizado nem integração automática com Git.

## Verificação da publicação inicial — histórico

- Compilação anterior: análise sem apontamentos, dois testes aprovados e build web concluído, conforme o guia do menu.
- Publicação: envio dos 38 arquivos concluído e sucesso confirmado pelo Cloudflare.
- Inspeção pública em 16/10/2026: página inicial renderizada, identidade visual preservada, três visitas fictícias visíveis, abertura de Clientes e retorno ao início funcionando.
- A inspeção pública cobriu a janela de computador; as larguras de 390 e 1280 pixels foram verificadas pelos testes de widgets da etapa do menu.
- Autenticação, integração com banco e validação com usuários permanecem para as próximas entregas.

Consulte [a implementação do menu](MENU_PRINCIPAL.md) para os limites e o roteiro de apresentação.

## Atualização de 21/10/2026

Publicada a branch `codex/dados-ficticios-importacao`, com consultas de usuários, clientes, visitas e pedidos fictícios, download do relatório HTML e importação local sem duplicação. Cloudflare confirmou o envio de 41 arquivos e a implantação concluída. O HTML está disponível em https://movisitas-academico.pages.dev/exemplos/vendas-ficticias.html.

O Supabase acadêmico recebeu uma carga independente no schema `academic_demo`, sem acesso público nem conexão automática com o navegador. Consulte [dados fictícios e limitações](DADOS_FICTICIOS.md).
