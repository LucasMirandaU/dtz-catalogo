-- ========================================================================================
-- Script de Optimización de Memoria, Consultas e Índices
-- Ejecutar en Supabase -> SQL Editor
-- ========================================================================================

-- 1. Optimización de índices para mejorar la velocidad en pantallas de alto tráfico
CREATE INDEX IF NOT EXISTS idx_reparaciones_fecha ON public.reparaciones(fecha_ingreso DESC);
CREATE INDEX IF NOT EXISTS idx_pedidos_estado ON public.pedidos_stock(estado);
CREATE INDEX IF NOT EXISTS idx_audit_created ON public.audit_log(created_at DESC);

-- 2. Refactorización y limpieza de caché de políticas de acceso (Profiles)
-- Se eliminan reglas generales ineficientes
DROP POLICY IF EXISTS "Authenticated can read profiles" ON public.profiles;
DROP POLICY IF EXISTS "Authenticated can update profiles" ON public.profiles;
DROP POLICY IF EXISTS "Authenticated can insert profiles" ON public.profiles;

-- Se establecen rutas directas de indexación (Seguridad integrada)
CREATE POLICY "Optimized read own profile" ON public.profiles
  FOR SELECT TO authenticated USING (auth.uid() = id);

CREATE POLICY "Optimized read all profiles" ON public.profiles
  FOR SELECT TO authenticated 
  USING ((SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('admin', 'superadmin'));

-- 3. Refactorización de memoria en módulo Reparaciones
DROP POLICY IF EXISTS "Acceso total a reparaciones para usuarios autenticados" ON public.reparaciones;

CREATE POLICY "Optimized access to reparaciones" ON public.reparaciones
  FOR ALL TO authenticated
  USING ( (SELECT active FROM public.profiles WHERE id = auth.uid()) = true )
  WITH CHECK ( (SELECT active FROM public.profiles WHERE id = auth.uid()) = true );

-- 4. Refactorización de memoria en módulo Pedidos
DROP POLICY IF EXISTS "Permitir lectura autenticados pedidos" ON public.pedidos_stock;
DROP POLICY IF EXISTS "Permitir insercion autenticados pedidos" ON public.pedidos_stock;
DROP POLICY IF EXISTS "Permitir actualizacion autenticados pedidos" ON public.pedidos_stock;
DROP POLICY IF EXISTS "Permitir eliminacion autenticados pedidos" ON public.pedidos_stock;

CREATE POLICY "Optimized access to pedidos" ON public.pedidos_stock
  FOR ALL TO authenticated
  USING ( (SELECT active FROM public.profiles WHERE id = auth.uid()) = true )
  WITH CHECK ( (SELECT active FROM public.profiles WHERE id = auth.uid()) = true );
