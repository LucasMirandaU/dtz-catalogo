-- ========================================================================================
-- Script Hotfix RLS (Reparaciones y Pedidos)
-- Ejecutar en Supabase -> SQL Editor
-- ========================================================================================

-- El campo "active" puede ser NULL en usuarios viejos, lo que bloquea UPDATE y DELETE.
-- Usaremos una verificación más segura: que el perfil exista en la base de datos.

DROP POLICY IF EXISTS "Optimized access to reparaciones" ON public.reparaciones;
CREATE POLICY "Optimized access to reparaciones" ON public.reparaciones
  FOR ALL TO authenticated
  USING ( EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid()) )
  WITH CHECK ( EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid()) );

DROP POLICY IF EXISTS "Optimized access to pedidos" ON public.pedidos_stock;
CREATE POLICY "Optimized access to pedidos" ON public.pedidos_stock
  FOR ALL TO authenticated
  USING ( EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid()) )
  WITH CHECK ( EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid()) );
