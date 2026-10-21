begin;
-- Repetível: os IDs fixos evitam duplicação e preservam registros existentes.
insert into academic_demo.users ("id","name","role","email") values
('U001','Ana Exemplo','Administradora','usuario1@example.com'),
('U002','Bruno Modelo','Gestor','usuario2@example.com'),
('U003','Carla Demonstração','Vendedora','usuario3@example.com'),
('U004','Diego Exemplo','Vendedor','usuario4@example.com'),
('U005','Elisa Modelo','Vendedora','usuario5@example.com')
on conflict (id) do nothing;
insert into academic_demo.clients ("id","code","name","city","email","seller") values
('C001','900001','Mercado Horizonte','Cidade Exemplo','cliente1@example.com','U003'),
('C002','900002','Empório Jardim','Cidade Exemplo','cliente2@example.com','U004'),
('C003','900003','Distribuidora Aurora','Vila Modelo','cliente3@example.com','U005'),
('C004','900004','Loja Estrela','Vila Modelo','cliente4@example.com','U003'),
('C005','900005','Comercial Primavera','Cidade Ilustração','cliente5@example.com','U004'),
('C006','900006','Armazém das Nuvens','Cidade Ilustração','cliente6@example.com','U005')
on conflict (id) do nothing;
insert into academic_demo.visits ("id","client","user","date","time","status","notes") values
('V001','C001','U003','2026-10-19','09:00','Concluída','Apresentação fictícia do catálogo.'),
('V002','C002','U004','2026-10-19','11:00','Agendada','Revisão fictícia de necessidades.'),
('V003','C003','U005','2026-10-19','14:30','Cancelada','Reagendamento demonstrativo.'),
('V004','C004','U003','2026-10-20','09:00','Concluída','Apresentação fictícia do catálogo.'),
('V005','C005','U004','2026-10-20','11:00','Agendada','Revisão fictícia de necessidades.'),
('V006','C006','U005','2026-10-20','14:30','Cancelada','Reagendamento demonstrativo.'),
('V007','C001','U003','2026-10-21','09:00','Concluída','Apresentação fictícia do catálogo.'),
('V008','C002','U004','2026-10-21','11:00','Agendada','Revisão fictícia de necessidades.'),
('V009','C003','U005','2026-10-21','14:30','Cancelada','Reagendamento demonstrativo.'),
('V010','C004','U003','2026-10-22','09:00','Concluída','Apresentação fictícia do catálogo.'),
('V011','C005','U004','2026-10-22','11:00','Agendada','Revisão fictícia de necessidades.'),
('V012','C006','U005','2026-10-22','14:30','Cancelada','Reagendamento demonstrativo.')
on conflict (id) do nothing;
insert into academic_demo.orders ("id","client","date","cents") values
('DEMO-0001','C001','2026-10-01',125050),
('DEMO-0002','C002','2026-10-02',138775),
('DEMO-0003','C003','2026-10-03',152500),
('DEMO-0004','C004','2026-10-04',166225),
('DEMO-0005','C005','2026-10-05',179950),
('DEMO-0006','C006','2026-10-06',193675),
('DEMO-0007','C001','2026-10-07',207400),
('DEMO-0008','C002','2026-10-08',221125),
('DEMO-0009','C003','2026-10-09',234850),
('DEMO-0010','C004','2026-10-10',248575),
('DEMO-0011','C005','2026-10-11',262300),
('DEMO-0012','C006','2026-10-12',276025),
('DEMO-0013','C001','2026-10-13',289750),
('DEMO-0014','C002','2026-10-14',303475),
('DEMO-0015','C003','2026-10-15',317200),
('DEMO-0016','C004','2026-10-16',330925),
('DEMO-0017','C005','2026-10-17',344650),
('DEMO-0018','C006','2026-10-18',358375)
on conflict (id) do nothing;
commit;
