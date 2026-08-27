-- =========================================================================
-- SCRIPT DE AUDITORIA Y SEGURIDAD RLS
-- Ejecutar en Supabase -> SQL Editor -> New Query
-- Propósito: Cerrar vulnerabilidades críticas de acceso a datos.
-- =========================================================================

-- 1. ELIMINAR TRIGGER DE AUTO-CREACIÓN DE PERFILES
-- Peligro: Si un hacker usaba la API de Supabase para registrarse, el trigger 
-- le asignaba automáticamente el rol de 'staff', dándole acceso al panel.
-- Solución: Borramos el trigger. Ahora solo el Admin puede crear perfiles explícitamente.
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 2. BLOQUEAR ESCALADA DE PRIVILEGIOS EN 'profiles'
-- Peligro: La política anterior permitía a cualquier usuario logueado editar su propio perfil (y su rol).
DROP POLICY IF EXISTS "Authenticated can insert profiles" ON public.profiles;
DROP POLICY IF EXISTS "Authenticated can update profiles" ON public.profiles;

CREATE POLICY "Admins can insert profiles"
  ON public.profiles FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('admin', 'superadmin'));

-- (La política de Update para Admins ya la habíamos creado en un script anterior, pero aseguramos).

-- 3. ASEGURAR LA TABLA PRODUCTOS
-- Peligro: Si 'productos' no tenía RLS, un atacante podía vaciar el catálogo entero.
ALTER TABLE public.productos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can read products" ON public.productos;
CREATE POLICY "Public can read products"
  ON public.productos FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Admins can modify products" ON public.productos;
CREATE POLICY "Admins can modify products"
  ON public.productos FOR ALL
  TO authenticated
  USING ((SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('admin', 'superadmin'))
  WITH CHECK ((SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('admin', 'superadmin'));

-- 4. ASEGURAR DATOS SENSIBLES EN REPARACIONES
-- Peligro: Antes, CUALQUIER usuario logueado podía ver nombres, teléfonos y pines de clientes.
DROP POLICY IF EXISTS "Acceso total a reparaciones para usuarios autenticados" ON public.reparaciones;

CREATE POLICY "Solo personal autorizado puede gestionar reparaciones"
  ON public.reparaciones FOR ALL
  TO authenticated
  USING ((SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('staff', 'admin', 'superadmin'))
  WITH CHECK ((SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('staff', 'admin', 'superadmin'));

-- 5. ASEGURAR PEDIDOS DE STOCK
DROP POLICY IF EXISTS "Permitir lectura autenticados pedidos" ON public.pedidos_stock;
DROP POLICY IF EXISTS "Permitir insercion autenticados pedidos" ON public.pedidos_stock;
DROP POLICY IF EXISTS "Permitir actualizacion autenticados pedidos" ON public.pedidos_stock;
DROP POLICY IF EXISTS "Permitir eliminacion autenticados pedidos" ON public.pedidos_stock;

CREATE POLICY "Solo personal autorizado puede gestionar pedidos"
  ON public.pedidos_stock FOR ALL
  TO authenticated
  USING ((SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('staff', 'admin', 'superadmin'))
  WITH CHECK ((SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('staff', 'admin', 'superadmin'));
