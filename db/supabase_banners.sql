-- ════════════════════════════════════════════════════════════════
--  DTZ CATÁLOGO — Tabla de Banners para el Carousel
--  Ejecutar en: Supabase → SQL Editor → New Query
-- ════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.banners (
  id          SERIAL       PRIMARY KEY,
  img_url     TEXT         NOT NULL,
  link_url    TEXT,
  titulo      TEXT,
  subtitulo   TEXT,
  orden       INTEGER      DEFAULT 0,
  activo      BOOLEAN      DEFAULT true,
  created_at  TIMESTAMPTZ  DEFAULT now()
);

ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;

-- Lectura pública (index.html lo necesita)
DROP POLICY IF EXISTS "Public read banners" ON public.banners;
CREATE POLICY "Public read banners"
  ON public.banners FOR SELECT
  USING (true);

-- Solo autenticados pueden gestionar
DROP POLICY IF EXISTS "Auth manage banners" ON public.banners;
CREATE POLICY "Auth manage banners"
  ON public.banners FOR ALL
  TO authenticated
  USING (true) WITH CHECK (true);

-- Bucket: reusar 'imagenes-productos' que ya existe
-- Las imágenes de banners se guardan ahí con prefijo 'banner-'

-- ════════════════════════════════════════════════════════════════
--  DIMENSIONES RECOMENDADAS PARA LOS BANNERS:
--  Desktop: 1200 × 400 px  (ratio 3:1)
--  Peso máximo: 500 KB por imagen (JPG o WEBP)
-- ════════════════════════════════════════════════════════════════
