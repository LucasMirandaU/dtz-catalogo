# DTZ Catálogo – Guía de configuración completa

## Arquitectura (costo $0)
- **Supabase** → base de datos + imágenes + autenticación
- **GitHub Pages** → hosting del catálogo público
- **index.html** → catálogo público (cualquiera con el link)
- **admin.html** → panel admin (solo con usuario/contraseña)
- **config.js** → credenciales de Supabase (completar una sola vez)

---

## PASO 1 — Crear proyecto en Supabase

1. Ir a https://supabase.com → "Start your project"
2. "New project" → nombre: `dtz-catalogo` → región: **South America (São Paulo)**
3. Guardar la contraseña que te pide (es para la base de datos)
4. Esperar ~2 minutos a que se cree el proyecto

---

## PASO 2 — Crear las tablas (SQL)

Ir a **SQL Editor** (ícono de terminal en el menú izquierdo) y ejecutar **todo esto de una vez**:

```sql
-- ═══════════════════════════════════════
--  TABLA: productos
-- ═══════════════════════════════════════
CREATE TABLE productos (
  id             BIGSERIAL PRIMARY KEY,
  code           TEXT NOT NULL,
  code_num       INTEGER DEFAULT 9999,
  name           TEXT NOT NULL,
  price          NUMERIC DEFAULT 0,
  stock          INTEGER DEFAULT 0,
  img_url        TEXT,
  has_valid_code BOOLEAN DEFAULT true,
  updated_at     TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_productos_code     ON productos(code);
CREATE INDEX idx_productos_code_num ON productos(code_num);

-- ═══════════════════════════════════════
--  TABLA: configuracion (logo, ajustes)
-- ═══════════════════════════════════════
CREATE TABLE configuracion (
  clave  TEXT PRIMARY KEY,
  valor  TEXT
);

-- ═══════════════════════════════════════
--  SEGURIDAD: Row Level Security
-- ═══════════════════════════════════════

-- Productos: lectura pública, escritura solo autenticados
ALTER TABLE productos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lectura pública de productos"
  ON productos FOR SELECT USING (true);

CREATE POLICY "Escritura solo admin en productos"
  ON productos FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Configuracion: lectura pública, escritura solo autenticados
ALTER TABLE configuracion ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lectura pública de configuracion"
  ON configuracion FOR SELECT USING (true);

CREATE POLICY "Escritura solo admin en configuracion"
  ON configuracion FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');
```

---

## PASO 3 — Crear el bucket de imágenes

1. En Supabase ir a **Storage** (ícono de carpeta) → **New bucket**
2. Nombre: `imagenes-productos`
3. **Public bucket**: ✅ activar (necesario para que las imágenes se vean)
4. Guardar

Luego ir a **Storage → Policies** y ejecutar en SQL Editor:

```sql
-- Lectura pública de imágenes
CREATE POLICY "Imágenes públicas"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'imagenes-productos');

-- Solo autenticados pueden subir
CREATE POLICY "Subida solo admin"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'imagenes-productos'
              AND auth.role() = 'authenticated');

-- Solo autenticados pueden borrar
CREATE POLICY "Borrado solo admin"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'imagenes-productos'
         AND auth.role() = 'authenticated');

-- Solo autenticados pueden actualizar
CREATE POLICY "Update solo admin"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'imagenes-productos'
         AND auth.role() = 'authenticated');
```

---

## PASO 4 — Crear usuarios administradores

En Supabase ir a **Authentication → Users → Add user → Create new user**:

- Email: (el del dueño, ej: `owner@gmail.com`)
- Password: contraseña segura (mín. 8 caracteres, incluir números y mayúsculas)
- ✅ "Auto Confirm User"

Repetir para cada empleado con acceso (máx. recomendado: 3).

> Cada usuario tiene su propio login. Si un empleado deja la empresa,
> se elimina solo su usuario desde Authentication → Users.

---

## PASO 5 — Configurar config.js

En Supabase ir a **Settings → API**:

| Dato | Dónde encontrarlo |
|------|-------------------|
| Project URL | Settings → API → "Project URL" |
| Anon Key | Settings → API → "Project API keys" → `anon public` |

Abrir `config.js` y reemplazar los dos valores:

```javascript
const DTZ_CONFIG = {
  supabaseUrl:     'https://XXXXXXXX.supabase.co',   // ← pegar aquí
  supabaseAnonKey: 'eyJhbGciOiJIUz...',              // ← pegar aquí (la larga)
};
```

> **Seguridad**: la `anon key` es segura en el frontend porque las
> políticas RLS limitan qué puede hacer. NUNCA usar la `service_role` key.

---

## PASO 6 — Publicar en GitHub Pages

### Primera vez:
1. Crear cuenta gratuita en https://github.com
2. Clic en **"+"** → **New repository**
   - Nombre: `dtz-catalogo`
   - Visibilidad: **Public**
   - Crear repositorio
3. Subir los 4 archivos: `index.html`, `admin.html`, `config.js`, `SETUP.md`
   - Clic en **"uploading an existing file"** → arrastrar los 4 archivos → Commit
4. Ir a **Settings → Pages**
   - Source: **Deploy from a branch**
   - Branch: **main** → **/ (root)**
   - Save

En ~2 minutos la web estará disponible en:
- **Catálogo público**: `https://TU_USUARIO.github.io/dtz-catalogo/`
- **Panel admin**: `https://TU_USUARIO.github.io/dtz-catalogo/admin.html`

### Para actualizar archivos en el futuro:
1. Ir al repositorio en GitHub
2. Clic en el archivo a actualizar → ícono del lápiz (editar) → pegar el nuevo contenido → Commit
3. O bien: arrastrar el archivo nuevo encima del viejo desde la vista de archivos

---

## USO DIARIO

### Actualizar catálogo desde Odoo
1. En Odoo: Inventario → Productos → Exportar → seleccionar columnas → descargar Excel
2. Ir a `admin.html` → iniciar sesión → tab **"📊 Importar"**
3. Arrastrar el Excel → revisar los números (totales, sin código, precios $0)
4. Clic en **"✔ Cargar catálogo"** → barra de progreso → listo

> Las imágenes cargadas manualmente se conservan automáticamente
> para los productos que mantienen el mismo código.

### Agregar/cambiar imágenes de productos
1. `admin.html` → tab **"📦 Productos"**
2. Buscar el producto → clic en **"+ Imagen"** (o en la miniatura si ya tiene)
3. Arrastrar la foto o hacer clic para seleccionar
4. Clic en **"💾 Guardar imagen"** → aparece de inmediato en el catálogo

### Cambiar el logo
1. `admin.html` → tab **"🖼 Logo"**
2. Arrastrar el nuevo logo (PNG con fondo transparente, máx. 2MB)
3. Clic en **"💾 Guardar logo"** → cambia instantáneamente en el catálogo

### Cómo ven el catálogo los clientes
- Abren el link público
- Buscan por nombre o código
- Filtran por stock o precio
- Agregan productos al carrito (🛒)
- Ajustan cantidades en el panel lateral
- Agregan una nota opcional
- Clic en **"Enviar pedido por WhatsApp"**
- Llega al número de DTZ un mensaje formateado con el listado completo

### Administrar usuarios
- **Agregar**: Supabase → Authentication → Users → Add user
- **Eliminar**: Supabase → Authentication → Users → clic en usuario → Delete
- **Cambiar contraseña**: el usuario puede hacerlo desde el panel, o desde Supabase → Authentication → Users

---

## SEGURIDAD IMPLEMENTADA

| Capa | Mecanismo |
|------|-----------|
| Catálogo público | Solo lectura via política RLS `anon` |
| Panel admin | Login con Supabase Auth (email + contraseña) |
| Escritura en DB | Solo `authenticated` via políticas RLS |
| Imágenes | Bucket con políticas separadas por rol |
| Claves en frontend | Solo `anon key` (diseñada para ser pública) |
| `service_role` key | NUNCA expuesta, permanece en Supabase |

