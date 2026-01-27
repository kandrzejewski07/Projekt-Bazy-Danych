# instalacja (tylko raz, w konsoli)
# install.packages("RMariaDB")

library(RMariaDB)

# POŁĄCZENIE Z WASZĄ BAZĄ
con <- dbConnect(
  RMariaDB::MariaDB(),
  dbname   = "team10",
  user     = "team10",
  password = "te@mzio",
  host     = "giniewicz.it",
  port     = 3306
)

# Pytanie 2.

# podział na kategorie, które dają przewagę bogatym

df1 <- dbGetQuery(con, "
WITH owner_category_perf AS (
  SELECT
    o.owner_id,
    o.wealth_rating,
    d.category,
    COUNT(*) AS starts,
    AVG(CASE WHEN p.disqualified = 0 AND p.place IS NOT NULL THEN p.place END) AS avg_place,
    AVG(CASE WHEN p.disqualified = 0 AND p.place = 1 THEN 1 ELSE 0 END) AS win_rate,
    AVG(CASE WHEN p.disqualified = 0 AND p.place <= 3 THEN 1 ELSE 0 END) AS podium_rate
  FROM owners o
  JOIN hamsters h       ON h.owner_id = o.owner_id
  JOIN participations p ON p.hamster_id = h.hamster_id
  JOIN competitions c   ON c.competition_id = p.competition_id
  JOIN disciplines d    ON d.discipline_id = c.discipline_id
  GROUP BY o.owner_id, o.wealth_rating, d.category
),
owner_category_grouped AS (
  SELECT
    owner_id,
    category,
    wealth_rating,
    starts,
    avg_place,
    win_rate,
    podium_rate,
    CASE
      WHEN wealth_rating <= 3 THEN 'biedni (1-3)'
      WHEN wealth_rating <= 7 THEN 'sredni (4-7)'
      ELSE 'bogaci (8-10)'
    END AS wealth_group
  FROM owner_category_perf
)
SELECT
  category,
  wealth_group,
  COUNT(*) AS owners,
  SUM(starts) AS starts_total,
  AVG(avg_place) AS avg_place_mean,
  AVG(win_rate) AS win_rate_mean,
  AVG(podium_rate) AS podium_rate_mean
FROM owner_category_grouped
WHERE avg_place IS NOT NULL
GROUP BY category, wealth_group
ORDER BY category,
  FIELD(wealth_group, 'biedni (1-3)', 'sredni (4-7)', 'bogaci (8-10)');
")
head(df1)


# podział na dyscypliny, które dają przewagę bogatym

df2 <- dbGetQuery(con, "
WITH owner_discipline_perf AS (
  SELECT
  o.owner_id,
  o.wealth_rating,
  d.discipline_id,
  d.name AS discipline_name,
  d.category,
  COUNT(*) AS starts,
  AVG(CASE WHEN p.disqualified = 0 AND p.place IS NOT NULL THEN p.place END) AS avg_place
  FROM owners o
  JOIN hamsters h       ON h.owner_id = o.owner_id
  JOIN participations p ON p.hamster_id = h.hamster_id
  JOIN competitions c   ON c.competition_id = p.competition_id
  JOIN disciplines d    ON d.discipline_id = c.discipline_id
  GROUP BY o.owner_id, o.wealth_rating, d.discipline_id, d.name, d.category
),
grouped AS (
  SELECT
  discipline_id,
  discipline_name,
  category,
  owner_id,
  CASE
  WHEN wealth_rating <= 3 THEN 'biedni'
  WHEN wealth_rating >= 8 THEN 'bogaci'
  ELSE NULL
  END AS wealth_group,
  avg_place
  FROM owner_discipline_perf
  WHERE avg_place IS NOT NULL
),
agg AS (
  SELECT
  discipline_id,
  discipline_name,
  category,
  COUNT(DISTINCT CASE WHEN wealth_group = 'biedni' THEN owner_id END) AS poor_owners,
  COUNT(DISTINCT CASE WHEN wealth_group = 'bogaci' THEN owner_id END) AS rich_owners,
  AVG(CASE WHEN wealth_group = 'biedni' THEN avg_place END) AS avg_place_poor,
  AVG(CASE WHEN wealth_group = 'bogaci' THEN avg_place END) AS avg_place_rich
  FROM grouped
  WHERE wealth_group IS NOT NULL
  GROUP BY discipline_id, discipline_name, category
)
SELECT
discipline_id,
discipline_name,
category,
poor_owners,
rich_owners,
avg_place_poor,
avg_place_rich,
(avg_place_poor - avg_place_rich) AS advantage_rich
FROM agg
WHERE poor_owners >= 2
AND rich_owners >= 2
ORDER BY advantage_rich DESC
LIMIT 5;")
head(df2)

# 4 dodatkowe pytania

# jak miesiąc urodzenia wpływa na wynik?

df3 <- dbGetQuery(con, "
SELECT
MONTHNAME(h.birth_date) AS birth_month,
COUNT(*) AS starts,
AVG(CASE 
    WHEN p.disqualified = 0 
    AND p.place IS NOT NULL 
    THEN p.place 
    END) AS avg_place
FROM hamsters h
JOIN participations p ON p.hamster_id = h.hamster_id
GROUP BY birth_month
HAVING starts >= 10
ORDER BY avg_place ASC;")
head(df3)


# jeśli właściciel ma więcej chomików to czy jego chomiki są lepsze?

df4 <- dbGetQuery(con, "
WITH owner_stats AS (
  SELECT
    o.owner_id,
    COUNT(DISTINCT h.hamster_id) AS hamster_count,
    COUNT(p.participation_id) AS starts,
    AVG(CASE WHEN p.disqualified = 0 AND p.place IS NOT NULL THEN p.place END) AS avg_place
  FROM owners o
  JOIN hamsters h       ON h.owner_id = o.owner_id
  JOIN participations p ON p.hamster_id = h.hamster_id
  GROUP BY o.owner_id
),
grouped AS (
  SELECT
    hamster_count,
    COUNT(*) AS owners,
    SUM(starts) AS starts_total,
    AVG(avg_place) AS mean_avg_place
  FROM owner_stats
  WHERE avg_place IS NOT NULL
  GROUP BY hamster_count
)
SELECT *
FROM grouped
ORDER BY hamster_count;")
head(df4)


# czy waga chomika wpływa na wyniki?

df5 <- dbGetQuery(con, "
WITH perf AS (
  SELECT
    h.hamster_id,
    h.weight_grams,
    p.disqualified,
    p.place
  FROM hamsters h
  JOIN participations p ON p.hamster_id = h.hamster_id
  WHERE h.weight_grams IS NOT NULL
)
SELECT
  CONCAT(FLOOR(weight_grams / 20) * 20, '-', FLOOR(weight_grams / 20) * 20 + 19) AS weight_bin,
  COUNT(*) AS starts_total,
  COUNT(DISTINCT hamster_id) AS hamsters,
  AVG(CASE WHEN disqualified = 0 AND place IS NOT NULL THEN place END) AS avg_place,
  AVG(CASE WHEN disqualified = 0 AND place = 1 THEN 1 ELSE 0 END) AS win_rate,
  AVG(CASE WHEN disqualified = 0 AND place <= 3 THEN 1 ELSE 0 END) AS podium_rate
FROM perf
GROUP BY weight_bin
HAVING starts_total >= 20
ORDER BY avg_place ASC;")

head(df5)


# czy konkretne specjalności (specialty) dają przewagę w wynikach?

df6 <- dbGetQuery(con, "
SELECT
  COALESCE(h.specialty, 'brak_specialty') AS specialty,
  COUNT(*) AS starts_total,
  COUNT(DISTINCT h.hamster_id) AS hamsters,
  AVG(CASE WHEN p.disqualified = 0 AND p.place IS NOT NULL THEN p.place END) AS avg_place,
  AVG(CASE WHEN p.disqualified = 0 AND p.place = 1 THEN 1 ELSE 0 END) AS win_rate,
  AVG(CASE WHEN p.disqualified = 0 AND p.place <= 3 THEN 1 ELSE 0 END) AS podium_rate
FROM hamsters h
JOIN participations p ON p.hamster_id = h.hamster_id
GROUP BY specialty
HAVING starts_total >= 20
ORDER BY avg_place ASC;")

head(df6)

# ROZŁĄCZENIE
dbDisconnect(con)