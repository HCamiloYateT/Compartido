# Plantillas corporativas de racafeMail — 0.1.0

Esta carpeta es la fuente de las plantillas y de la configuración R. El único motor
reutilizable vive en `Libreria-Racafe/racafeMail`: no copie ni haga `source()` de un motor
`racafeMail.R` junto a estas plantillas. No se instala ningún servicio adicional.

## Estructura y contrato

- `VERSION`: versión del contrato (0.1.0).
- `config.R`: lista R `racafe_mail` con identidad y referencias SMTP; nunca contraseñas.
- `templates/base.html`: estructura HTML completa, tablas e identidad común.
- `templates/invitacion.html`: nombre, enlace HTTPS y vencimiento.
- `templates/otp.html`: nombre, código de seis dígitos y vigencia en minutos.
- `templates/notificacion.html`: nombre y mensaje de texto plano.
- `templates/confirmacion.html`: nombre, detalle y fecha, sin efectos de negocio.
- `components/firma.html`: firma uniforme para las cuatro plantillas.

Las variables `{{nombre}}` se escapan como texto/atributo; no admiten HTML de usuario.
Solo la base inserta `[[CONTENIDO_INTERNO]]`, `[[FIRMA_INTERNA]]` y `[[AVISO_PRUEBAS]]`.
No agregue scripts, CSS externo ni variables con contenido HTML sin revisar el motor.
Los archivos y `config.R` son código/recursos de confianza; solo los operadores deben
poder modificarlos. `config.R` se evalúa como R, no como una configuración aislada.

## Instalación local versionada

Instale `racafeMail` 0.1.0 desde la subcarpeta homónima de Libreria-Racafe. Fije ambos
repositorios a commits aprobados y archive esos identificadores con la versión liberada.
Copie únicamente este directorio a una ruta de recursos de solo lectura para el proceso,
por ejemplo `/home/compartido/email`; no exponga la raíz del repositorio vía HTTP.

```r
config <- racafeMail::racafeMailConfig(ruta = "/home/compartido/email", version = "0.1.0")
racafeMail::racafeMailPreview("notificacion", list(nombre = "Prueba", mensaje = "Mensaje de prueba"),
                            archivo = tempfile(fileext = ".html"), config = config)
```

También se admite `RACAFE_MAIL_HOME`. Render y preview no hacen SMTP ni descargan
imágenes; las URL se consultan únicamente si el cliente del destinatario las carga.
No hay JSON de configuración runtime.

## Personalización

Edite `empresa`, `web`, `logo_url`, `firma_url`, `color`, `color_fondo`, `color_texto` y `pie`
en `config.R`, o páselos explícitamente a `racafeMailConfig()`. Los colores son hexadecimales
`#RRGGBB`; las imágenes y web deben usar URL HTTPS públicas estables. `logo.png` y
`logo2.png` permanecen en `img/`; una ruta del disco no es una URL de correo.
En producción conviene servir las imágenes desde un dominio estable o una URL inmutable;
la URL inicial de GitHub `main` es un valor editable, no un recurso fijado por el paquete.
Las imágenes remotas pueden bloquearse. CID queda pendiente de validar en Gmail/Outlook,
no se adopta ni se usa data URI como alternativa por defecto.

`RACAFE_MAIL_FROM`, `RACAFE_MAIL_CRED` y `RACAFE_MAIL_TEST_MODE` toman precedencia sobre
los nombres heredados `FIRMA_BLASTULA_FROM`, `FIRMA_BLASTULA_CRED` y `FIRMA_TEST_MODE`.
Las variables de credenciales contienen una **ruta** a un archivo externo de blastula;
no confirme ese archivo en Git. El modo de pruebas solo agrega un aviso al contenido:
no bloquea el envío cuando se llama explícitamente al transportador.

## Validación y rollback

Desde Libreria-Racafe, con la ruta de esta copia:

```sh
RACAFE_MAIL_TEST_HOME=/ruta/Compartido/email Rscript -e 'testthat::test_local("racafeMail")'
```

Revise las cuatro vistas previas y valide Gmail/Outlook con destinatarios de prueba
antes de activar un flujo real. No hay envíos ni cambios de producción automáticos.
Conserve la copia previa, los dos commits y cualquier configuración local fuera del
checkout; para rollback restaure juntos el paquete y `email/` de la versión anterior.
La guía de migración del paquete describe Firma Digital y el adaptador OTP propuestos,
sin modificar FastAPI, MySQL, Nginx, systemd, Shiny ni OEAPP.
