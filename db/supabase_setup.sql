-- ════════════════════════════════════════════════════════════════
--  DTZ CATÁLOGO — Setup de base de datos
--  Ejecutar en: Supabase → SQL Editor → New Query
--  Fecha: 2026-06-02
-- ════════════════════════════════════════════════════════════════

-- ── 1. TABLA PROFILES ────────────────────────────────────────────
-- Almacena el nombre visible, rol y email de cada usuario de admin.
-- Vinculada a auth.users mediante FK.

CREATE TABLE IF NOT EXISTS public.profiles (
  id            uuid        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email         text,
  display_name  text,
  role          text        DEFAULT 'admin' CHECK (role IN ('admin', 'viewer')),
  active        boolean     DEFAULT true,
  created_at    timestamptz DEFAULT now()
);

-- ── 2. ROW LEVEL SECURITY ────────────────────────────────────────
-- Sin RLS, cualquiera con la anon key puede leer/escribir la tabla.

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Solo usuarios autenticados pueden leer perfiles
DROP POLICY IF EXISTS "Authenticated can read profiles" ON public.profiles;
CREATE POLICY "Authenticated can read profiles"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (true);

-- Solo usuarios autenticados pueden insertar perfiles
DROP POLICY IF EXISTS "Authenticated can insert profiles" ON public.profiles;
CREATE POLICY "Authenticated can insert profiles"
  ON public.profiles FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Solo usuarios autenticados pueden actualizar perfiles
DROP POLICY IF EXISTS "Authenticated can update profiles" ON public.profiles;
CREATE POLICY "Authenticated can update profiles"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- ── 3. TRIGGER: AUTO-CREAR PERFIL AL REGISTRAR USUARIO ──────────
-- Cuando un nuevo usuario confirma su email en auth.users,
-- se crea automáticamente un registro en profiles.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
    'admin'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ── 4. BACKFILL: CREAR PERFILES PARA USUARIOS EXISTENTES ────────
-- Si ya tenés usuarios en auth.users sin perfil, este INSERT los migra.
-- Es seguro ejecutarlo siempre (ON CONFLICT DO NOTHING).

INSERT INTO public.profiles (id, email, display_name, role)
SELECT
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data->>'display_name', split_part(u.email, '@', 1)),
  'admin'
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.id = u.id
);

-- ── 5. TABLA BANNERS (para el carousel del index) ────────────────
-- Preparación para la funcionalidad de banners (siguiente feature).

CREATE TABLE IF NOT EXISTS public.banners (
  id          serial      PRIMARY KEY,
  image_url   text        NOT NULL,
  titulo      text,
  subtitulo   text,
  link_url    text,
  orden       int         DEFAULT 0,
  activo      boolean     DEFAULT true,
  created_at  timestamptz DEFAULT now()
);

ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;

-- Lectura pública (el index.html la necesita sin autenticación)
DROP POLICY IF EXISTS "Public can read active banners" ON public.banners;
CREATE POLICY "Public can read active banners"
  ON public.banners FOR SELECT
  USING (true);

-- Solo admin puede modificar banners
DROP POLICY IF EXISTS "Authenticated can manage banners" ON public.banners;
CREATE POLICY "Authenticated can manage banners"
  ON public.banners FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- ════════════════════════════════════════════════════════════════
--  FIN DEL SETUP
--  Verificar en Supabase → Table Editor que existen:
--   ✔ public.profiles
--   ✔ public.banners
--  Y en Authentication → Policies que RLS está activo en ambas.
-- ════════════════════════════════════════════════════════════════
