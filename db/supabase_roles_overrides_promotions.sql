-- ════════════════════════════════════════════════════════════════
--  DTZ CATÁLOGO — Roles, Overrides y Promociones
--  Ejecutar en: Supabase → SQL Editor → New Query
--  Fecha: 2026-06-04
-- ════════════════════════════════════════════════════════════════

-- ── 1. ACTUALIZAR ROLES EN PROFILES ─────────────────────────────
-- Nuevos roles: superadmin | admin | staff
-- superadmin → Desarrollador (acceso total)
-- admin      → Dueño/Encargado (productos, promociones, logo)
-- staff      → Empleado (solo imágenes de productos)

ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_role_check;

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_role_check
  CHECK (role IN ('superadmin', 'admin', 'staff'));

-- Actualizar el trigger para que nuevos usuarios arranquen como 'staff'
-- (el superadmin los sube de rol manualmente)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
    'staff'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ⚠️  IMPORTANTE: Actualizar tu usuario actual a superadmin
-- Reemplazá 'tu-email@gmail.com' con tu email real:
-- UPDATE public.profiles SET role = 'superadmin' WHERE email = 'tu-email@gmail.com';

-- ── 2. TABLA PRODUCT_OVERRIDES ───────────────────────────────────
-- Almacena nombre y precio personalizados para el catálogo web.
-- Los imports de Odoo NO tocan esta tabla → los cambios se preservan.

CREATE TABLE IF NOT EXISTS public.product_overrides (
  code          TEXT        PRIMARY KEY,
  display_name  TEXT,
  custom_price  NUMERIC,
  updated_by    TEXT,
  updated_at    TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.product_overrides ENABLE ROW LEVEL SECURITY;

-- Lectura pública (index.html la usa para mostrar datos personalizados)
DROP POLICY IF EXISTS "Public read overrides" ON public.product_overrides;
CREATE POLICY "Public read overrides"
  ON public.product_overrides FOR SELECT
  USING (true);

-- Solo autenticados pueden escribir
DROP POLICY IF EXISTS "Auth write overrides" ON public.product_overrides;
CREATE POLICY "Auth write overrides"
  ON public.product_overrides FOR ALL
  TO authenticated
  USING (true) WITH CHECK (true);

-- ── 3. TABLA PROMOTIONS ──────────────────────────────────────────
-- Reglas de descuento por volumen: N+ productos en carrito → X% off.
-- Soporta múltiples niveles activos simultáneamente.

CREATE TABLE IF NOT EXISTS public.promotions (
  id              SERIAL      PRIMARY KEY,
  nombre          TEXT        NOT NULL,
  min_cantidad    INTEGER     NOT NULL CHECK (min_cantidad > 0),
  descuento_pct   NUMERIC(5,2) NOT NULL CHECK (descuento_pct > 0 AND descuento_pct <= 100),
  activo          BOOLEAN     DEFAULT true,
  created_at      TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.promotions ENABLE ROW LEVEL SECURITY;

-- Lectura pública (index.html la usa para calcular descuentos)
DROP POLICY IF EXISTS "Public read promotions" ON public.promotions;
CREATE POLICY "Public read promotions"
  ON public.promotions FOR SELECT
  USING (true);

-- Solo autenticados pueden gestionar
DROP POLICY IF EXISTS "Auth manage promotions" ON public.promotions;
CREATE POLICY "Auth manage promotions"
  ON public.promotions FOR ALL
  TO authenticated
  USING (true) WITH CHECK (true);

-- ════════════════════════════════════════════════════════════════
--  VERIFICACIÓN
--  Después de ejecutar, correr:
--  SELECT * FROM public.profiles;
--  → Confirmar que tu usuario tiene role = 'superadmin'
-- ════════════════════════════════════════════════════════════════
