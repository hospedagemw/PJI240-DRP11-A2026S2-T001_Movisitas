# Visitas em andamento

A lista de visitas apresenta primeiro os atendimentos em andamento, com destaque visual e o botão **Concluir visita**. Agendamentos, visitas concluídas e canceladas aparecem abaixo.

Cada responsável pode manter somente uma visita em andamento. Ao tentar iniciar outra, o sistema identifica o cliente do atendimento aberto e direciona para a lista de visitas. O administrador pode acompanhar atendimentos de diferentes responsáveis; a restrição permanece individual.

Para finalizar, abra **Visitas**, localize o atendimento destacado, clique em **Concluir visita**, revise as observações e confirme. O banco registra a conclusão e libera o responsável para iniciar outro atendimento.

A navegação retorna ao início das listas, evitando que a posição de rolagem de outra tela esconda o atendimento. Mensagens de código de cliente duplicado e de visita já em andamento são distintas.

Não há alteração de esquema nem encerramento automático dos registros existentes. A proteção de uma visita em andamento por responsável continua no Supabase.

Validação: análise estática Flutter e compilação web de produção.
