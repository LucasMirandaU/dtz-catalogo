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
