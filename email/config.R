# Configuración R de confianza: identidad corporativa y referencias SMTP, nunca secretos ----
racafe_mail <- list(
  empresa = "Racafé & Cía. S.C.A.",
  web = "https://www.racafe.com",
  logo_url = "https://raw.githubusercontent.com/HCamiloYateT/Compartido/main/img/logo.png",
  firma_url = "https://raw.githubusercontent.com/HCamiloYateT/Compartido/main/img/logo.png",
  color = "#bf2838",
  color_fondo = "#f4f4f4",
  color_texto = "#333333",
  pie = "Este es un mensaje automático. Por favor, no responda a este correo.",
  remitente = Sys.getenv("RACAFE_MAIL_FROM", Sys.getenv("FIRMA_BLASTULA_FROM", "")),
  credenciales = Sys.getenv("RACAFE_MAIL_CRED", Sys.getenv("FIRMA_BLASTULA_CRED", "")),
  entorno = Sys.getenv("RACAFE_MAIL_TEST_MODE", Sys.getenv("FIRMA_TEST_MODE", "false"))
)
