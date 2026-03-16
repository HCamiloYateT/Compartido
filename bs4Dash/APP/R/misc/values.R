# Misc / Values ---------------------------------------------------------------
# Constantes, valores de configuracion y parametros globales de la aplicacion.

# Paleta de estados ----
colores_estado_venta <- c(Cerrada   = "#d5f5e3",
                          Pendiente = "#fef9e7",
                          Cancelada = "#fadbd8"
                          )

colores_etapa_lead <- c(Prospecto   = "#eaf2ff",
                        Contactado  = "#d6eaf8",
                        Propuesta   = "#fef9e7",
                        Negociacion = "#fdf2e9",
                        Ganado      = "#d5f5e3"
                        )

# Orden de etapas de leads ----
etapas_leads_ord <- c("Prospecto", "Contactado", "Propuesta", "Negociacion", "Ganado")


fac_SUCS <- c("BACHUÉ",  "MEDELLÍN",  "POPAYÁN", "ARMENIA", "PEREIRA", "BUCARAMANGA", "HUILA", "ARENALES", "TOTAL")
fac_sucs <- c("Bachué", "Medellín", "Popayán", "Armenia", "Pereira", "Bucaramanga", "Huila", "Arenales", "Total")

fac_Meses <- c("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre")

fac_PRODS <- c('EXCELSOS','SUPREMOS, DUNKIN Y MILLSTONE','PRODUCTO DE COLOMBIA',
               'PRACTICES','4C Y CRECER','CERTIFICADOS','REGIONALES','PERFIL DE TAZA',
               'FINCA','A LA MEDIDA','CONSUMOS Y PASILLAS SACOS DE 70KG', 'TRILLAS PARA TERCEROS')

fac_PRODS_ARE <- c('CONSUMO', 'CONSUMO MEZCLA', 'PASILLA MOLIDO', 'PASILLA SOLUBLE', 'RIPIO')

# Márgenes Plotly ----
m <- list(l = 50,r = 50,b = 5,t = 20)