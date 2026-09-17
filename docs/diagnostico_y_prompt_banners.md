# Diagnóstico de Estado y Plan de Acción (Banners 3:1)

## 1. Análisis del Historial y Git Diff
El selector de local en el carrito se hizo más compacto y horizontal de forma exitosa. El cambio de `PER_PAGE` a 25 también está reflejado.
La lógica de paginación e interacción del carrito se mantiene 100% operativa.

## 2. Revisión de Banners en la Base de Datos (`supabase_banners.sql`)
El esquema de la tabla `banners` está estructuralmente completo y correcto.
- La columna `img_url` es de tipo `TEXT NOT NULL`, lo cual es agnóstico a la resolución.
- Las dimensiones recomendadas documentadas son: 1200 × 400 px (ratio 3:1).

## 3. Conexión con el Frontend (`index.html`)
Se reemplazó la regla CSS vieja (`clamp()`) por la propiedad `aspect-ratio: 3 / 1`.
Esto asegura matemáticamente que la caja de la imagen siempre tenga proporción 3:1 independientemente del tamaño de pantalla, haciendo que las imágenes de 1200x400 encajen perfectamente sin deformarse ni sufrir recortes asimétricos.

## 4. Prompt para Generación de Banners con IA

> **Prompt optimizado:**
> 
> Necesito que generes una imagen para usar como banner publicitario web.
> 
> MEDIDAS EXACTAS Y OBLIGATORIAS:
> - Ancho: 1200 píxeles
> - Alto: 400 píxeles
> - Relación de aspecto: 3:1 (horizontal panorámico)
> 
> ESTÉTICA Y ESTILO:
> - Fondo oscuro (negro o gris muy oscuro con texturas sutiles).
> - Detalles técnicos, luces neón o acentos en color teal/turquesa (#2DD4BF).
> - Estilo: Premium, moderno, relacionado con tecnología, componentes de PC o servicio técnico.
> 
> CONTENIDO Y DISTRIBUCIÓN (MUY IMPORTANTE):
> [Describe aquí qué elementos visuales quieres].
> - Te adjunto el LOGO. Colócalo de forma natural dentro del diseño, preferentemente hacia un costado, respetando sus colores.
> - IMPORTANTE: El tercio inferior izquierdo (abajo a la izquierda) DEBE quedar libre de elementos complejos o distractores. Debe tener un fondo liso, oscuro o degradado suave, porque ahí irá superpuesto en color blanco el Título y Subtítulo de la web.
> - No agregues texto tú mismo, solo deja el espacio visual limpio para que mis textos resalten.
> 
> RESTRICCIÓN FINAL: La imagen final DEBE tener exactamente 1200x400px. Si tu sistema no permite medidas en píxeles, asegúrate de generar la imagen más panorámica posible (relación 3:1) y yo la escalaré.
