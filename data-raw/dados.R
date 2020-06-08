library(tidyverse)
library(gtrendsR)

####Dados Distanciamento Social####
# Os dados escolhidos para distanciamento social foram os do estado de SP
# disponíveis nesse link: https://www.saopaulo.sp.gov.br/coronavirus/isolamento/
# e os dados da apple mobility https://www.apple.com/covid19/mobility
# Os dados já estão disponíveis no pacote. As datas escolhidas foram as seguintes:
# Gov SP: 2020-03-05, 2020-06-06
# Apple: 2020-01-13, 2020-06-06

# Dados de SP foram carregados com o R base por conta de especificidades
# do dado baixado
indice_isolamento <- read.csv2("data-raw/Grafico_crosstab.csv",
                               skipNul = TRUE,
                               sep = "\t") %>%
  rename(data = 1, isolamento = 2) %>% # renomear colunas
  mutate(data = paste0(data,"/2020")) %>% # adicionar o ano na data
  mutate(data = lubridate::dmy(data), # mudar data para formato date
         isolamento = parse_number(as.character(isolamento))) # tirar porcentagem

# Dados Apple mobility
# O dado apresenta 3 tipos de dado por pais "driving", "walking" e "transit",
# respectivos a dados de motoristas, pessoas a pe e em transporte publico
# Para fins de analise, vamos fazer a media dessas medidas por dia.
# Alem disso, o dado conta com dados faltantes nos dias 11 e 12 de maio,
# por conta disso iremos fazer uma interpolacao linear entre os dias adjacentes
# para termos os dados completos
apple_mobility <- read_csv("data-raw/applemobilitytrends-2020-06-06.csv") %>%
  filter(region == "Brazil") %>% # pegar dados do Brasil
  select(region, 7:152) %>% # selecionar coluna regiao e colunas de dado de isolamento
  summarise_at(1:147, mean) %>% # fazer a media do driving, walking e transito por dia
  pivot_longer(-region, names_to = "data") %>% # transpor colunas para linhas
  mutate(value = zoo::na.approx(value)) %>% # interpolar dados faltantes
  mutate(region = "Brazil",
         data = lubridate::ymd(data))  # adicionar Brazil como regiao de novo


####Dados Google Trends####
# Pegar o google trends da palavra "coronavirus" para SP e para o Brasil
# para cruzar com os dados de isolamento social

# pegar dados SP entre 2020-03-05 ate 2020-06-06
buscas_sp <- gtrends(keyword = "coronavirus",
             geo = c("BR-SP"), gprop = "web",
             time = "2020-03-05 2020-06-06")$interest_over_time



# pegar dados Brazil entre 2020-01-13 ate 2020-06-06
googlet_br <- gtrends(keyword = "coronavirus",
                      geo = c("BR"), gprop = "web",
                      time = "2020-01-13 2020-06-06")$interest_over_time

buscas_br <- googlet_br %>%
  mutate(hits = case_when(hits == "<1" ~ 0.5,
                          TRUE ~ as.numeric(as.character(.$hits)))) # converter o "<1" em 0.5 para usar como numérico


#####Juntando dados####
# Juntar os dados do estado de SP com o do google
# Foi usado inner_join uma vez que ha dados faltantes nos dados do
# estado de SP e nos do google trends
dados_sp <- buscas_sp %>% select(date, hits) %>%
  inner_join(indice_isolamento, by = c("date" = "data")) %>%
  rename(google_trends = hits,
         indice_isolamento = isolamento)

# Juntar os dados da apple mobility com os dados do google
# Foi usado o left_join uma vez que os dados da apple possuem uma linha a
# mais que os dados do google trends
dados_br <- buscas_br %>% select(date, hits) %>%
  left_join(apple_mobility, by = c("date" = "data")) %>%
  select(date,
         google_trends = hits,
         apple_mobility = value)


# Salvando dados processados na pasta data
write_csv2(dados_sp, "data/dados_sp.csv")
write_csv2(dados_br, "data/dados_br.csv")
