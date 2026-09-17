-- =========================================================================
-- SCRIPT 05: Actualización del Módulo de Taller (v1.0.0)
-- Descripción: Agrega campos nuevos (dni, checkboxes, trabajo realizado)
-- y ajusta el Nro de Orden para que arranque desde el 101.
-- =========================================================================

-- 1. Eliminar la columna 'nro_orden' (ya no es manual)
ALTER TABLE reparaciones 
DROP COLUMN IF EXISTS nro_orden;

-- 2. Agregar nuevas columnas
ALTER TABLE reparaciones 
ADD COLUMN IF NOT EXISTS dni TEXT DEFAULT '',
ADD COLUMN IF NOT EXISTS chk_sin_bateria BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS chk_rajado BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS chk_mojado BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS trabajo_realizado TEXT DEFAULT '';

-- 3. Reiniciar la secuencia de ID para que el próximo equipo ingresado sea el #101
-- Nota: Esto asume que el ID más alto actual es menor a 101. 
-- Si ya tenés IDs mayores a 101, esto podría dar error de llave duplicada al insertar. 
-- En ese caso, cambialo por un número mayor a tu ID máximo.
ALTER SEQUENCE reparaciones_id_seq RESTART WITH 101;
