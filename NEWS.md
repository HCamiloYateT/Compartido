# Recursos 1.1.0

- Amplía los estilos de racafeForms 0.4.0 con badges semánticos y densidades de tarjeta/indicador.
- Centraliza tokens de controles y colores semánticos; conserva los valores existentes de badges de entorno.
- Evita estirar tarjetas vecinas, uniforma campos dentro/fuera del formulario y mejora el wrap de acciones.
- Reutiliza las dimensiones corporativas de modal y los scripts de portapapeles/reset sin duplicarlos.

# Correo 0.1.0

- Añade email/config.R, VERSION, base y firma común para racafeMail.
- Añade invitación, OTP, notificación y confirmación con HTML de tablas y estilos inline.
- Centraliza colores y URLs de marca; conserva el motor únicamente en Libreria-Racafe.
- Añade guía de instalación versionada, validación y rollback sin cambios de servicios.

# Recursos 1.0.0

- Añade ASSETS_VERSION para consumo local versionado desde racafeForms 0.3.0.
- Conserva Styles/style.css como entrada e importa el nuevo módulo Styles/racafe-forms.css.
- Añade estilos rf- para paneles, tarjetas, indicadores, cuadrículas, acciones, modales, readonly y mensajes.
- Reutiliza colores, tipografía y tamaños de modal existentes; sin una segunda tabla de anchos.
- Centraliza portapapeles de texto/PNG y reset de formularios, con resultados reales a Shiny.
- Actualiza Scripts/scripts para tooltips delegados e inicialización idempotente.
- Mantiene imágenes institucionales y utilidades existentes sin cambios.
- La integración se probó junto a racafeForms con 237 comprobaciones de R y 54 de navegador por modo Shiny/bs4Dash.

El informe reproducible está en Libreria-Racafe/racafeForms/docs/validation-report.md.
