-- =====================================================================
--  GeoBus · Proyecto Intermodular 2º DAM
--  Esquema de la base de datos (PostgreSQL 18)
--
--  Cómo usarlo: conéctate a la base de datos GeoBus (vacía) y ejecuta
--  este archivo entero. Crea 9 tablas, sus índices y una vista.
--  Las notificaciones «avísame X minutos antes» NO se guardan aquí.
--  No contiene datos ni contraseñas.
--
--  Para empezar de cero (BORRA TODO, incluidos los datos), descomenta:
--    DROP VIEW  IF EXISTS parada_de_linea;
--    DROP TABLE IF EXISTS monedero, aviso, favorito, usuario,
--                         hora_de_paso, viaje, calendario, linea, parada CASCADE;
-- =====================================================================


-- ---------------------------------------------------------------------
--  1. TABLAS DEL TRANSPORTE (se cargan desde el GTFS del Consorcio)
--     Los identificadores son TEXT: el GTFS no fija su longitud.
-- ---------------------------------------------------------------------

CREATE TABLE parada (
    parada_id  TEXT          PRIMARY KEY,
    nombre     TEXT          NOT NULL,
    latitud    NUMERIC(9,6)  NOT NULL CHECK (latitud  BETWEEN  -90 AND  90),
    longitud   NUMERIC(9,6)  NOT NULL CHECK (longitud BETWEEN -180 AND 180),
    codigo     TEXT
);

CREATE TABLE linea (
    linea_id      TEXT  PRIMARY KEY,
    nombre_corto  TEXT  NOT NULL,
    nombre_largo  TEXT
);

CREATE TABLE calendario (
    servicio_id  TEXT      PRIMARY KEY,
    lunes        SMALLINT  NOT NULL CHECK (lunes     IN (0,1)),
    martes       SMALLINT  NOT NULL CHECK (martes    IN (0,1)),
    miercoles    SMALLINT  NOT NULL CHECK (miercoles IN (0,1)),
    jueves       SMALLINT  NOT NULL CHECK (jueves    IN (0,1)),
    viernes      SMALLINT  NOT NULL CHECK (viernes   IN (0,1)),
    sabado       SMALLINT  NOT NULL CHECK (sabado    IN (0,1)),
    domingo      SMALLINT  NOT NULL CHECK (domingo   IN (0,1)),
    fecha_inicio DATE      NOT NULL,
    fecha_fin    DATE      NOT NULL,
    CHECK (fecha_fin >= fecha_inicio)
);

CREATE TABLE viaje (
    viaje_id     TEXT  PRIMARY KEY,
    linea_id     TEXT  NOT NULL REFERENCES linea(linea_id),
    servicio_id  TEXT  NOT NULL REFERENCES calendario(servicio_id),
    destino      TEXT                      -- separa ida y vuelta ("Dirección Alcalá")
);

CREATE TABLE hora_de_paso (
    viaje_id      TEXT     NOT NULL REFERENCES viaje(viaje_id) ON DELETE CASCADE,
    orden_parada  INTEGER  NOT NULL,
    parada_id     TEXT     NOT NULL REFERENCES parada(parada_id),
    hora_llegada  INTERVAL NOT NULL,       -- INTERVAL: el GTFS admite horas > 24:00
    hora_salida   INTERVAL NOT NULL,
    PRIMARY KEY (viaje_id, orden_parada)
);


-- ---------------------------------------------------------------------
--  2. TABLAS PROPIAS DE LA APLICACIÓN
-- ---------------------------------------------------------------------

CREATE TABLE usuario (
    usuario_id       INTEGER       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    correo           VARCHAR(150)  NOT NULL UNIQUE,
    contrasena_hash  VARCHAR(255)  NOT NULL   -- nunca la contraseña en claro
);

-- Acceso directo a una parada desde el menú Inicio.
CREATE TABLE favorito (
    usuario_id  INTEGER  NOT NULL REFERENCES usuario(usuario_id) ON DELETE CASCADE,
    parada_id   TEXT     NOT NULL REFERENCES parada(parada_id)   ON DELETE CASCADE,
    PRIMARY KEY (usuario_id, parada_id)       -- una parada solo una vez por usuario
);

-- Incidencias del servicio (retrasos, cancelaciones, averías...).
-- Las inserta el backend automáticamente; no hay administradores.
-- linea_id y parada_id son opcionales: sin ninguno, el aviso es general.
CREATE TABLE aviso (
    aviso_id     INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    linea_id     TEXT         REFERENCES linea(linea_id)   ON DELETE CASCADE,
    parada_id    TEXT         REFERENCES parada(parada_id) ON DELETE CASCADE,
    tipo         VARCHAR(20)  NOT NULL
                 CHECK (tipo IN ('retraso','cancelacion','incidencia','cambio_servicio')),
    descripcion  TEXT         NOT NULL,
    inicio       TIMESTAMPTZ  NOT NULL DEFAULT now(),
    fin          TIMESTAMPTZ,                     -- sin fin: sigue vigente
    CHECK (fin IS NULL OR fin >= inicio)
);

-- Monedero: solo datos para reconocer la tarjeta.
-- NUNCA se guarda el número completo ni el CVV.
CREATE TABLE monedero (
    monedero_id      INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    usuario_id       INTEGER      NOT NULL REFERENCES usuario(usuario_id) ON DELETE CASCADE,
    tipo             VARCHAR(20)  NOT NULL
                     CHECK (tipo IN ('bancaria','credito','estudiante','transporte')),
    alias            VARCHAR(50)  NOT NULL,
    titular          VARCHAR(100),
    ultimos_digitos  CHAR(4)      NOT NULL CHECK (ultimos_digitos ~ '^[0-9]{4}$'),
    caducidad        DATE                     -- primer día del mes de caducidad; opcional
);


-- ---------------------------------------------------------------------
--  3. ÍNDICES (las claves primarias y UNIQUE ya crean los suyos)
-- ---------------------------------------------------------------------

CREATE INDEX idx_viaje_linea       ON viaje (linea_id);
CREATE INDEX idx_viaje_servicio    ON viaje (servicio_id);
-- "Próximos autobuses de una parada": búsqueda por parada y hora.
CREATE INDEX idx_hora_parada       ON hora_de_paso (parada_id, hora_llegada);
CREATE INDEX idx_favorito_parada   ON favorito (parada_id);
CREATE INDEX idx_aviso_linea       ON aviso (linea_id);
CREATE INDEX idx_aviso_parada      ON aviso (parada_id);
CREATE INDEX idx_monedero_usuario   ON monedero (usuario_id);


-- ---------------------------------------------------------------------
--  4. VISTA: paradas de cada línea, por destino y en orden
--     (para la pantalla Paradas: elegir línea -> ver sus paradas)
-- ---------------------------------------------------------------------

CREATE VIEW parada_de_linea AS
SELECT  v.linea_id,
        v.destino,
        h.parada_id,
        MIN(h.orden_parada) AS orden
FROM    viaje v
JOIN    hora_de_paso h USING (viaje_id)
GROUP BY v.linea_id, v.destino, h.parada_id;
