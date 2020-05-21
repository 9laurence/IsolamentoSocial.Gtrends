library(gtrendsR)

# Site com dados de isolamento: https://www.saopaulo.sp.gov.br/coronavirus/isolamento/

# Link com o arquivo dos dados de isolamento do estado de SP
link <- "https://public.tableau.com/vizql/w/IsolamentoSocial/v/DADOS/vudcsv/sessions/E004A10FF26A493CB41A44D7A1C641C3-0:0/views/1292535119418963567_2497449162794898547?summary=true"
link <- "https://public.tableau.com/vizql/w/IsolamentoSocial/v/DADOS/vudcsv/sessions/44866EA797894FBABA34BE2C187D4A8F-0:0/views/1292535119418963567_2497449162794898547?summary=true"
download.file(link, "data-raw/isolamento_sp.csv")

x <- gtrends(keyword = "coronavirus",
             geo = c("BR-SP"), gprop = "web",
             time = "2020-03-05 2020-05-19")

x$interest_by_region

buscas <- x$interest_over_time

query_d <- list(maxrows = 200)
x <- httr::GET("https://public.tableau.com/vizql/w/IsolamentoSocial/v/Dashboard/viewData/sessions/1F538E53F9544645B219FBEC0B627CAF-0:0/views/1292535119418963567_2497449162794898547?maxrows=200&viz=%7B%22worksheet%22%3A%22Dados%22%2C%22dashboard%22%3A%22DADOS%22%7D",
                query = query_d)
x2 <- httr::content(x, "raw")
writeBin(x2, "d.csv")
