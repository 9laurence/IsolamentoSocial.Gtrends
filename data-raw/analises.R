library(tidyverse)

# Trazendo o processamento dos dados que foi feito no dados.R
source("data-raw/dados.R")

####Dados SP####
# Inspecao visual dos dados
dados_sp %>%
  ggplot(aes(x = google_trends, y = indice_isolamento)) +
  geom_point()

# Dados de isolamento apontam para intermitencia por conta de
# finais de semana (pontos abaixo de 45 no eixo y), Por conta disso,
# retiramos esses dados para as analises
dados_sp2 <- dados_sp %>% filter(indice_isolamento > 45)

# Verificando a normalidade dos dados do google trends e do isolamento
# social
dados_sp2 %>% select_if(is.numeric) %>%
  map(., shapiro.test) %>%
  map_df(broom::tidy) %>%
  unnest(c(1:3)) %>%
  mutate(variavel = colnames(select_if(dados_sp2, is.numeric))) %>%
  relocate(variavel)

# Dados nao apresentam normalidade, por conta disso sera usado o Coeficiente
# de correlação de postos de Spearman
# Dados cortados
cor.test(dados_sp2$google_trends, dados_sp2$indice_isolamento,
         method = "spearman")

# Dados inteiros
cor.test(dados_sp$google_trends, dados_sp$indice_isolamento,
         method = "spearman")

# Analise visual da correlacao
dados_sp2 %>%
  ggplot(aes(x = google_trends, y = indice_isolamento)) +
  geom_point()+
  geom_smooth(method = lm, color = "red", fill = "red")+
  labs(x = "Pesquisas no Google pelo termo 'coronavirus'",
       y = "Indice de Isolamento Social em SP",
       title = "Scatter plot entre as pesquisas no Google por 'coronavirus' e o Indice de
       Isolamento Social no estado de SP")+
  theme_classic()
ggsave("data/scatterplot_sp.jpg")

# Analise visual atraves do tempo
# Analise visual da correlacao
dados_sp2 %>%
  rename(pesquisas_google_coronavirus = google_trends) %>%
  pivot_longer(-date, names_to = "dado") %>%
  ggplot(aes(x = date, y = value, color = dado)) +
  geom_line()+
  labs(x = "Dias",
       y = "",
       title = "Indice de isolamento social e pesquisas no Google atraves do tempo",
       color = "Dado",
       caption = "Linha pontilhada indica inicio da quarentena.")+
  geom_vline(xintercept = as.numeric(dados_sp2$date[7]), linetype = 2)+
  scale_color_manual(values = c("#ed1c24","#4285F4"))+
  theme_classic()+
  theme(legend.position = "bottom")
ggsave("data/time_series_sp.jpg")


# Regressao linear
sink("data/lm_sp.txt")
print(lm(indice_isolamento ~ google_trends, data = dados_sp2) %>% summary())
sink()

# O R2 indica que 21.34% da variacao no isolamento se deve pela quantidade
# de buscas no google trends





####Dados Brasil####
# Inspecao visual dos dados
dados_br %>%
  ggplot(aes(x = google_trends, y = apple_mobility)) +
  geom_point()

# Verificando a normalidade dos dados do google trends e do isolamento
# social
dados_br %>% select_if(is.numeric) %>%
  map(., shapiro.test) %>%
  map_df(broom::tidy) %>%
  unnest(c(1:3)) %>%
  mutate(variavel = colnames(select_if(dados_br, is.numeric))) %>%
  relocate(variavel)

# Dados nao apresentam normalidade, por conta disso sera usado o Coeficiente
# de correlação de postos de Spearman
cor.test(dados_br$google_trends, dados_br$apple_mobility,
         method = "spearman")

# Analise visual da correlacao
dados_br %>%
  ggplot(aes(x = google_trends, y = apple_mobility)) +
  geom_point()+
  geom_smooth(method = lm, color = "red", fill = "red")+
  labs(x = "Pesquisas no Google pelo termo 'coronavirus'",
       y = "Apple mobility no BR",
       title = "Scatter plot entre as pesquisas no Google por coronavirus e o Apple mobility
       no Brasil")+
  theme_classic()
ggsave("data/scatterplot_br.jpg")

# Analise visual atraves do tempo
# Analise visual da correlacao
dados_br %>%
  rename(pesquisas_google_coronavirus = google_trends) %>%
  pivot_longer(-date, names_to = "dado") %>%
  ggplot(aes(x = date, y = value, color = dado)) +
  geom_line()+
  labs(x = "Dias",
       y = "",
       title = "Apple mobility e pesquisas no Google atraves do tempo",
       color = "Dado",
       caption = "Linha pontilhada indica primeiro caso de COVID-19 no Brasil.
       Linha solida indica momento que transmissao comunitaria foi detectada no Brasil.")+
  geom_vline(xintercept = as.numeric(dados_br$date[45]), linetype = 2)+
  geom_vline(xintercept = as.numeric(dados_br$date[64]), linetype = 1)+
  scale_color_manual(values = c("#666666","#4285F4"))+
  theme_classic()+
  theme(legend.position = "bottom")
ggsave("data/time_series_br.jpg")


# Regressao linear
sink("data/lm_br.txt")
print(lm(apple_mobility ~ google_trends, data = dados_br) %>% summary())
sink()

# O R2 indica que 32.48% da variacao no isolamento se deve pela quantidade
# de buscas no google trends
