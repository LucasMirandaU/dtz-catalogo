-- Migración para agregar la columna 'fecha' a la tabla 'reparaciones'

ALTER TABLE public.reparaciones 
ADD COLUMN IF NOT EXISTS fecha date DEFAULT CURRENT_DATE;

-- Opcional: comentar la columna para mantener la documentación de la base de datos
COMMENT ON COLUMN public.reparaciones.fecha IS 'Fecha de ingreso de la reparación (automática por defecto)';
