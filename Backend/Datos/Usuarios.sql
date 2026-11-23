CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO usuario (nombre, correo, contrasena)
VALUES
('Carlos Rodríguez', 'carlos.rodriguez@gmail.com',
 crypt('GeoBus123!', gen_salt('bf'))),

('María Fernández', 'maria.fernandez@gmail.com',
 crypt('GeoBus123!', gen_salt('bf'))),

('Daniel García', 'daniel.garcia@gmail.com',
 crypt('GeoBus123!', gen_salt('bf'))),

('Laura Sánchez', 'laura.sanchez@gmail.com',
 crypt('GeoBus123!', gen_salt('bf'))),

('Alejandro Martín', 'alejandro.martin@gmail.com',
 crypt('GeoBus123!', gen_salt('bf')));