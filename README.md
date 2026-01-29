# Projekt - Bazy danych 

## 1. Spis użytych technologii

* Python (wersja 3.12.3)

    * Biblioteki i moduły: `SQLAlchemy`, `faker`, `pymysql`, `random`, `urllib`

* R (wersja 4.5.1)

    * Pakiety: `RMariaDB`, `knitr`

## 2. Lista plików

* `README.md` - dokumentacja
* `IHRF_Database.sql` - plik tworzący schemat bazy danych w SQL
* `schemat.json.vuerd` - schemat ERD bazy danych
* `main.py` - główny plik wypełniający skryptowo bazę danych
* `database_seeder.py` - plik zaierający definicje klasy, która generuje dane dla każdej tabeli

Pliki pomocnicze zawierające definicje klas używanych przy skryptowym wypełnianiu bazy:
* `Base.py`
* `Competition.py`
* `Cost.py`
* `Discipline.py`
* `DopingTest.py`
* `Employee.py`
* `Financing.py`
* `Hamster.py`
* `Owner.py`
* `Participation.py`
* `Sponsor.py`
* `SponsorshipContract.py`


## 3. Instrukcja uruchamiania

1. skompilowanie pliku `IHRF_Database.sql`
2. uruchomienie pliku `main.py`
3. 



## 5. Lista zależności funkcyjnych dla każdej relacji


### 1. Tabela `employees`

**Klucze kandydujące:**
* $\{employee\_id\}$
* $\{email\}$
* $\{phone\}$

**Lista Zależności Funkcyjnych:**
1. $employee\_id \to \{first\_name, last\_name, birth\_date, email, phone, address, hire\_date, position, employment\_type, salary, is\_active\}$
2. $email \to \{employee\_id, first\_name, last\_name, birth\_date, phone, address, hire\_date, position, employment\_type, salary, is\_active\}$
3. $phone \to \{employee\_id, first\_name, last\_name, birth\_date, email, address, hire\_date, position, employment\_type, salary, is\_active\}$

**Wyjaśnienie:**
$\{employee\_id\}$, $\{email\}$ oraz $\{phone\}$ są unikalne, więc pozwalają jednoznacznie identyfikować krotki relacji.


### 2. Tabela `sponsors`

**Klucze kandydujące:**
* $\{sponsor\_id\}$
* $\{tax\_number\}$

**Lista Zależności Funkcyjnych:**
1. $sponsor\_id \to \{company\_name, tax\_number, country, city, rep\_first\_name, rep\_last\_name, rep\_email, rep\_phone\}$
2. $tax\_number \to \{sponsor\_id, company\_name, country, city, rep\_first\_name, rep\_last\_name, rep\_email, rep\_phone\}$

**Wyjaśnienie:**
$\{sponsor\_id\}$, $\{tax\_number\}$ muszą być unikalne, więc pozwalają jednoznacznie identyfikować dane.

### 3. Tabela `sponsorship_contracts`

**Klucze kandydujące:**
* $\{contract\_id\}$

**Lista Zależności Funkcyjnych:**
1. $contract\_id \to \{sponsor\_id, start\_date, end\_date, contract\_value, offer\_type\}$

**Wyjaśnienie:**
$\{contract\_id\}$ jest jedynym unikalnym atrybutem.


### 4. Tabela `financings`

**Klucze kandydujące:**
* $\{financing\_id\}$

**Lista Zależności Funkcyjnych:**
1. $financing\_id \to \{source, value, income\_date\}$

**Wyjaśnienie:**
Tylko $\{financing\_id\}$ pozwala określić kiedy, skąd i ile pierniędzy otrzymała Federacja.

### 5. Tabela `costs`

**Klucze kandydujące:**
* $\{cost\_id\}$

**Lista Zależności Funkcyjnych:**
1. $cost\_id \to \{year, value\}$

**Wyjaśnienie:**
$\{cost\_id\}$ jest jedynym atrybutem, który może odróżniać rok i wartość kosztów.


### 6. Tabela `owners`

**Klucze kandydujące:**
* $\{owner\_id\}$

**Lista Zależności Funkcyjnych:**
1. $owner\_id \to \{first\_name, last\_name, wealth\_rating\}$

**Wyjaśnienie:**
$\{owner\_id\}$ jest jedynym unikalnym atrybutem.


### 7. Tabela `hamsters`

**Klucze kandydujące:**
* $\{hamster\_id\}$

**Lista Zależności Funkcyjnych:**
1. $hamster\_id \to \{name, race, weight, birth\_date, death\_date, specialty, owner\_id\}$

**Wyjaśnienie:**
Chociaż `owner_id` jest kluczem obcym, nie implikuje on unikalności chomika. Jedyną zależnością funkcyjną jest zależność wszystkich atrybutów od `hamster_id`.


### 8. Tabela `disciplines`

**Klucze kandydujące:**
* $\{discipline\_id\}$
* $\{name\}$

**Lista Zależności Funkcyjnych:**
1. $discipline\_id \to \{name, category, surface, distance\}$
2. $name \to \{discipline\_id, category, surface, distance\}$

**Wyjaśnienie:**
$\{name\}$ zawiera informacje o kategorii, nawierzchni oraz dystansie, ale jest unikatowa, zatem jest też kluczem kandydującym.


### 9. Tabela `competitions`

**Klucze kandydujące:**
* $\{competition\_id\}$

**Lista Zależności Funkcyjnych:**
1. $competition\_id \to \{discipline\_id, name, date, time, city, spectators\}$

**Wyjaśnienie:**
Wszystkie atrybuty (gdzie, kiedy, co) opisują konkretne zawody identyfikowane przez ID.


### 10. Tabela `participations`

**Klucze kandydujące:**
* $\{participation\_id\}$

**Lista Zależności Funkcyjnych:**
1. $participation\_id \to \{competition\_id, hamster\_id, place, disqualified\}$

**Wyjaśnienie:**
Chomiki mogą brać udział w różnych zawodach i zdobywać różne miejsca - nie ma między tymi informacjami żdanych zależności.


### 11. Tabela `doping_tests`

**Klucze kandydujące:**
* $\{test\_id\}$

**Lista Zależności Funkcyjnych:**
1. $test\_id \to \{employee\_id, participation\_id, substance\_name, positive\}$

**Wyjaśnienie:**
Każdy test jest osobnym bytem. Wynik zależy od konkretnego pobrania próbki.


## 6.Uzasadnienie, że baza jest w EKNF:

Baza danych jest w postaci normalnej normalna EKNF, jeśli każda nietrywialna zależność funkcyjna albo zaczyna się od klucza kandydującego albo kończy się na atrybucie elementarnym.
Jak widzimy z powyższej listy zależności funkcyjnych - każda z nich zaczyna się od klucza kandydującego, zatem stworzona baza jest w postaci normalnej EKNF.

## 7. Co było najtrudniejsze?

* Interpretacja oraz ułożenie odpowiednich zapytań w SQL do pytań z części 3.
* Zautomatyzowanie generowania danych, które mają sens logiczny i spełniają założenia projektu.
* 