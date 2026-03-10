# Guía de estilos compartidos

El archivo `style.css` define estilos globales reutilizables entre aplicaciones.

## Bloques principales incluidos

- Configuración general de la app.
- Tipografía base y títulos.
- Componentes UI (tabs, modales, popups, tarjetas).
- Clases utilitarias para footers de cajas modales.
- Estilos globales para tablas `reactable`.

## Cómo extender sin romper compatibilidad

- Agregar nuevas clases en lugar de modificar comportamiento existente cuando sea posible.
- Si se cambia una clase ampliamente usada, documentar impacto en el `README.md` principal.
- Evitar selectores excesivamente específicos que dificulten sobrescritura local.

## Checklist antes de publicar cambios

1. Confirmar que no se degradan pantallas existentes.
2. Revisar que colores y tipografía mantengan coherencia visual.
3. Verificar en resolución desktop (mínimo) y, si aplica, móvil.
