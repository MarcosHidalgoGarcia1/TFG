WITH relaciones(nombre_linea, nombre_autobus) AS (
    VALUES
    ('M-104 · Alcalá de Guadaíra – Hospital de Valme',
     'M-104'),

    ('M-131 · Dos Hermanas – Sevilla (Directo)',
     'M-131'),

    ('M-131 · Dos Hermanas – Sevilla (por Hospital Tomillar)',
     'M-131 (Hospital Tomillar)'),

    ('M-132 · Dos Hermanas - Sevilla',
     'M-132'),

    ('M-132B · Dos Hermanas (por Polígono La Isla) – Fuente del Rey – Sevilla',
     'M-132B (Polígono La Isla)'),

    ('M-132B · Dos Hermanas (por Polígono La Isla, Crown y Copero) – Fuente del Rey – Sevilla',
     'M-132B (Crown y Copero)'),

    ('M-133 · Dos Hermanas – Montequinto (por Echaguy) – Sevilla',
     'M-133 (Echaguy)'),

    ('M-133 · Dos Hermanas (por Olivar de Quintos) – Sevilla',
     'M-133 (Olivar de Quintos)'),

    ('M-134 · Los Palacios – Sevilla',
     'M-134'),

    ('M-134 · Los Palacios – Sevilla (Directo por A-4)',
     'M-134 (Directo A-4)'),

    ('M-134 · Parcial Los Palacios – Hospital Tomillar',
     'M-134 (Hospital Tomillar)')
)
INSERT INTO linea_autobus (linea_id, autobus_id)
SELECT l.id, a.id
FROM relaciones r
JOIN linea l ON l.nombre = r.nombre_linea
JOIN autobus a ON a.nombre = r.nombre_autobus
ON CONFLICT DO NOTHING;