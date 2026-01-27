from sqlalchemy import Column, Integer, String, Date
from entities.Base import Base

class Hamster(Base):
    __tablename__ = 'hamsters'

    hamster_id = Column(Integer, primary_key=True)
    name = Column(String(50))
    race = Column(String(50))
    weight_grams = Column(Integer)
    birth_date = Column(Date)
    death_date = Column(Date)
    specialty = Column(String(20))
    owner_id = Column(Integer)


