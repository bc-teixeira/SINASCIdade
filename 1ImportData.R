library(read.dbc)
library(tidyverse)
library(lubridate)
library(svMisc)


#Mudar para o diretório onde estão guardados os DBCs
filesdirectory <- "D:/DATASUS/SINASC/Dados/"

#Captura arquivos que iniciam com PA
files <- dir(filesdirectory, pattern = "^DN.*dbc$")

#Anos a serem incluidos na análise
incyears <- c(c(1996:2000), c(2015:2019))

#inclui somente arquivos de anos especificados
files <- files[as.numeric(substr(files, 5,8))%in% incyears]

#Cria vetor para guardar os dados
SINASC <- vector(mode = "list", length = length(files))

t <- Sys.time()
#Loop nos arquivos
for (i in 1:length(files)){
  SINASC[[i]] <-  read.dbc(paste0(filesdirectory, files[i]), as.is = TRUE) %>% 
    select(IDADEMAE, QTDFILVIVO, DTNASC, CODMUNRES) %>% 
    mutate(DTNASC = dmy(DTNASC), 
           UFRES = substr(CODMUNRES, 1,2)) %>% 
    select(-CODMUNRES)
  
  progress(i, max.value = length(files))                                 #Barra de progressão para acompanhar status do processo
}


SINASC <- plyr::rbind.fill(SINASC) %>% as_tibble()
print(paste0("Run time: ", as.numeric(Sys.time()-t,units = "secs") , " sec"))


UFs <- read_csv2("Estados e regioes.csv")

SINASC <- SINASC %>% 
  mutate(ano = year(DTNASC),
         IDADEMAE = as.numeric(IDADEMAE),
         QTDFILVIVO = as.numeric(QTDFILVIVO),
         UFRES = as.numeric(UFRES),
         GRPANO = if_else(ano < 2005, "1996 a 2000", "2015 a 2019")) %>% 
  left_join(UFs %>% select(codigo_uf, UF = estado_abre), by = c("UFRES" = "codigo_uf")) %>% 
  select(-UFRES)

rm(UFs, files, filesdirectory, incyears, t)
