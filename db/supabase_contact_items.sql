-- ════════════════════════════════════════════════════════════════
--  DTZ CATÁLOGO — Tabla de Contacto (barra superior)
--  Ejecutar en: Supabase → SQL Editor → New Query
-- ════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.contact_items (
  id         SERIAL       PRIMARY KEY,
  icono      TEXT         NOT NULL DEFAULT '📍',
  texto      TEXT         NOT NULL,
  link_url   TEXT,
  orden      INTEGER      DEFAULT 0,
  activo     BOOLEAN      DEFAULT true,
  created_at TIMESTAMPTZ  DEFAULT now()
);

ALTER TABLE public.contact_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read contact_items" ON public.contact_items;
CREATE POLICY "Public read contact_items"
  ON public.contact_items FOR SELECT USING (true);

DROP POLICY IF EXISTS "Auth manage contact_items" ON public.contact_items;
CREATE POLICY "Auth manage contact_items"
  ON public.contact_items FOR ALL
  TO authenticated USING (true) WITH CHECK (true);

-- Datos iniciales (los que estaban hardcodeados)
INSERT INTO public.contact_items (icono, texto, link_url, orden, activo) VALUES
  ('📍', 'San Juan 2984, Rosario', null,                                          0, true),
  ('📱', '3416 60-8662',           'tel:+5493416608662',                          1, true),
  ('📍', 'San Juan 1912, Rosario', null,                                          2, true),
  ('📱', '341 328-1697',           'tel:+5493413281697',                          3, true),
  ('📸', '@DTZ.SERVICIOTECNICO',   'https://instagram.com/DTZ.SERVICIOTECNICO',   4, true);

NOTIFY pgrst, 'reload schema';

-- ════════════════════════════════════════════════════════════════
--  Consejos:
--  - Icono: cualquier emoji (📍📱📸🌐📧 etc.)
--  - Link URL: opcional. Si lo dejás vacío, el texto no es clickeable.
--  - Para teléfono: link = tel:+549XXXXXXXXX
--  - Para Instagram: link = https://instagram.com/usuario
--  - Para WhatsApp: link = https://wa.me/549XXXXXXXXX
-- ════════════════════════════════════════════════════════════════
