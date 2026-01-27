#instalacja pakietu potrzebnego do połączenia
install.packages("RMariaDB")

#wczytanie pakietu potrzebnego do połaczenia
library(RMariaDB)

#ustanowienie połaczenia z serwerem zajęciowym
con <- dbConnect(RMariaDB::MariaDB(),
                 dbname = "team10",
                 username = "team10",
                 password = "te@mzio",
                 host = "giniewicz.it")

# PYTANIE 1.
query <- "WITH Ranking AS (
    SELECT 
        d.category AS Kategoria,
        h.name AS Imie_Chomika,
        CONCAT(o.first_name, ' ', o.last_name) AS Wlasciciel,
        COUNT(*) AS Liczba_Zwyciestw,
        RANK() OVER (PARTITION BY d.category ORDER BY COUNT(*) DESC) as Pozycja
    FROM 
        participations p
    JOIN competitions c ON p.competition_id = c.competition_id
    JOIN disciplines d ON c.discipline_id = d.discipline_id
    JOIN hamsters h ON p.hamster_id = h.hamster_id
    JOIN owners o ON h.owner_id = o.owner_id
    WHERE 
        p.place = 1 AND p.disqualified = 0
    GROUP BY 
        d.category, h.hamster_id
)
SELECT * FROM Ranking WHERE Pozycja = 1;"

#zapisanie uzyskanego wyniku, który jest ramką danych pod zmienną
df <- dbGetQuery(con, query)

#Sprawdzenie pierwszych obserwacji, aby nie wyświetlać całej tabeli
head(df)

#Podsumowanie dotyczące ramki danych
summary(df)

#Zamknięcie połączenia
dbDisconnect(con)

#Komendy działające na zapisanej ramce danych dalej działają
head(df)


query2 <- "SELECT 
    ROUND(AVG(DATEDIFF(ostatnia_wygrana, pierwsza_wygrana)), 0) AS Srednia_Dlugosc_Szczytu_Dni,
    MAX(DATEDIFF(ostatnia_wygrana, pierwsza_wygrana)) AS Rekordowa_Dlugosc_Dni
FROM (
    SELECT 
        p.hamster_id,
        MIN(c.date) as pierwsza_wygrana,
        MAX(c.date) as ostatnia_wygrana
    FROM participations p
    JOIN competitions c ON p.competition_id = c.competition_id
    WHERE p.place = 1 AND p.disqualified = 0
    GROUP BY p.hamster_id
    HAVING COUNT(*) >= 2  
) AS statystyki_chomikow;"
df2 <- dbGetQuery(con, query2)


query3 <- "SELECT 
    -- W jakim wieku zazwyczaj zdobywa się złoto?
    ROUND(AVG(TIMESTAMPDIFF(MONTH, h.birth_date, c.date)), 1) AS Sredni_Wiek_Mistrza_Miesiace,
    
    -- Kiedy najwcześniej zaczynają wygrywać?
    MIN(TIMESTAMPDIFF(MONTH, h.birth_date, c.date)) AS Wiek_Wschodzacej_Gwiazdy,
    
    -- Kiedy najpóźniej wygrywają (koniec szczytu)?
    MAX(TIMESTAMPDIFF(MONTH, h.birth_date, c.date)) AS Wiek_Weterana
FROM participations p
JOIN competitions c ON p.competition_id = c.competition_id
JOIN hamsters h ON p.hamster_id = h.hamster_id
WHERE p.place = 1 AND p.disqualified = 0;"

df3 <- dbGetQuery(con, query3)

# PYTANIE 3.

# --- CZĘŚĆ 1: POPULARNOŚĆ (Trend w czasie) ---

# SQL: Grupujemy zawody po dacie i liczymy uczestników
query_pop <- "
SELECT 
    DATE_FORMAT(c.date, '%Y-%m-01') as Miesiac, -- Zaokrąglamy do 1. dnia miesiąca
    COUNT(p.participation_id) as Liczba_Uczestnikow
FROM participations p
JOIN competitions c ON p.competition_id = c.competition_id
GROUP BY Miesiac
ORDER BY Miesiac;
"
dane_trend <- dbGetQuery(con, query_pop)

# Konwersja kolumny Miesiac na format daty w R
dane_trend$Miesiac <- as.Date(dane_trend$Miesiac)

library(ggplot2)

# Wykres liniowy
ggplot(dane_trend, aes(x = Miesiac, y = Liczba_Uczestnikow)) +
  geom_line(color = "darkgreen", size = 1.2) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "dashed") + # Linia trendu
  labs(
    title = "Popularność sportu w czasie",
    subtitle = "Liczba startujących chomików miesięcznie",
    x = "Data",
    y = "Liczba startów"
  ) +
  theme_minimal()

# --- CZĘŚĆ 2: RENTOWNOŚĆ (Przychody vs Koszty) ---

# 1.
library(DBI)
library(dplyr)
library(ggplot2)


# 2. 
# Używamy COALESCE(kolumna, 0), żeby zamienić NULL na 0 już na etapie pobierania
query_fin <- "
SELECT year(income_date) as Rok, COALESCE(value_gbp, 0) as Kwota, 'Inne' as Typ FROM financings
UNION ALL
SELECT year(start_date) as Rok, COALESCE(contract_value_gbp, 0) as Kwota, 'Sponsoring' as Typ FROM sponsorship_contracts
UNION ALL
SELECT year as Rok, -COALESCE(value_gbp, 0) as Kwota, 'Koszty' as Typ FROM costs
"
dane_fin <- dbGetQuery(con, query_fin)

# 3. 
bilans_roczny <- dane_fin %>%
  filter(!is.na(Rok)) %>% # Usuwamy ewentualne wpisy bez daty
  group_by(Rok) %>%
  # Dodajemy na.rm = TRUE jako drugie zabezpieczenie
  summarise(Wynik_Finansowy = sum(Kwota, na.rm = TRUE)) %>%
  mutate(Status = ifelse(Wynik_Finansowy > 0, "Zysk", "Strata"))

# Wyłączamy notację naukową dla osi Y
options(scipen = 999)

# 4. Rysowanie wykresu
ggplot(bilans_roczny, aes(x = factor(Rok), y = Wynik_Finansowy, fill = Status)) +
  geom_col(width = 0.6) +
  scale_fill_manual(values = c("Zysk" = "forestgreen", "Strata" = "firebrick")) +
  geom_text(aes(label = round(Wynik_Finansowy, 0)), 
            vjust = ifelse(bilans_roczny$Wynik_Finansowy >= 0, -0.5, 1.5),
            fontface = "bold", 
            size = 3.5) + # Trochę mniejsza czcionka, żeby się zmieściło
  labs(
    title = "Bilans roczny federacji",
    x = "Rok",
    y = "Wynik finansowy (GBP)"
  ) +
  theme_minimal()


# --- CZĘŚĆ 3: ATRAKCYJNOŚĆ DLA WIDZÓW ---

# Średnia liczba widzów na zawodach danej kategorii
query_widzowie <- "
SELECT 
    d.category as Kategoria,
    d.name as Dyscyplina,
    c.spectators as Liczba_Widzow
FROM competitions c
JOIN disciplines d ON c.discipline_id = d.discipline_id
"
dane_widownia <- dbGetQuery(con, query_widzowie)

# Wykres pudełkowy (pokazuje rozkład widowni)
ggplot(dane_widownia, aes(x = Kategoria, y = Liczba_Widzow, fill = Kategoria)) +
  geom_boxplot() +
  geom_jitter(width = 0.2, alpha = 0.3) + # Dodaje punkty, żeby widzieć poszczególne zawody
  labs(
    title = "Co przyciąga tłumy?",
    subtitle = "Rozkład liczby widzów w zależności od kategorii",
    x = "Kategoria",
    y = "Liczba widzów na zawodach"
  ) +
  theme_minimal()

#Ważna uwaga dot. danych: O ile widzów (spectators) mamy przypisanych do zawodów (czyli do kategorii), o tyle sponsorzy nie są przypisani do kategorii! Tabela sponsorship_contracts nie łączy się z disciplines. 




















