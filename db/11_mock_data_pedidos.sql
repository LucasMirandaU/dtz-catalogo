-- ========================================================================================
-- Script para generar ejemplos de prueba (Módulo Pedidos)
-- Instrucción: Correr en el SQL Editor de Supabase
-- ========================================================================================

INSERT INTO pedidos_stock (sucursal, marca, tipo, variante, detalle_libre, cliente_nombre, cliente_telefono, estado) VALUES
-- FALTANTES AMBOS LOCALES (7 items)
('Local 1912', 'FALTANTES AMBOS LOCALES', 'Insumo', 'N/A', 'Cinta doble faz fina', NULL, NULL, 'Pendiente'),
('Local 2984', 'FALTANTES AMBOS LOCALES', 'Cargador', 'N/A', 'Fuxo 20W tipo C', NULL, NULL, 'Pendiente'),
('Local 1912', 'FALTANTES AMBOS LOCALES', 'Cable', 'N/A', 'Tipo C a Lightning', NULL, NULL, 'Pendiente'),
('Local 2984', 'FALTANTES AMBOS LOCALES', 'Templado Común', 'N/A', 'Genérico para iPhone 11', NULL, NULL, 'Pendiente'),
('Local 1912', 'FALTANTES AMBOS LOCALES', 'Insumo', 'N/A', 'Pegamento T7000', NULL, NULL, 'Pendiente'),
('Local 2984', 'FALTANTES AMBOS LOCALES', 'Aro de Luz', 'Con Soporte', '12 pulgadas', NULL, NULL, 'Pendiente'),
('Local 1912', 'FALTANTES AMBOS LOCALES', 'Insumo', 'N/A', 'Alcohol Isopropílico', NULL, NULL, 'Pendiente'),

-- LOCAL 1912 (10 items)
('Local 1912', 'SAMSUNG', 'Funda', 'Silicon Case', 'A23 color rojo', 'Juan Pérez', '341 358 9446', 'Pendiente'),
('Local 1912', 'SAMSUNG', 'Funda', 'Antishock', 'S21 FE transparente', 'María', '341 222 3333', 'Pendiente'),
('Local 1912', 'IPHONE', 'Funda', 'MagSafe', '13 Pro transparente', 'Lucas', NULL, 'Pendiente'),
('Local 1912', 'IPHONE', 'Templado Privado', 'N/A', 'iPhone 14', 'Griselda', '3757609851', 'Pendiente'),
('Local 1912', 'MOTOROLA', 'Funda', 'Space', 'Moto G52 / G82', 'Liliana', '3413935306', 'Pendiente'),
('Local 1912', 'MOTOROLA', 'Templado Común', 'N/A', 'Edge 30 Neo', NULL, NULL, 'Pendiente'),
('Local 1912', 'XIAOMI', 'Funda', 'New Skin', 'Redmi Note 12 4G', 'Fernando', '341 wsp', 'Pendiente'),
('Local 1912', 'VARIOS', 'Cable', 'N/A', 'HDMI a RCA', NULL, NULL, 'Pendiente'),
('Local 1912', 'SAMSUNG', 'Funda', 'Rígida', 'A20 negra azul', 'Liliana', '3413935306', 'Pendiente'),
('Local 1912', 'XIAOMI', 'Templado Común', 'N/A', 'Redmi Note 13 Pro 5G', NULL, NULL, 'Recibido'), 

-- LOCAL 2984 (10 items)
('Local 2984', 'IPHONE', 'Funda', 'Silicon Case', 'iPhone 11 Lila', 'Martina', '341 555 7777', 'Pendiente'),
('Local 2984', 'SAMSUNG', 'Funda', 'Simil Metal', 'S23 Ultra negra', 'Carlos', '341 999 8888', 'Pendiente'),
('Local 2984', 'MOTOROLA', 'Funda', 'Con Soporte', 'Moto G200', 'Roberto', '341 444 2222', 'Pendiente'),
('Local 2984', 'SAMSUNG', 'Templado Privado', 'N/A', 'A54', 'Julieta', NULL, 'Pendiente'),
('Local 2984', 'XIAOMI', 'Funda', 'Antishock', 'Poco X5 Pro', NULL, NULL, 'Pendiente'),
('Local 2984', 'IPHONE', 'Templado Común', 'N/A', 'iPhone 12 Mini', 'Gastón', '341 111 2222', 'Pendiente'),
('Local 2984', 'VARIOS', 'Cargador', 'N/A', 'Cargador V8 genérico', NULL, NULL, 'Pendiente'),
('Local 2984', 'SAMSUNG', 'Funda', 'Silicona', 'Note 8 azul o roja', 'Jorge', NULL, 'Pendiente'),
('Local 2984', 'MOTOROLA', 'Templado Común', 'N/A', 'Moto E22', NULL, NULL, 'Pendiente'),
('Local 2984', 'IPHONE', 'Funda', 'MagSafe', 'iPhone 15 Pro Max', 'Sofía', '341 777 6666', 'Pendiente'),

-- RECIBIDOS EXTRAS (5 items)
('Local 1912', 'IPHONE', 'Cable', 'N/A', 'Lightning original', 'Marta', '341 888 1111', 'Recibido'),
('Local 2984', 'SAMSUNG', 'Templado Común', 'N/A', 'A14 5G', NULL, NULL, 'Recibido'),
('Local 1912', 'MOTOROLA', 'Funda', 'Silicon Case', 'Moto E13 verde', 'Andrés', NULL, 'Recibido'),
('Local 2984', 'XIAOMI', 'Funda', 'Space', 'Redmi Note 11', 'Lorena', '341 222 9999', 'Recibido'),
('Local 1912', 'VARIOS', 'Insumo', 'N/A', 'Malla Apple Watch 42mm negra', 'Esteban', NULL, 'Recibido');
