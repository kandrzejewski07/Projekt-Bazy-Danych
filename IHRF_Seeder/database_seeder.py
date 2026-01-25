from datetime import datetime, timedelta, time, date
from random import choice, randint
from dateutil.relativedelta import relativedelta
from unidecode import unidecode

from faker import Faker
from sqlalchemy import text

from entities import *
from entities.Discipline import Surface, Category


class DatabaseSeeder:
    def __init__(self, session):
        self.session = session
        self.faker = Faker("en_GB")
        self.random = randint

    def seed(self):
        self.session.execute(text("DELETE FROM doping_tests"))
        self.session.execute(text("DELETE FROM sponsorship_contracts"))
        self.session.execute(text("DELETE FROM participations"))
        self.session.execute(text("DELETE FROM competitions"))
        self.session.execute(text("DELETE FROM disciplines"))
        self.session.execute(text("DELETE FROM employees"))
        self.session.execute(text("DELETE FROM hamsters"))
        self.session.execute(text("DELETE FROM sponsors"))
        self.session.execute(text("DELETE FROM financings"))
        self.session.execute(text("DELETE FROM costs"))
        self.session.execute(text("DELETE FROM owners"))
        self.session.execute(text("ALTER TABLE doping_tests AUTO_INCREMENT = 1"))
        self.session.execute(text("ALTER TABLE sponsorship_contracts AUTO_INCREMENT = 1"))
        self.session.execute(text("ALTER TABLE participations AUTO_INCREMENT = 1"))
        self.session.execute(text("ALTER TABLE competitions AUTO_INCREMENT = 1"))
        self.session.execute(text("ALTER TABLE disciplines AUTO_INCREMENT = 1"))
        self.session.execute(text("ALTER TABLE employees AUTO_INCREMENT = 1"))
        self.session.execute(text("ALTER TABLE hamsters AUTO_INCREMENT = 1"))
        self.session.execute(text("ALTER TABLE sponsors AUTO_INCREMENT = 1"))
        self.session.execute(text("ALTER TABLE financings AUTO_INCREMENT = 1"))
        self.session.execute(text("ALTER TABLE costs AUTO_INCREMENT = 1"))
        self.session.execute(text("ALTER TABLE owners AUTO_INCREMENT = 1"))
        # owners = self.create_owners(100)
        # hamsters = self.create_hamsters(1000, owners)
        employees = self.create_employees(100)
        # sponsors = self.create_sponsors(100)
        # disciplines = self.create_disciplines(100)
        # financings = self.create_financings(100)
        # costs = self.create_costs()
        # competitions = self.create_competitions(100, disciplines)
        # sponsorship_contracts = self.create_sponsorship_contracts(100, sponsors)
        # participations = self.create_participations(5, 20, competitions, hamsters)
        # doping_tests = self.create_doping_tests(100, participations, employees, competitions)
        # self.fix_results_when_disqualifed(participations)

    def create_owners(self, count):
        faker_languages = ['it_IT', 'en_GB', 'pl_PL', 'fr_FR', 'de_DE']

        owners = []

        for _ in range(count):
            single_country_faker = Faker(locale=self.faker.random_element(faker_languages))
            owner = Owner(
                first_name = single_country_faker.first_name(),
                last_name = single_country_faker.last_name(),
                wealth_rating = self.random(1, 10)
            )
            owners.append(owner)
            
        self.session.add_all(owners)
        self.session.commit()
        return(owners)

    def create_hamsters(self, count, owners):
        faker_names = Faker(['it_IT', 'en_GB', 'pl_PL', 'fr_FR', 'de_DE'])

        races = ['Syrian', 'Winter White', 'Roborovski', 'Chinese', 'Campbell\'s', 'European']
        
        specialties = ['Speed', 'Jumping', 'Strength', 'Stamina', 'Agility', 'Wisdom', None]

        hamsters = []
        for _ in range(count):
            birth_date = self.faker.date_between(start_date='-6y', end_date='-2m')
            death_date_min = birth_date + relativedelta(months = 2)
            death_date_max = birth_date + relativedelta(years = 3)
            death_date = self.faker.date_between(start_date = death_date_min, end_date = death_date_max)
            if death_date > date.today():
                death_date = None
                
            hamster = Hamster(
                name = faker_names.first_name(),
                race = self.faker.random_element(races),
                weight_grams = self.random(20, 200),
                birth_date = birth_date,
                death_date = death_date,
                specialty = self.faker.random_element(specialties),
                owner_id = self.faker.random_element(owners).owner_id
            )
            hamsters.append(hamster)
        
        self.session.add_all(hamsters)
        self.session.commit()
        return(hamsters)

    def create_employees(self, count):
        faker_languages = ['it_IT', 'en_GB', 'pl_PL', 'fr_FR', 'de_DE']

        positions = ['Store Manager', 'Sales Associate', 'Veterinarian', 
                     'Vet Technician', 'Cleaner', 'Stock Clerk', 
                     'Customer Support', 'Hamster Trainer', 'Accountant']
        
        employment_types = ['Full-time', 'Part-time', 'Contract', 'Internship', 'B2B']

        email_domains = ['gmail.com', 'yahoo.com', 'outlook.com']

        employees = []
        emails = []

        for _ in range(count):
            single_country_faker = Faker(locale=self.faker.random_element(faker_languages))
            birth_date = self.faker.date_of_birth(minimum_age=18, maximum_age=60)
            able_to_work_date = birth_date + relativedelta(years=18, months=1)
            hire_date = self.faker.date_between(start_date=able_to_work_date, end_date='today')
            hire_date = hire_date.replace(day=1)
            first_name = single_country_faker.first_name()
            last_name = single_country_faker.last_name()
            domain = self.faker.random_element(email_domains)
            email_base = unidecode(first_name + last_name).lower().replace(' ', '')
            email = (email_base + '@' + domain).lower()
            i = 1
            while email in emails:
                email = (email_base + str(i) + '@' + domain).lower()
                i += 1
            emails.append(email)

            employee = Employee(
                first_name = first_name,
                last_name = last_name,
                birth_date = birth_date,
                
                email = email,
                phone = self.faker.unique.phone_number(),
                address = self.faker.address().replace('\n', ', '),
                
                hire_date = hire_date,
                position = self.faker.random_element(positions),
                employment_type = self.faker.random_element(employment_types),
                
                salary_gbp = self.random(20, 100) * 100,
                
                is_active = self.faker.boolean(chance_of_getting_true=90)
            )
            employees.append(employee)
        # Always one loyal Veterinarian, for the purposes of doping-tests
        employee.is_active = 1
        employee.position = 'Veterinarian'
        employee.birth_date = date.today() - relativedelta(years=40)
        employee.hire_date = date.today() - relativedelta(years=10)
        
        self.session.add_all(employees)
        self.session.commit()
        return(employees)
    
    def create_sponsors(self, count):
        faker_languages = ['it_IT', 'en_GB', 'pl_PL', 'fr_FR', 'de_DE']

        email_domains = ['gmail.com', 'yahoo.com', 'outlook.com']

        sponsors = []
        emails = []

        for _ in range(count):
            language = self.faker.random_element(faker_languages)
            single_country_faker = Faker(language)
            match language:
                case 'it_IT':
                    country = 'Italy'
                case 'en_GB':
                    country = 'Great Britain'
                case 'pl_PL':
                    country = 'Poland'
                case 'fr_FR':
                    country = 'France'
                case 'de_DE':
                    country = 'Germany'
            rep_first_name = single_country_faker.first_name()
            rep_last_name = single_country_faker.last_name()
            domain = self.faker.random_element(email_domains)
            email_base = unidecode(rep_first_name + rep_last_name).lower().replace(' ', '')
            email = (email_base + '@' + domain).lower()
            i = 1            
            while email in emails:
                email = (email_base + str(i) + '@' + domain).lower()
                i += 1
            emails.append(email)

            sponsor = Sponsor(
                company_name = single_country_faker.company(),

                tax_number = self.faker.unique.bothify(text=language.split('_')[1]+'#########'),
                
                country = country,
                city = single_country_faker.city(),

                rep_first_name = rep_first_name,
                rep_last_name = rep_last_name,
                
                rep_email = email,
                rep_phone = single_country_faker.phone_number()
            )
            sponsors.append(sponsor)
        
        self.session.add_all(sponsors)
        self.session.commit()
        return(sponsors)

    def create_disciplines(self, count):
        disciplines = []
        names = []
        for _ in range(count):
            while True:
                category = self.faker.random_element(list(Category))
                surface = self.faker.random_element(list(Surface))
                distance = self.random(2, 50) * 10
                hurdles = self.faker.boolean(10)
                if hurdles:
                    type = 'Hurdles'
                else:
                    if distance <= 100:
                        type = 'Sprint'
                    elif distance > 100 and distance <= 300:
                        type = 'Race'
                    else:
                        type = 'Marathon'
                name = f"{category.value} {surface.value} {distance}m {type}"
                if name not in names:
                    names.append(name)
                    break

            discipline = Discipline(
                name = name,
                category = category,
                surface = surface,
                distance = distance
            )

            disciplines.append(discipline)
        
        self.session.add_all(disciplines)
        self.session.commit()
        return(disciplines)

    def create_financings(self, count):
        streams = { 'Ticket Sales': (500, 15000),           
                    'Merchandise Store': (100, 3000),       
                    'VIP Box Rental': (2000, 8000),         
                    'TV Broadcast Rights': (15000, 150000), 
                    'Streaming Subscriptions': (1000, 5000),
                    'Betting Commission': (500, 25000),     
                    'Government Grant': (10000, 50000),     
                    'Private Donation': (50, 1000) }

        financings = []

        for _ in range(count):
            stream = self.faker.random_element(list(streams.keys()))
            min_val, max_val = streams[stream]
            min_val *= 100
            max_val *= 100

            financing = Financing(
                source = stream,
                value_gbp = self.random(min_val, max_val) / 100,
                income_date = self.faker.date_between(start_date='-5y', end_date='today')
            )

            financings.append(financing)
                
        self.session.add_all(financings)
        self.session.commit()
        return(financings)

    def create_costs(self):
        years = [2020, 2021, 2022, 2023, 2024, 2025]

        costs = []

        for year in years:
            cost = Cost(
                year = year,
                value_gbp = self.random(30000000, 50000000) / 100
            )
            costs.append(cost)

        self.session.add_all(costs)
        self.session.commit()
        return(costs)

    def create_competitions(self, count, disciplines):
        surface_keywords = {
            Surface.Tarmac: ['Street', 'Speedway', 'Circuit', 'Urban', 'Metro', 'Grand Prix'],
            Surface.Gravel: ['Rocky', 'Mountain', 'Canyon', 'Offroad', 'Dusty', 'Quarry'],
            Surface.Sand:   ['Dune', 'Sahara', 'Desert', 'Beach', 'Pharaoh', 'Oasis'],
            Surface.Ice:    ['Frozen', 'Arctic', 'Glacier', 'Polar', 'Slippery', 'Frost'],
            Surface.Snow:   ['Alpine', 'Blizzard', 'Winter', 'Yeti', 'Avalanche', 'Nordic']
        }

        suffixes = ['Dash', 'Challenge', 'Cup', 'Masters', 'Invitational', 'Trophy', 'Open']

        competitions = []

        for _ in range(count):
            faker_names = Faker(['it_IT', 'en_GB', 'pl_PL', 'fr_FR', 'de_DE'])

            discipline = self.faker.random_element(disciplines)
            keywords = surface_keywords.get(discipline.surface)
            
            keyword = self.faker.random_element(keywords)
            suffix = self.faker.random_element(suffixes)
            city = faker_names.city()
            
            comp_date = self.faker.date_between(start_date='-5y', end_date='+1y')
            hour = self.random(6, 22)
            minute = self.faker.random_element([0, 15, 30, 45])
            comp_time = time(hour, minute, 0)

            competition = Competition(
                discipline_id = discipline.discipline_id,
                name = f"{keyword} {suffix} {comp_date.year}",
                date = comp_date,
                time = comp_time,
                city = city,
                spectators = self.random(0, 2000)
            )
            competitions.append(competition)
        
        self.session.add_all(competitions)
        self.session.commit()
        return(competitions)                    
    
    def create_sponsorship_contracts(self, count, sponsors):
        offer_types = [ 'Nutritional Supply',
                        'Medical Care',
                        'Cage Equipment',
                        'Travel Expenses',
                        'Racing Equipment',
                        None ]

        sponsorship_contracts = []

        for _ in range(count):
            sponsor = self.faker.random_element(sponsors)
            start_date = self.faker.date_between(start_date='-5y', end_date='today')
            if self.faker.boolean(chance_of_getting_true=80):
                duration = self.random(1, 1000)
                end_date = start_date + timedelta(days=duration)
            else:
                end_date = None

            contract_value_gbp = None
            if self.faker.boolean(chance_of_getting_true=90):
                contract_value_gbp = self.random(50000, 5000000) / 100

            offer_type = self.faker.random_element(offer_types)
            while contract_value_gbp is None and offer_type is None:
                offer_type = self.faker.random_element(offer_types)

            contract = SponsorshipContract(
                sponsor_id = sponsor.sponsor_id,
                start_date = start_date,
                end_date = end_date,
                contract_value_gbp = contract_value_gbp,
                offer_type = offer_type
            )
            self.session.add(contract)

        self.session.add_all(sponsorship_contracts)
        self.session.commit()
        return(sponsorship_contracts)

    def create_participations(self, min_hamsters_per_competition, max_hamsters_per_competiton, competitions, hamsters):
        competitions_finished = [c for c in competitions if c.date < date.today()]        
        participations = []

        for competition in competitions_finished:
            hamsters_able_to_race = [h for h in hamsters if h.birth_date + relativedelta(months=2) < competition.date and (h.death_date is None or h.death_date > competition.date)]
            hamsters_count = min(len(hamsters_able_to_race), self.random(min_hamsters_per_competition, max_hamsters_per_competiton))
            race_participants = self.faker.random_elements(hamsters_able_to_race, hamsters_count, True)
            current_rank = 1

            for hamster in race_participants:
                place = current_rank
                current_rank += 1

                participation = Participation(
                    competition_id=competition.competition_id,
                    hamster_id=hamster.hamster_id,
                    place=place,
                    disqualified=False
                )
                participations.append(participation)

        self.session.add_all(participations)
        self.session.commit()
        return(participations)
          
    def create_doping_tests(self, count, participations, employees, competitions):
        doping_tests = []
        used_participations = []

        for _ in range(count):
            participation = self.faker.random_element(participations)
            while participation in used_participations:
                participation = self.faker.random_element(participations)
            used_participations.append(participation)

            competition = [c for c in competitions if c.competition_id == participation.competition_id][0]

            is_positive = self.faker.boolean(chance_of_getting_true=5)
            if is_positive:
                participation.disqualified = True
                participation.place = None

            chemical_part = self.faker.word().capitalize()
            suffix = self.faker.random_element(['zol', 'ide', 'ine', 'ate', 'ium', 'ex'])
            prefix = self.faker.random_element(['Methyl', 'Hydro', 'Nitro', 'Super', 'Ultra'])
            name = f"{prefix}-{chemical_part}{suffix}"

            active_vet_employees = [e for e in employees 
                                    if (e.position == 'Veterinarian' 
                                    or e.position == 'Vet Technician')
                                    and e.is_active
                                    and e.hire_date < competition.date]

            test = DopingTest(
                employee_id=self.faker.random_element(active_vet_employees).employee_id,
                participation_id=participation.participation_id,
                substance_name = name,
                positive=is_positive
            )
            doping_tests.append(test)

        self.session.add_all(doping_tests)
        self.session.commit()
        return()
    
    def fix_results_when_disqualifed(self, participations):
        disqualifications = [p for p in participations if p.disqualified]

        for disqualification in disqualifications:
            other_results = [p for p in participations if p.competition_id == disqualification.competition_id and p.place is not None]
            other_results.sort(key=lambda x: x.place)
            found = False
            for i in range(1, len(other_results) + 1):
                if i != other_results[i-1].place:
                    found = True
                if found:
                    other_results[i-1].place = i
