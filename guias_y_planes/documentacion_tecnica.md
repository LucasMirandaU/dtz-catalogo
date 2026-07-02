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
*   `reparaciones`: `id`, `cliente`, `dni`, `telefono`, `equipo`, `codigo_desbloqueo`, `fallas`, `trabajo_realizado`, `presupuesto`, `estado`, `historial_pagos` (jsonb), `fotos` (jsonb, hasta 3 URLs ImgBB, v1.2.0), checks booleanos (`chk_sin_bateria`, `chk_rajado`, etc.).
*   `audit_log`: Registro inmutable de auditoría para acciones en Admin y Taller (`action_type`, `user_email`, `entity_code`, `detalle`, `user_role`).

## Integración Multimedia e ImgBB (v1.2.0)
Para no consumir cuota de transferencia y almacenamiento en Supabase (evitando errores de "Cached Egress Exceeded"), toda subida de imágenes fue migrada a **ImgBB API**:
1. **API Key Centralizada:** Definida en `config.js` (`imgbbApiKey`).
2. **Función Helper:** `uploadToImgBB(file, customName)` en `admin.html`.
3. **Compresión WebP en Cliente:** Antes del envío al endpoint `https://api.imgbb.com/1/upload`, el frontend comprime usando un canvas invisible en formato WebP (800px para catálogo, 600px para taller).

## Estrategia de Infraestructura y SaaS (Lucatoons)
*   **GitHub Pages vs. Vercel:** Para proyectos estáticos tipo catálogo/ERP de mostrador como DTZ, **GitHub Pages** es la arquitectura recomendada por su costo $0, portabilidad y simplicidad de *forking*.
*   **Seguridad de API Keys en SPA:** Al estar en el frontend, las keys en `config.js` son públicas. Esto es un estándar aceptable para ImgBB y Supabase Anon Key porque no otorgando acceso administrativo a cuenta ni bases de datos.
*   **Cuándo escalar a Vercel con Serverless Functions:** Para proyectos futuros que requieran cobros online (Stripe/MercadoPago), Inteligencia Artificial o emails transaccionales, se debe desplegar en **Vercel** usando la carpeta `/api` (Backend Serverless) guardando claves sensibles en Variables de Entorno secretas.

## Flujo de Trabajo en Git y Ramas (Manual del Desarrollador)
*   **Ramas de Tarea (`feat/` o `fix/`):** Se crean desde `main`, se trabajan aisladas, se combinan (`git merge` o PR) a `main` al finalizar y luego **se borran inmediatamente** (`git branch -d nombre-rama`) para mantener el repositorio limpio.
*   **Ramas Estructurales (`main`, `staging`):** Nunca se borran. Representan entornos estables y de producción.
*   **Ramas Descartadas:** Si una prueba no prospera, se borra directamente sin hacer merge para no ensuciar el código principal.
