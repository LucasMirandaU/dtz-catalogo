-- ════════════════════════════════════════════════════════════════
--  DTZ CATÁLOGO — Permisos de Usuarios (RLS)
--  Ejecutar en: Supabase → SQL Editor → New Query
--  Propósito: Permite que los Admins puedan borrar a otros usuarios
-- ════════════════════════════════════════════════════════════════

-- 1. Permitir a Admins y Superadmins borrar perfiles (dar de baja usuarios)
DROP POLICY IF EXISTS "Admins can delete profiles" ON public.profiles;
CREATE POLICY "Admins can delete profiles"
  ON public.profiles FOR DELETE
  TO authenticated
  USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('admin', 'superadmin')
  );

-- 2. Permitir a Admins y Superadmins actualizar perfiles (cambiar roles de otros)
DROP POLICY IF EXISTS "Admins can update profiles" ON public.profiles;
CREATE POLICY "Admins can update profiles"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('admin', 'superadmin')
  );
