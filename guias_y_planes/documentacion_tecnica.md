# 🛠️ Documentación Técnica - Catálogo DTZ

Esta documentación es exclusiva para el desarrollador del proyecto.

## Stack y Arquitectura
*   **Frontend:** HTML5 + CSS3 + Vanilla JS (Sin frameworks pesados, enfoque 100% en First Contentful Paint).
*   **Backend/DB:** Supabase (PostgreSQL + Auth + Storage).
*   **Hosting:** GitHub Pages con dominio propio delegado vía Cloudflare DNS.
*   **Flujo de Datos:** Odoo → Excel → importación JS (`admin.html`) → Supabase → Frontend (`index.html`).

## Seguridad — Puntos Críticos

### 1. Manejo de Keys
*   En `config.js` solo se expone la `anon_key` pública.
*   La `service_role_key` jamás debe exponerse, ya que bypasea el RLS (Row Level Security).

### 2. Row Level Security (RLS) en PostgreSQL
La seguridad está delegada al motor SQL:
*   Tabla `productos` y `banners`: `SELECT` público. `INSERT/UPDATE/DELETE` restringido por token JWT de administrador.
*   Tabla `auditoria`: Solo lectura/escritura interna.

### 3. Protección de Sesión en `admin.html`
Al inicializar, se verifica `supabase.auth.getSession()`. Si es null, bloquea la carga del DOM y renderiza la pantalla de Login forzando la autenticación.

## Base de Datos y Resiliencia (Mapeo Odoo)

Para evitar que cambios en los encabezados del Excel de Odoo rompan el sistema, se implementó un objeto `COLUMN_MAP` en el importador JS.

```javascript
const COLUMN_MAP = {
  // Nombre interno en DB : [posibles nombres en Excel]
  "sku":         ["Referencia interna", "Internal Reference", "Ref. Interna", "SKU"],
  "nombre":      ["Nombre", "Name", "Descripción", "Product Name"],
  "categoria":   ["Categoría interna", "Internal Category", "Categoria"],
  "precio":      ["Precio de venta", "Sales Price", "Price", "Precio"],
  "stock":       ["Cantidad disponible", "On Hand", "Stock", "Qty On Hand"],
  "imagen_url":  ["Imagen", "Image", "Photo", "Foto"]
};
```
Si Odoo cambia un nombre, solo se debe agregar el nuevo alias al array correspondiente. Nunca cambiar el nombre de la columna en PostgreSQL.

## Estructura de Tablas Principal
*   `productos`: `id`, `code` (sku), `name`, `categoria`, `price`, `stock`, `img_url`, `has_valid_code`, `created_at`, `updated_at`.
*   `banners`: `id`, `img_url`, `titulo`, `subtitulo`, `link_url`, `orden`, `activo`, `created_at`.
*   `auditoria`: `id`, `usuario`, `accion`, `detalle`, `fecha`.
*   `product_overrides`: `code` (PK), `display_name`, `custom_price`, `oculto` (bool, v1.2.0), `updated_by`, `updated_at`.
*   `reparaciones`: `id`, `cliente`, `dni`, `telefono`, `equipo`, `codigo_desbloqueo`, `fallas`, `trabajo_realizado`, `presupuesto`, `estado`, `historial_pagos` (jsonb), `fotos` (jsonb, hasta 3 URLs ImgBB, v1.2.0), checks booleanos de ingreso rápido (`chk_sin_bateria`, `chk_rajado`, `chk_mojado`), y columna JSONB `inspeccion_hw` (v1.3.0) para el checklist detallado de hardware de 11 puntos en dos columnas.
*   `descuentos` (v1.3.0): `id`, `codigo` (unique), `nombre`, `porcentaje`, `activo`, `created_at`. Seguridad RLS: lectura directa bloqueada al público; solo accesible vía función RPC `validar_cupon(codigo_input)` (Security Definer) para consultar validez en el carrito.
*   `precios_taller` (v1.3.0): `id`, `categoria`, `servicio`, `precio`, `orden`, `created_at`. Tarifario rápido para autocompletado en taller. RLS con lectura pública para mostrador y técnicos; gestión exclusiva para Admin/Superadmin.
*   `audit_log`: Registro inmutable de auditoría para acciones en Admin y Taller (`action_type`, `user_email`, `entity_code`, `detalle`, `user_role`).

## Integración Multimedia e ImgBB (v1.2.0)
Para no consumir cuota de transferencia y almacenamiento en Supabase (evitando errores de "Cached Egress Exceeded"), toda subida de imágenes fue migrada a **ImgBB API**:
1. **API Key Centralizada:** Definida en `config.js` (`imgbbApiKey`).
2. **Función Helper:** `uploadToImgBB(file, customName)` en `admin.html`.
3. **Compresión JPEG en Cliente (Hotfix Agosto 2026):** Antes del envío al endpoint `https://api.imgbb.com/1/upload`, el frontend web comprime usando un canvas invisible en formato **JPEG (800px para catálogo, 600px para taller)**. Se abandonó el formato WebP debido a falsos positivos en los detectores de spam de ImgBB que generaban la eliminación silenciosa (Error 404) y tiempos lentos de carga en su CDN. En la app móvil, se utiliza detección dinámica del MIME original de la cámara para asegurar coincidencia de extensiones.

## Módulo de Promociones y Descuentos (v1.3.0)
El carrito de compras implementa una regla de **no acumulabilidad automática**:
* Evalúa la promoción por volumen activa y el cupón de descuento validado por el usuario.
* Aplica exclusivamente el descuento que represente un mayor ahorro económico para el cliente ("Solución Nivel Dios UX").
* Las validaciones de cupones se ejecutan a través del RPC `validar_cupon` en Supabase, preservando la privacidad del listado completo de códigos.

## Actualización v1.3.1 (Correcciones y Mejoras de Taller)
1. **Seguridad y Navegación en Admin:** Se corrigió el arreglo de permisos `ROLE_TABS` en `admin.html` para autorizar a roles `admin` y `superadmin` al uso persistente de las pestañas **🎟️ Descuentos** y **🛠️ Tarifario**.
2. **Impresión de Remito PDF (`reparaciones.html`):** Se unificó la llamada de impresión al método `printPDF()`, corrigiendo las referencias al DOM para el número de orden (`p_orden`) y añadiendo de forma destacada el membrete con la **Sucursal de Ingreso** (`Local 2984` o `Local 1912`).
3. **Filtros en Taller:** Se implementó un menú de filtrado por estado (`#filterEstado`) combinable con búsqueda por texto libre.
4. **Inspección de Biometría:** Se añadió la opción `"No tiene"` para dispositivos sin sensor biométrico.
