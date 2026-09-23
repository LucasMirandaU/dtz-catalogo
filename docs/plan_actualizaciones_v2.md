# Actualización de App y Web DTZ

Este plan detalla los pasos para incorporar la firma de retiro, unificar los PDFs, arreglar WhatsApp, añadir la versión de la App y revisar métricas.

## Modificaciones Propuestas

### 1. Base de Datos
- **[NUEVO]** Script SQL `db/17_add_firma_retiro.sql` para añadir la columna `firma_retiro` (tipo `text`) a la tabla `reparaciones`.

### 2. WebDTZ (Panel Admin)
- **[MODIFICAR]** `reparaciones.html`
  - Añadir el bloque para ver y gestionar la **Firma de Retiro** del cliente.
  - Actualizar la plantilla de impresión PDF (`#printLayout`) para que incluya la firma de retiro debajo de la firma de ingreso.

### 3. DTZMobile (App de Técnicos)
- **[MODIFICAR]** `src/app/repair/[id].tsx`
  - Añadir el componente de firma digital para el **Retiro**.
  - Reemplazar el código HTML actual del generador de PDFs (`expo-print`) copiando exactamente el diseño de la Web (misma estructura, mismos legales, mismos totales).
  - Revisar y corregir la función de compartir a WhatsApp. (Actualmente usa el menú nativo de compartir del celular. Evaluaremos si se debe enviar un texto con link directo, o arreglar el PDF).
- **[MODIFICAR]** `src/app/(tabs)/profile.tsx`
  - Añadir el número de versión (ej. `v1.0.0`) leyendo el archivo `app.json` para que los técnicos sepan si están desactualizados.

### 4. WebDTZ (Catálogo)
- **Métricas de Visitas:** Actualmente el `index.html` estático no cuenta con un sistema de métricas integrado (como Google Analytics o Meta Pixel). Para poder decirle a los clientes de los banners cuánta gente los vio, propongo integrar **Google Analytics 4 (GA4)** gratuito.

## Preguntas Pendientes para la Vuelta

1. **Sobre compartir a WhatsApp en la App:** Actualmente la App genera el PDF y abre el menú general de "Compartir" del teléfono (donde elegís WhatsApp u otra app). ¿Falla al abrir ese menú, o preferís un botón que diga "Enviar por WhatsApp" que abra WhatsApp directamente con un texto predeterminado sin el PDF?

2. **Sobre las Métricas de Banners:** ¿Tenés ya una cuenta de Google Analytics creada para `dtzserviciotecnico.com.ar`? Si es así, solo pasame el "ID de medición" (ej: `G-XXXXXXXXXX`). Si no la tenés, podés crear una cuenta gratis en analytics.google.com y pasarme el código, o podemos armar un contador simple en Supabase (aunque Analytics es mucho más profesional y te da gráficos). ¿Qué preferís?
