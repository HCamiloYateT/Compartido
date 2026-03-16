
input = list(FT_Periodo = 2024, FT_Asesor = "CMEDINA", PEN_PendProducir =T, 
             PEN_PendDespachar=T, PEN_DespPendFacturar=T, FT_Segmento = "DETAL", 
             FT_LinNeg = "A LA MEDIDA")

dat_ped <- function(){
  
  ConsultaSistema("syscafe", uid, pwd,
                  "SELECT PdcCod, PdcLin, PdcCan, LinNegCod, LinProCod
                                FROM EXPPEDI1
                                WHERE CiaCod =10 and PdcCan > 0") %>%
    inner_join(ConsultaSistema("syscafe", uid, pwd,
                               paste0("SELECT PdcCod, PdcUsu, PdcFecCre, CliNit  as PerCod
                                            FROM EXPPEDID
                                            WHERE CiaCod = 10 AND CliNit <>32 AND
                                           PdcEst = 'A' AND PdcVtaNal = 1")),
               by = "PdcCod") %>%
    left_join(NCLIENTE %>%  select(PerCod, PerRazSoc), by = join_by(PerCod)) %>%
    left_join(CargarDatos("CRMNALCLIENTE")  %>%
                mutate(Segmento = ifelse(input$FT_Periodo == 2024, Segmento2024, Segmento2025)) %>%
                select(LinNegCod, PerCod = CLCliNit, Segmento) %>%
                distinct(),
              by = join_by(PerCod, LinNegCod)
    ) %>%
    anti_join(ConsultaSistema("syscafe", uid, pwd,
                              "SELECT PdcCod, PdcLin
                                  FROM EXPLOT1 "),
              by = join_by(PdcCod, PdcLin)) %>%
    left_join(ConsultaSistema("syscafe", uid, pwd,
                              "SELECT LinNegCod, LinNegNom AS LinNeg
                                  FROM NLINEANE
                                  WHERE CiaCod = 10"),
              by = join_by(LinNegCod) ) %>%
    left_join(ConsultaSistema("syscafe", uid, pwd,
                              "SELECT LinProCod, LinProNom
                                  FROM NTIPPROD
                                  WHERE CiaCod = 10"),
              by = join_by(LinProCod)) %>%
    select(PerRazSoc, Segmento, PdcCod, PdcCan, PdcFecCre, LinNeg, LinProNom, PdcUsu) %>%
    mutate(PdcFecCre = as.Date(PdcFecCre)) %>%
    filter(PdcUsu %in% input$FT_Asesor)
  
}
dat <- function(){BaseDatos}
dat()
usr <- function(){"CMEDINA"}
