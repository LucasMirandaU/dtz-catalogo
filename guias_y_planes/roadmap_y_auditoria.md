# Historial de Desarrollo y Auditoría — WebDTZ

Este documento detalla la evolución arquitectónica del proyecto, el plan de funcionalidades implementado y la auditoría de seguridad realizada antes del pase a producción.

---

## 1. Auditoría de Seguridad (Aprobada ✅)

El sistema fue diseñado bajo una arquitectura **Backend-First**, delegando la seguridad de los datos al motor de base de datos PostgreSQL a través de Supabase.

- [x] **Gestión de Claves API:** Exposición exclusiva de la `anon_key` pública en el frontend (`config.js`). Uso 100% seguro y estándar para SPA (Single Page Applications).
- [x] **Archivos Sensibles Protegidos:** Archivos SQL de migración y guías internas gestionados mediante `.gitignore` para evitar fugas de información estructural.
- [x] **Políticas RLS (Row Level Security):** Inserciones, actualizaciones y borrados en las tablas de `productos`, `banners`, `promotions` y `profiles` bloqueadas a nivel de base de datos. Solo accesibles mediante tokens JWT firmados de usuarios con rol de administrador.
- [x] **Protección de Datos Personales:** Cero contraseñas o tokens hardcodeados en el código fuente.

---

## 2. Checklist de Funcionalidades (Roadmap Ejecutado)

A continuación, el registro de las funcionalidades planificadas y su estado de ejecución. Todo el desarrollo se orientó a minimizar dependencias y maximizar la velocidad de carga (Vanilla JS).

### 👥 Autenticación y Roles
- [x] Login seguro con email y contraseña (Supabase Auth).
- [x] Gestión de Perfiles (`profiles`) vinculados a `auth.users`.
- [x] Sistema de Roles jerárquico: `Superadmin`, `Admin` y `Staff`.
- [x] Navegación dinámica en el panel (renderizado de tabs según rol).
- [x] Funciones exclusivas de Superadmin (creación de nuevos usuarios).

### 📦 Integración y Catálogo
- [x] Importación masiva (Drag & Drop) desde archivos `.xlsx` nativos de Odoo.
- [x] Lectura de datos resiliente (mapeo dinámico de columnas del Excel).
- [x] Validación cruzada (productos sin código, sin precio, sin stock).
- [x] Visualización de productos con filtros dinámicos y paginación (50 por vista).
- [x] Sistema de *Overrides* (Modificadores): permite alterar precios y nombres para la web sin modificar el ERP Odoo.

### 🛒 Flujo de Compra y WhatsApp
- [x] Carrito de compras reactivo (estado gestionado en el DOM).
- [x] Persistencia del carrito en `localStorage` (sobrevive al cierre del navegador).
- [x] Sistema de promociones por volumen de compra (auto-aplicables).
- [x] Elección de sucursal de retiro en el checkout.
- [x] Formateo automático del pedido y envío directo a la API de WhatsApp.

### 🖼️ UI/UX y Multimedia
- [x] Carrusel de banners dinámico con auto-rotación y gestos táctiles (Swipe).
- [x] Lightbox (Modal de imagen a pantalla completa) para productos en el catálogo público, con soporte nativo de zoom.
- [x] Barra superior de contacto completamente autogestionable desde el admin.
- [x] Carga y compresión de imágenes optimizada. Límite de 1.5MB por subida de banner para proteger la cuota de la DB.
- [x] Memoria caché inteligente para carga inmediata de Logos y Perfiles de usuario (Prevención de FOUC - Flash of Unstyled Content).

### 📊 Auditoría y Registro
- [x] Tabla de auditoría (`audit_log`) inmutable para registrar todas las acciones realizadas en el panel de administración.
- [x] Opción de exportación de registros a Excel.

### 🛠️ Módulo de Taller y Reparaciones (v1.1.0)
- [x] Desarrollo de un micro-sistema independiente (`reparaciones.html`) para la gestión de ingresos y servicio técnico.
- [x] Arquitectura de base de datos aislada (`reparaciones`) con RLS estricto para protección de datos de clientes y credenciales de dispositivos.
- [x] Implementación de historial de pagos parciales utilizando estructuras `JSONB`, minimizando latencia y operaciones relacionales (JOINs).
- [x] **Flujo Rápido (Seña):** Capacidad de registrar señas/adelantos iniciales de forma directa al crear una orden.
- [x] Estados de orden predefinidos (incluyendo cancelación) con cálculo en tiempo real del saldo deudor.
- [x] **Checklist Extendido:** 8 parámetros de revisión preestablecidos para agilizar recepciones y evitar reclamos (Bandeja SIM, Cámaras, etc.).
- [x] Generación nativa de comprobantes en PDF listos para impresión/WhatsApp, incluyendo textos legales y términos de servicio automatizados.
### 🛠️ Módulo de Taller, Catálogo e ImgBB (v1.2.0)
- [x] **Migración ImgBB:** Reemplazo de subida de imágenes a Supabase Storage por la API de ImgBB mediante `uploadToImgBB()`, eliminando límites de cuota de almacenamiento.
- [x] **Compresión Inteligente WebP:** Compresión automática en el navegador antes de subir (800px para catálogo, 600px para taller) optimizando velocidad de carga y ancho de banda.
- [x] **Ocultar Productos:** Nuevo toggle de visibilidad (`oculto`) en `product_overrides` con botón de ojo (`👁️`/`🙈`) en `admin.html` y filtrado en `index.html`.
- [x] **📸 Fotos en Taller:** Soporte para adjuntar hasta 3 fotografías por orden de reparación, persistidas en columna JSONB `fotos`.
- [x] **🖨️ PDF en 1 Sola Carilla:** Rediseño del CSS de impresión (`@media print`) para incluir miniaturas de fotos y legales del remito en una sola página.
- [x] **🗑️ Eliminar Reparaciones con Seguridad de Roles:** Botón de borrado con confirmación de seguridad, estrictamente limitado a roles `Admin` y `Superadmin` (rol `Staff` bloqueado).
### 🎁 Promociones, Cupones y Mejoras Taller (v1.3.0)
- [x] **Gestión de Descuentos (Cupones):** Nueva pestaña en el panel Admin para crear, activar, pausar y eliminar códigos de descuento en porcentaje.
- [x] **RPC de Validación Segura (`validar_cupon`):** El carrito consulta la validez del cupón sin exponer la tabla en el frontend (`anon_key`), manteniendo RLS privado.
- [x] **Regla de No Acumulabilidad (UX Nivel Dios):** Comparación automática entre promociones por volumen y cupones de descuento, aplicando el beneficio más alto.
- [x] **Tarifario Rápido de Taller:** Nueva tabla `precios_taller` gestionable por Admins y de lectura rápida para el Staff.
- [x] **⚡ Autocompletado en Recepción:** Select en creación/edición de reparaciones para cargar precios y autocompletar descripciones de servicios al instante.
- [x] **📋 Checklist Detallado de Hardware (2 Columnas):** Reducción del ingreso rápido a 3 estados críticos (Sin Batería, Rajado, Mojado) y agregado de inspección exhaustiva de 11 componentes (Tapa, Batería, Cámaras, SIM, Pin, Biometría, Display, Audio, Micrófono) guardados en JSONB `inspeccion_hw`.
- [x] **Flujo Oficial de Estados DTZ:** Sincronización del ciclo de vida de reparaciones (`Ingresado / En Revisión`, `Presupuestado / Esperando Confirmación`, `Reparando`, etc.).

---

*Fin del documento de auditoría.*
