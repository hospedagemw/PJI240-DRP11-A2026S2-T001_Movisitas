# Administração de usuários

Somente um administrador ativo pode cadastrar, editar e desativar ou reativar usuários. O vendedor consulta apenas seu próprio perfil.

- **Novo usuário:** nome, e-mail, senha inicial de 8 a 128 caracteres e perfil (administrador ou vendedor). O administrador preenche a senha no formulário; ela não é documentada, exibida na listagem ou salva no repositório.
- **Editar:** altera nome e perfil. Não modifica e-mail nem senha de uma conta existente.
- **Desativar:** exclusão lógica. Bloqueia o acesso aos dados e conserva vínculos com clientes e visitas. Exige concluir o atendimento em andamento antes de desativar.
- **Reativar:** restaura o acesso correspondente ao perfil.
- **Proteção do administrador:** não pode desativar a própria conta nem remover seu próprio perfil administrativo.

## Implementação

O formulário Flutter chama a Edge Function `admin-users` para criar uma conta no Supabase Auth. A função valida o token e consulta o perfil ativo no banco antes de usar a chave administrativa, disponível exclusivamente no ambiente do servidor. Se a criação do perfil falhar, tenta reverter a conta recém-criada; se a reversão falhar, informa a necessidade de revisão no Supabase.

Alterações e desativação usam `admin_update_profile`, com verificação de autorização no banco. Nenhum acesso direto de escrita na tabela profiles é concedido ao navegador. As policies existentes consultam o status ativo para bloquear leitura e alterações de dados por contas desativadas.

## Publicação e validação

Aplicar `20261023000300_admin_usuarios.sql`, publicar `supabase/functions/admin-users/index.ts` com validação de JWT e publicar o aplicativo. Não colocar service_role no Flutter ou na configuração pública.

Validar formulário vazio, edição própria, cadastro por administrador, recusa a vendedor e anônimo, edição, desativação e reativação. Cadastro de contas com senha é concluído pelo administrador no formulário.

A validação legada de JWT do gateway fica desativada para aceitar as chaves atuais do projeto. A função continua exigindo token validado pelo Supabase Auth com getUser e perfil de administrador ativo. Não há cadastro anônimo.

Validação executada: análise Flutter sem problemas, dois testes do formulário aprovados, compilação release concluída e teste transacional no Supabase aprovado (edição, desativação, reativação, bloqueio de vendedor/anônimo e proteção da própria conta). Os registros de teste foram revertidos.
