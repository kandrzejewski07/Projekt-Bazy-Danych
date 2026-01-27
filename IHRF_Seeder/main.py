from random import randint
from faker import Faker

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from urllib.parse import quote_plus

from database_seeder import DatabaseSeeder

faker = Faker()
random = randint

pwd = quote_plus("te@mzio")
# engine = create_engine(f"mysql+pymysql://team10:{pwd}@giniewicz.it:3306/team10", echo=False)
engine = create_engine(f"mysql+pymysql://team10:{pwd}@giniewicz.it:3306/team10", echo=True)

Session = sessionmaker(bind=engine)
session = Session()

seeder = DatabaseSeeder(session)
seeder.seed()