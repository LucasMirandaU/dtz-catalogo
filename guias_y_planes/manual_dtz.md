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

### Cómo gestionar los Banners (Publicidades)
1. En el panel, ve a la sección **"Banners"**.
2. Hacé clic en "Nuevo banner" y subí tu foto.
3. **Medidas obligatorias para que no se vea deformado:**
    *   Ancho: 1200 píxeles.
    *   Alto: 400 píxeles.
    *   Relación: 3:1 panorámica.
4. Podés pausar (desactivar) una publicidad en cualquier momento sin borrarla. También podés cambiar el orden arrastrándolas. (Máximo 5 activas).

### Cómo usar el Módulo de Reparaciones (Taller)
1. Desde el panel, hacé clic en el botón superior **"📱 Reparaciones"**.
2. **Para ingresar un equipo:** Tocá el botón "+ Nueva". Llená los datos del cliente, la falla que reporta, la contraseña del teléfono y el Nro de Orden físico si usan talonario de papel. Guardá los cambios.
3. **Para cambiar de estado:** Tocá la tarjeta del cliente y cambiá el estado (Ej: de "Ingresado" a "Reparado"). El color de la tarjeta cambiará automáticamente para que sea fácil identificarlo a simple vista.
4. **Para registrar una seña o pago:** Entrá a la reparación, bajá hasta "Historial de Pagos" y tocá **"+ Pago"**. Elegí el monto y el método de pago. El sistema restará ese monto del Presupuesto Total y calculará automáticamente cuánto le falta abonar al cliente.

---
*Desarrollado en exclusiva para DTZ por [Tu Nombre / Lucatoons]*
