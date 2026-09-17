-- ==============================================================================
-- MIGRACIÓN v1.3.0: SISTEMA DE DESCUENTOS (RPC) Y TARIFARIO DE TALLER
-- Ejecutar este script en el SQL Editor de Supabase
-- ==============================================================================

-- 1. TABLA DE DESCUENTOS (CUPONES)
CREATE TABLE IF NOT EXISTS public.descuentos (
    id BIGSERIAL PRIMARY KEY,
    codigo TEXT UNIQUE NOT NULL,
    nombre TEXT NOT NULL,
    porcentaje NUMERIC NOT NULL,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habilitar RLS en descuentos
ALTER TABLE public.descuentos ENABLE ROW LEVEL SECURITY;

-- Política: Solo Administradores y Superadmins pueden gestionar o listar los cupones en la tabla
DROP POLICY IF EXISTS "Admins can manage descuentos" ON public.descuentos;
CREATE POLICY "Admins can manage descuentos" ON public.descuentos
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE profiles.id = auth.uid() 
        AND profiles.role IN ('admin', 'superadmin')
    )
);

-- 2. FUNCIÓN SECRETA RPC PARA VALIDAR CUPÓN (SECURITY DEFINER)
-- Bypassea RLS solo para consultar si el código exacto existe y está activo, devolviendo JSON
CREATE OR REPLACE FUNCTION public.validar_cupon(codigo_input TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    res JSON;
BEGIN
    SELECT json_build_object(
        'valido', true,
        'porcentaje', porcentaje,
        'nombre', nombre,
        'codigo', codigo
    )
    INTO res
    FROM public.descuentos
    WHERE upper(trim(codigo)) = upper(trim(codigo_input))
      AND activo = true
    LIMIT 1;

    IF res IS NULL THEN
        RETURN json_build_object('valido', false);
    END IF;

    RETURN res;
END;
$$;



-- 3. COLUMNA PARA CHECKLIST DETALLADO DE HARDWARE (2 COLUMNAS) EN REPARACIONES
ALTER TABLE IF EXISTS public.reparaciones ADD COLUMN IF NOT EXISTS inspeccion_hw JSONB;

-- 4. TABLA DE PRECIOS RÁPIDOS DE TALLER
CREATE TABLE IF NOT EXISTS public.precios_taller (
    id BIGSERIAL PRIMARY KEY,
    categoria TEXT NOT NULL,
    servicio TEXT NOT NULL,
    precio NUMERIC NOT NULL,
    orden INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habilitar RLS en precios_taller
ALTER TABLE public.precios_taller ENABLE ROW LEVEL SECURITY;

-- Política de lectura pública (para que el Staff y los técnicos en mostrador puedan leer)
DROP POLICY IF EXISTS "Anyone can read precios_taller" ON public.precios_taller;
CREATE POLICY "Anyone can read precios_taller" ON public.precios_taller
FOR SELECT USING (true);

-- Política de modificación solo para Admins/Superadmins
DROP POLICY IF EXISTS "Admins can manage precios_taller" ON public.precios_taller;
CREATE POLICY "Admins can manage precios_taller" ON public.precios_taller
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE profiles.id = auth.uid() 
        AND profiles.role IN ('admin', 'superadmin')
    )
);

-- Insertar datos iniciales de ejemplo en precios_taller
INSERT INTO public.precios_taller (categoria, servicio, precio, orden)
VALUES
    ('SAM / MOTO / REDMI', 'Limpieza Pin de Carga', 20000, 10),
    ('SAM / MOTO / REDMI', 'Limpieza General', 30000, 20),
    ('SAM / MOTO / REDMI', 'Cambio de Placa de carga', 45000, 30),
    ('IPHONE', 'Limpieza Pin de Carga', 25000, 40),
    ('IPHONE', 'Limpieza General (desarme de equipo)', 35000, 50),
    ('IPHONE', 'Cambio de Placa de carga', 60000, 60)
ON CONFLICT DO NOTHING;
