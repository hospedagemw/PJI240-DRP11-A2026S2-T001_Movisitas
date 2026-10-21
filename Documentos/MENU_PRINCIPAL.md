# Fase 3 — Estrutura e menu principal

> Registro histórico da primeira entrega. Para a versão atual e a apresentação, consulte o [guia do sistema e roteiro de vídeo](GUIA_E_ROTEIRO_VIDEO.md).

Entrega de 14/10/2026, branch `codex/fase-3-menu-principal`.

## Implementado

- Estrutura Flutter para web, organizada em aplicação, páginas e dados demonstrativos.
- Identidade visual: vermelho #ED3237, cinza #383838 e fundo #F7F7F8, seguindo o tema da aplicação de origem.
- Menu com Início, Clientes, Usuários, Visitas e Importação.
- Navegação lateral a partir de 800 pixels e inferior em telas menores; rótulos expandidos a partir de 1100 pixels.
- Tela inicial com três visitas fictícias e data fixa de 14/10/2026 para uma apresentação reproduzível.
- Páginas de preparação dos módulos, descrição do escopo e retorno ao início.
- Aviso sobre a demonstração acessível pelo botão de informação.

O código desta fundação foi organizado para receber os módulos gradualmente. A aplicação de origem orienta a identidade visual e o escopo; o protótipo HTML continua em `Documentos/Prototipacao` como referência documental.

## Executar

Use Flutter com Dart compatível com a restrição do `pubspec.yaml` (Dart 3.13.4 ou superior, abaixo de 4.0.0).

```sh
flutter pub get
flutter run -d chrome
```

Para gerar a versão web:

```sh
flutter build web
```

A saída fica em `build/web`; sirva essa pasta por HTTP para visualizar a compilação. Não abra o arquivo compilado diretamente pelo explorador.

## Roteiro breve para vídeo

1. Apresentar o nome Movisitas e o aviso de dados fictícios.
2. Mostrar as três visitas de exemplo na página inicial.
3. Navegar pelos quatro módulos e explicar o objetivo de cada um.
4. Mostrar a navegação em uma janela estreita.
5. Explicar que esta entrega conclui a estrutura e que os cadastros serão desenvolvidos nas etapas seguintes.

## Limites desta entrega

Não há login, controle de permissões, cadastro, persistência, conexão com Supabase ou importação funcional. O menu apresenta os módulos previstos e não representa autorização de acesso. Os dados são exemplos fixos em `lib/data/demo_data.dart`; nenhum dado real foi incorporado.

A importação futura lerá o relatório de comissão e gravará os pedidos na tabela. Não haverá cálculo de comissão. O formato e as validações serão conferidos no módulo existente antes da migração.

## Verificação

```sh
flutter analyze
flutter test
flutter build web
```

Os testes de widgets verificam os quatro destinos, o retorno ao início e a ausência de exceções em larguras de 390 e 1280 pixels. Não constituem testes de integração com banco nem avaliação com a comunidade.

## Próximas entregas

Cada funcionalidade terá sua própria branch, documentação e validação: autenticação/perfis, clientes, usuários, visitas e importação do relatório de comissão. A incorporação à main ocorrerá após revisão da respectiva entrega.

Resultado em 14/10/2026: análise sem apontamentos, dois testes aprovados e compilação web concluída. O compilador emitiu um aviso sobre a fonte CupertinoIcons; esta entrega utiliza apenas MaterialIcons. Inspeção visual realizada no site público em 16/10/2026: tela inicial, abertura de Clientes e retorno ao início conferidos. A validação com usuários permanece pendente. Consulte o [registro de publicação no Cloudflare](DEPLOY_CLOUDFLARE.md).
