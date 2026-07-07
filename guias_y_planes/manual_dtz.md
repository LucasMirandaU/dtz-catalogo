# 📖 Manual de Uso - Catálogo Web DTZ

Este manual está diseñado para los dueños y administradores de **DTZ Servicio Técnico**. Contiene la información clave sobre dónde está alojada la web y cómo utilizar el panel de administración.

---

## 1. 🌐 Información del Sistema

*   **Sitio web público:** [https://www.dtzserviciotecnico.com.ar](https://www.dtzserviciotecnico.com.ar)
*   **Panel de Administración:** [https://www.dtzserviciotecnico.com.ar/admin.html](https://www.dtzserviciotecnico.com.ar/admin.html)

### Cuentas y Accesos Clave (Completar a mano por seguridad)

*   **Hosting / Repositorio (GitHub):**
    *   Usuario/Email: ____________________________________
    *   Contraseña: ____________________________________
*   **Gestor de Dominio (Nic.ar / Cloudflare):**
    *   Usuario/Email: ____________________________________
    *   Contraseña: ____________________________________
*   **Base de Datos (Supabase):**
    *   Usuario/Email: ____________________________________
    *   Contraseña: ____________________________________

*(Por seguridad, no anotes estas contraseñas en archivos digitales compartidos. Imprimí esta hoja o guardala en un gestor de contraseñas seguro).*

---

## 2. 🔐 Control de Empleados y Panel (Roles)

En el panel de administración existen 3 niveles de acceso. Vos como dueño tenés el rol de **Administrador**, lo que te da control total sobre tu negocio y tu equipo.

### Tu Rol: Administrador (Dueño)
*   **Catálogo y Marketing:** Podés importar Excel de Odoo, cambiar precios/nombres exclusivos para la web, subir fotos, crear promociones, Banners y cambiar el Logo.
*   **Gestión de Equipo:** Desde la pestaña **"Usuarios"**, podés crear cuentas nuevas para tus empleados, cambiarles la contraseña si se la olvidan, ascenderlos o eliminarlos del sistema. Todo sin salir del panel.
*   **Auditoría:** Podés ver el historial de quién tocó qué cosa en el sistema.

### Rol de tus Empleados: Staff
*   **Gestión Básica:** Al entrar al panel, verán habilitada la pestaña "Productos" y el acceso al "📱 Reparaciones".
*   **Catálogo:** Pueden buscar productos y subir o cambiarles la foto.
*   **Reparaciones:** Pueden ingresar nuevos equipos, cambiar estados y agregar cobros parciales a los clientes.
*   **Restricción:** No pueden importar Excel, modificar precios/nombres, ni tocar banners, promociones o usuarios.

### Rol del Desarrollador: Superadmin
*   Rol oculto y exclusivo para el desarrollador de la web. Tiene los mismos permisos que el Administrador, pero con protección anti-borrado (un Admin no puede borrar ni degradar a un Superadmin).

### Buenas prácticas de seguridad
*   Cada empleado debe tener un email y una contraseña propios. **No deben compartir credenciales.**
*   Si un empleado se va de la empresa, podés eliminar su acceso en cualquier momento desde la pestaña "Usuarios". Su historial de cambios quedará guardado en Auditoría.

---

## 3. 📦 Guía de Uso Diario (Para Empleados)

### Cómo cargar o actualizar productos
1. Ingresá al panel en `dtzserviciotecnico.com.ar/admin.html`.
2. Necesitás iniciar sesión con tu email y contraseña.
3. El catálogo se sincroniza exportando un archivo Excel (`.xlsx`) desde Odoo.
4. Hacé clic en **"Importar productos"** y seleccioná el Excel de Odoo.
5. El sistema mostrará un resumen (cuántos productos entraron y si hubo errores).

⚠️ **Importante sobre Odoo:** Nunca cambies el nombre de las columnas en Odoo al exportar el Excel. Si los nombres cambian (ej: de "Precio de venta" a "Sales Price"), la importación podría fallar.

### Cómo Ocultar Productos (Sin borrar de Odoo)
1. Si un producto no tiene stock o está temporalmente discontinuado, podés ocultarlo de la web al instante haciendo clic en el icono del **ojo (`👁️`)** en la tabla del panel de administración.
2. El botón cambiará a **`🙈 (Oculto)`** y el producto desaparecerá del catálogo público inmediatamente.
3. Al volver a importar un Excel de Odoo, los productos que ya no estén en el Excel se eliminarán automáticamente, mientras que los que sigan estando conservarán su estado de visibilidad y su foto.

### Cómo gestionar los Banners (Publicidades)
1. En el panel, ve a la sección **"Banners"**.
2. Hacé clic en "Nuevo banner" y subí tu foto.
3. **Medidas obligatorias para que no se vea deformado:**
    *   Ancho: 1200 píxeles.
    *   Alto: 400 píxeles.
    *   Relación: 3:1 panorámica.
4. Podés pausar (desactivar) una publicidad en cualquier momento sin borrarla. También podés cambiar el orden arrastrándolas. (Máximo 5 activas).

### Cómo usar el Módulo de Reparaciones (Taller)
1. Desde el panel, hacé clic en el botón superior **"🛠️ Reparaciones"**.
2. **Para ingresar un equipo:** Tocá el botón "+ Nueva". Llená los datos del cliente (incluyendo DNI), marcá el estado del equipo en el **Checklist** y anotá la falla.
3. **📸 Fotos del Equipo:** Podés adjuntar **hasta 3 fotografías** del estado en que llega el celular (roturas, rayones, número de serie). Se suben automáticamente y quedan vinculadas a la orden.
4. **Generar el número de orden:** Ya no se ingresa a mano. El sistema generará el número oficial de forma automática y secuencial (Ej: #101) al guardar la orden.
5. **Señas Iniciales:** Podés ingresar el monto en "Seña Inicial ($)" y el método de pago directamente en el formulario al momento de recibir el equipo. El sistema lo restará automáticamente del presupuesto.
6. **Comprobante (PDF):** Una vez guardada la orden, vas a tener un botón de "🖨️ PDF" en la parte inferior para generar el remito con los términos y condiciones legales. **Las 3 fotos adjuntas aparecerán en miniatura y el remito está calibrado para imprimirse en 1 sola carilla.**
7. **Para cambiar de estado:** Tocá la tarjeta del cliente y cambiá el estado (Ej: de "Ingresado" a "Reparado"). El color de la tarjeta cambiará automáticamente para que sea fácil identificarlo a simple vista.
8. **Pagos posteriores:** Si el cliente viene a pagar un saldo o retirar, entrá a la reparación, bajá hasta "Historial de Pagos" y tocá **"+ Pago"**. El sistema recalculará el saldo a pagar.
9. **🗑️ Eliminar Órdenes:** Los usuarios con rol Administrador o Superadmin verán un botón rojo de "Eliminar" en la barra inferior para borrar órdenes cargadas por error (con cuadro de confirmación).
10. **📜 Auditoría Taller:** En la barra superior, el botón "Auditoría Taller" permite visualizar el historial de todas las órdenes creadas, pagos registrados, fotos subidas y eliminaciones efectuadas por el personal.
11. **⚡ Autocompletado con Tarifario:** Al crear o editar una orden, usá el desplegable "⚡ Cargar Precio de Lista" para elegir una reparación estándar (Ej: Limpieza Pin de Carga). El sistema completará el presupuesto y sumará el detalle a las notas de falla.
12. **📋 Inspección Detallada de Hardware:** Ahora contás con un checklist rápido de 3 estados (Sin Batería, Rajado, Mojado) y una inspección exhaustiva de 11 componentes en dos columnas (Tapa trasera, Cámaras, SIM, Pin, Biometría, Display, Altavoz, Auricular, Micrófono) para máxima claridad.
13. **Flujo Oficial de Estados:** Los estados disponibles en el desplegable son ahora los oficiales: `Ingresado / En Revisión`, `Presupuestado / Esperando Confirmación`, `Reparando`, `Esperando Repuesto`, `Reparado / Avisado al Cliente`, `Sin Reparación / Rechazado` y `Entregado`.

### Cómo usar los Cupones de Descuento (Admin)
1. En el panel de administración, ve a la pestaña **"Descuentos"**.
2. Completa el Nombre (Ej: "Primer año del local"), el Código en mayúsculas (Ej: "PRIMERANIVERSARIO") y el Porcentaje (Ej: 25%).
3. Los clientes podrán escribir el código en el Carrito de la web. El sistema aplicará la regla de **no acumulabilidad**, comparando el cupón con la promoción por volumen y aplicando el mayor beneficio para el cliente.
4. Puedes pausar o eliminar cupones en cualquier momento con los botones de acción en la tabla.

### Cómo gestionar el Tarifario de Taller (Admin)
1. En el panel de administración, ve a la pestaña **"Tarifario"**.
2. Agrega servicios indicando Categoría (Ej: "SAM / MOTO / REDMI" o "IPHONE"), Servicio (Ej: "Limpieza Pin de Carga") y Precio ($).
3. Este listado estará disponible en el módulo de reparaciones para consulta rápida de los técnicos (botón "💲 Precios") y para el autocompletado en el mostrador al recibir equipos.

---
*Desarrollado en exclusiva para DTZ por Lucatoons*
