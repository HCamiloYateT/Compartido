# Datos Dummy -----------------------------------------------------------------

set.seed(42)

# Parametros base ----
n_clientes  <- 120
n_ventas    <- 500
n_leads     <- 80
fechas_base <- seq(as.Date("2024-01-01"), as.Date("2024-12-31"), by = "day")

# Tabla de clientes dummy ----
dummy_clientes <- tibble(
  id_cliente  = 1:n_clientes,
  nombre      = paste("Cliente", str_pad(1:n_clientes, 3, pad = "0")),
  segmento    = sample(c("Premium", "Estandar", "Basico"), n_clientes, replace = TRUE,
                       prob = c(0.2, 0.5, 0.3)),
  ciudad      = sample(c("Bogota", "Medellin", "Cali", "Barranquilla", "Bucaramanga"),
                       n_clientes, replace = TRUE),
  activo      = sample(c(TRUE, FALSE), n_clientes, replace = TRUE, prob = c(0.75, 0.25)),
  fecha_alta  = sample(fechas_base[1:180], n_clientes, replace = TRUE),
  valor_total = round(runif(n_clientes, 500000, 50000000), -3)
)

# Tabla de ventas dummy ----
dummy_ventas <- tibble(
  id_venta    = 1:n_ventas,
  id_cliente  = sample(dummy_clientes$id_cliente, n_ventas, replace = TRUE),
  fecha       = sample(fechas_base, n_ventas, replace = TRUE),
  producto    = sample(c("Cafe Premium", "Cafe Molido", "Cafe Instantaneo",
                         "Capsulas", "Accesorios"), n_ventas, replace = TRUE),
  cantidad    = sample(1:50, n_ventas, replace = TRUE),
  precio_unit = round(runif(n_ventas, 8000, 120000), -2),
  estado      = sample(c("Cerrada", "Pendiente", "Cancelada"), n_ventas,
                       replace = TRUE, prob = c(0.7, 0.2, 0.1))
) %>%
  mutate(
    valor_total = cantidad * precio_unit,
    mes         = floor_date(fecha, "month"),
    trimestre   = paste0("Q", quarter(fecha))
  )

# Tabla de leads dummy ----
dummy_leads <- tibble(
  id_lead   = 1:n_leads,
  nombre    = paste("Lead", str_pad(1:n_leads, 3, pad = "0")),
  origen    = sample(c("Web", "Referido", "Llamada", "Feria", "Email"),
                     n_leads, replace = TRUE),
  etapa     = sample(c("Prospecto", "Contactado", "Propuesta", "Negociacion", "Ganado"),
                     n_leads, replace = TRUE, prob = c(0.3, 0.25, 0.2, 0.15, 0.1)),
  fecha     = sample(fechas_base[200:365], n_leads, replace = TRUE),
  valor_est = round(runif(n_leads, 1000000, 30000000), -3)
)

# Resumen de ventas por mes para graficos ----
dummy_ventas_mes <- dummy_ventas %>%
  filter(estado != "Cancelada") %>%
  group_by(mes) %>%
  summarise(
    total_ventas = sum(valor_total),
    n_ventas     = n(),
    ticket_prom  = mean(valor_total)
  )

# KPIs globales ----
dummy_kpis <- list(
  total_ventas    = sum(dummy_ventas$valor_total[dummy_ventas$estado == "Cerrada"]),
  clientes_activos = sum(dummy_clientes$activo),
  leads_activos   = nrow(dummy_leads[dummy_leads$etapa != "Ganado", ]),
  ticket_promedio = mean(dummy_ventas$valor_total[dummy_ventas$estado == "Cerrada"])
)
