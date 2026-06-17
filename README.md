# 🛒 DTZ Servicio Técnico – Catálogo Web B2C/B2B

¡Bienvenido al repositorio del Catálogo Web Oficial de **DTZ Servicio Técnico**!  
🔗 **Sitio en vivo:** [www.dtzserviciotecnico.com.ar](https://www.dtzserviciotecnico.com.ar)

Este proyecto nace de la necesidad de proveer a una empresa de servicio técnico informático un **catálogo autogestionable, rápido y seguro**, sin depender de plataformas de e-commerce con altas comisiones o costos fijos mensuales (como TiendaNube o Shopify).

## 🚀 Arquitectura y Stack Tecnológico

El proyecto está diseñado bajo un enfoque **Serverless + Vanilla Frontend** para maximizar el rendimiento, reducir los tiempos de carga a cero y minimizar los costos operativos.

*   **Frontend:** HTML5, CSS3, y Vanilla JavaScript (Cero dependencias pesadas, sin React ni frameworks que ralenticen el FCP).
*   **Backend & Base de Datos:** [Supabase](https://supabase.com/) (PostgreSQL).
*   **Autenticación:** Supabase Auth (Sistema de login por Email y JWT).
*   **Seguridad:** RLS (*Row Level Security*) de PostgreSQL. Todo el control de permisos se ejecuta en la capa de la base de datos, garantizando que el Frontend sea imposible de vulnerar.
*   **Hosting:** GitHub Pages con dominio propio delegado vía Cloudflare DNS.
*   **AI Pair Programming:** Desarrollado utilizando metodologías ágiles en conjunto con **Antigravity**, **Claude 3.5 Sonnet / 4.6** y **Gemini 1.5 Pro / 3.1 Pro**.

## ✨ Funcionalidades Principales

### 🖥️ Interfaz de Usuario (Capa Pública)
*   **Catálogo en tiempo real:** Lectura de productos desde la base de datos con paginación asíncrona optimizada.
*   **Motor de Filtros y Búsqueda:** Búsqueda instantánea por código de barras o nombre del producto, y filtros por stock y rangos de precio.
*   **Carrito de Compras B2C:** Carrito efímero guardado en `localStorage`, con cálculo automático de **Promociones escalonadas** (ej: 10% off a partir de 3 productos).
*   **Checkout Integrado:** No requiere pasarela de pagos. El pedido viaja pre-formateado a través de la API de WhatsApp al local seleccionado.

### 🛡️ Panel de Administración y Backend (El corazón del sistema)
*   Protegido mediante comprobación de sesión y validación de tokens contra Supabase Auth.
*   **PostgreSQL Nativo:** A diferencia de proyectos frontend puros, toda la lógica crítica, validaciones y permisos residen en la base de datos mediante **Triggers** y **SQL puro**.
*   **Control de Usuarios (RBAC):** Gestión de roles (`superadmin`, `admin`, `staff`) a nivel base de datos.
*   **Módulo de Reparaciones (Taller):** Micro-sistema independiente para el ingreso de equipos al servicio técnico, gestión de fallas y cuenta corriente (historial de cobros usando campos `JSONB`). Accesible de forma unificada por todos los empleados.
*   **Registro de Auditoría (Logs):** Trazabilidad total implementada desde el backend. Cada vez que un empleado interactúa, queda registrado de forma inmutable quién, qué y cuándo lo hizo.

## 📂 Estructura del Repositorio

A los reclutadores y desarrolladores: Los invito a revisar la carpeta `/guias_y_planes`, donde documento mi proceso de ingeniería de software, toma de decisiones arquitectónicas y checklists de features.

```text
├── admin.html               # SPA del Panel de Administración
├── index.html               # SPA Pública (Catálogo)
├── config.js                # Variables de entorno y conexión
├── /guias_y_planes/         # 🧠 Documentación de diseño y arquitectura
├── /scripts_sql/            # 💾 DDL y Políticas RLS de Supabase
└── SETUP.md                 # Manual de despliegue
```

## 🔐 Nota sobre Seguridad Arquitectónica
Este proyecto fue diseñado con un enfoque de seguridad **Backend-First**. El repositorio expone intencionalmente la `anon_key` en el frontend, ya que es una práctica estándar en arquitecturas BaaS modernas. La seguridad e integridad real de los datos (`INSERT`, `UPDATE`, `DELETE`) está sellada herméticamente en el motor de **PostgreSQL** mediante políticas estrictas de *Row Level Security* (RLS). 

Te invito a auditar la carpeta `scripts_sql/` para ver las definiciones de tablas, triggers y políticas escritas en código duro.

---
*Desarrollado y mantenido por [Lucas Miranda U](https://github.com/LucasMirandaU) en colaboración con DTZ Servicio Técnico.*
