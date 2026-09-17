-- ════════════════════════════════════════════════════════════════
--  DTZ CATÁLOGO — Tabla de Auditoría
--  Ejecutar en: Supabase → SQL Editor → New Query
-- ════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.audit_log (
  id              SERIAL       PRIMARY KEY,
  created_at      TIMESTAMPTZ  DEFAULT now(),
  user_email      TEXT         NOT NULL,
  user_name       TEXT,
  user_role       TEXT,
  action_type     TEXT         NOT NULL,
  entity_code     TEXT,
  entity_name     TEXT,
  detalle         TEXT
);

ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

-- Solo usuarios autenticados pueden leer y escribir
DROP POLICY IF EXISTS "Auth manage audit_log" ON public.audit_log;
CREATE POLICY "Auth manage audit_log"
  ON public.audit_log FOR ALL
  TO authenticated
  USING (true) WITH CHECK (true);

-- Recargar schema
NOTIFY pgrst, 'reload schema';

-- ════════════════════════════════════════════════════════════════
--  Tipos de acción registrados (action_type):
--  IMAGEN_SUBIR      — Se subió imagen de producto
--  IMAGEN_ELIMINAR   — Se eliminó imagen de producto
--  OVERRIDE_GUARDAR  — Se guardó nombre/precio web personalizado
--  OVERRIDE_ELIMINAR — Se eliminó override (vuelve a datos Odoo)
--  PROMO_CREAR       — Se creó una promoción
--  PROMO_ACTIVAR     — Se activó/pausó una promoción
--  PROMO_ELIMINAR    — Se eliminó una promoción
--  BANNER_SUBIR      — Se subió un banner
--  BANNER_ACTIVAR    — Se activó/pausó un banner
--  BANNER_ELIMINAR   — Se eliminó un banner
--  LOGO_CAMBIAR      — Se actualizó el logo
--  LOGO_ELIMINAR     — Se eliminó el logo
--  USUARIO_CREAR     — Se creó un usuario
--  USUARIO_ROL       — Se cambió el rol de un usuario
-- ════════════════════════════════════════════════════════════════
