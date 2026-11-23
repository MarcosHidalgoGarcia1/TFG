INSERT INTO parada_linea (parada_id, linea_id)
SELECT p.id, x.linea_id
FROM (VALUES
    (2456, ARRAY[4,5,6]),
    (3421, ARRAY[4]),
    (3415, ARRAY[4,9,11]),
    (3413, ARRAY[4,9,11]),
    (2528, ARRAY[4]),
    (3057, ARRAY[4,5,6]),
    (3056, ARRAY[1,4,5,6,9]),
    (3066, ARRAY[4,5,6]),
    (3068, ARRAY[2,3,4,5,6,9]),
    (3064, ARRAY[2,3,4,5,6,9,11]),
    (3028, ARRAY[2,3,4,5,6,9,11]),
    (3026, ARRAY[2,3,4,5,6,9,10]),
    (2962, ARRAY[2,3,4,5,6,7,8,9,10]),
    (2958, ARRAY[2,3,4,5,6,7,8,9,10]),
    (3265, ARRAY[2,3,4,5,6,7,8,9,10]),
    (3005, ARRAY[2,3,4,5,6,7,8,9,10]),
    (3021, ARRAY[2,3,4,5,6,7,8,9,10]),
    (2953, ARRAY[2,3,4,5,6,7,8,9,10]),
    (2959, ARRAY[2,3,4,5,6,7,8,9,10,11]),
    (2961, ARRAY[2,3,4,5,6,7,8,9,10,11]),
    (2963, ARRAY[2,3,4,5,6,7,8,9,10,11]),
    (3025, ARRAY[2,3,4,5,6,9,10]),
    (3027, ARRAY[1,4,5,6,9]),
    (3012, ARRAY[4,5,6]),
    (3030, ARRAY[2,3,4,5,6,9]),
    (3266, ARRAY[2,3,4,5,6,9]),
    (3065, ARRAY[2,3,4,5,6,9]),
    (2518, ARRAY[2,3,4,5,6,9]),
    (3414, ARRAY[4,9,11]),
    (3416, ARRAY[4,9,11]),
    (2512, ARRAY[4]),
    (2513, ARRAY[4]),
    (2514, ARRAY[4]),
    (2476, ARRAY[4,10]),
    (3419, ARRAY[4,10]),
    (2472, ARRAY[4]),
    (2473, ARRAY[4]),
    (2471, ARRAY[4]),
    (2470, ARRAY[4]),
    (2469, ARRAY[4,5,6])
) AS datos(codigo_ctmas, lineas)
INNER JOIN parada p
    ON p.codigo_ctmas = datos.codigo_ctmas
CROSS JOIN LATERAL unnest(datos.lineas) AS x(linea_id)
ON CONFLICT (parada_id, linea_id) DO NOTHING;

-- ==========================================
-- 3. CONSULTAR PARADAS Y SUS LINEAS
-- ==========================================

SELECT
    p.codigo_ctmas,
    p.nombre AS parada,
    l.nombre AS linea
FROM parada_linea pl
JOIN parada p ON p.id = pl.parada_id
JOIN linea l ON l.id = pl.linea_id
ORDER BY p.codigo_ctmas, l.id;