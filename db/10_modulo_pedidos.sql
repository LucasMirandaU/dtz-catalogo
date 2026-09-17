-- ========================================================================================
-- Script de Creación del Módulo de Pedidos y Faltantes (Reemplazo Word)
-- Rama: feature/pedidos-stock
-- ========================================================================================

CREATE TABLE IF NOT EXISTS pedidos_stock (
    id bigserial PRIMARY KEY,
    created_at timestamptz DEFAULT now(),
    sucursal text NOT NULL, -- 'Local 1912' o 'Local 2984'
    marca text NOT NULL, -- 'FALTANTES AMBOS LOCALES', 'IPHONE', 'SAMSUNG', 'MOTOROLA', 'XIAOMI', 'VARIOS'
    tipo text NOT NULL, -- 'Funda', 'Templado Común', 'Templado Privado', 'Cable', 'Cargador', 'Insumo', 'Otro'
    variante text, -- 'Rígida', 'Silicona', 'Space', 'MagSafe', 'Antishock', 'Silicon Case', 'Con Soporte', 'Simil Metal', 'New Skin', 'N/A'
    detalle_libre text, -- Ej: 'A20 negra azul' o detalle específico
    cliente_nombre text,
    cliente_telefono text,
    estado text DEFAULT 'Pendiente' -- 'Pendiente', 'Recibido'
);

-- Habilitar RLS
ALTER TABLE pedidos_stock ENABLE ROW LEVEL SECURITY;

-- Políticas de RLS
-- Permitir acceso a cualquier usuario autenticado (Staff/Admin)
CREATE POLICY "Permitir lectura autenticados pedidos"
ON pedidos_stock FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Permitir insercion autenticados pedidos"
ON pedidos_stock FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Permitir actualizacion autenticados pedidos"
ON pedidos_stock FOR UPDATE
TO authenticated
USING (true);

CREATE POLICY "Permitir eliminacion autenticados pedidos"
ON pedidos_stock FOR DELETE
TO authenticated
USING (true);
