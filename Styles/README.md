# Guía de estilos compartidos

El archivo `style.css` define estilos globales reutilizables entre aplicaciones.

## Bloques principales incluidos

- Configuración general de la app.
- Tipografía base y títulos.
- Componentes UI (tabs, modales, popups, tarjetas).
- Clases utilitarias para footers de cajas modales.
- Estilos globales para tablas `reactable`, `TablaPresupuesto` y `gt`.


## Tamaños de modales

Para evitar que todos los modales compartan el mismo ancho, el CSS expone clases de tamaño reutilizables. Pueden aplicarse al contenedor `.modal` o directamente a `.modal-dialog`, según cómo construya el modal cada app; también existen alias con prefijo `modal-` para integraciones que siguen la convención de Bootstrap (`modal-ventana`, `modal-subventana1`, etc.).

| Clase | Uso sugerido | Ancho máximo |
| --- | --- | --- |
| `ventana` | Modal principal o vista amplia | `1200px` |
| `subventana1` | Submodal amplio | `1050px` |
| `subventana2` | Submodal medio-amplio | `900px` |
| `subventana3` | Submodal medio | `760px` |
| `subventana4` | Submodal compacto | `620px` |
| `subventana5` | Submodal pequeño | `500px` |
| `aviso` | Confirmaciones, alertas o mensajes breves | `380px` |

Todos los tamaños usan límites responsivos en `vw` para no desbordar pantallas pequeñas.

## Cómo extender sin romper compatibilidad

- Agregar nuevas clases en lugar de modificar comportamiento existente cuando sea posible.
- Si se cambia una clase ampliamente usada, documentar impacto en el `README.md` principal.
- Evitar selectores excesivamente específicos que dificulten sobrescritura local.

## Checklist antes de publicar cambios

1. Confirmar que no se degradan pantallas existentes.
2. Revisar que colores y tipografía mantengan coherencia visual.
3. Verificar en resolución desktop (mínimo) y, si aplica, móvil.
