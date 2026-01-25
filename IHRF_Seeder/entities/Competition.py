from sqlalchemy import Column, Integer, String, Date, Time
from entities.Base import Base

class Competition(Base):
    __tablename__ = 'competitions'

    competition_id = Column(Integer, primary_key=True)
    discipline_id = Column(Integer)
    name = Column(String(100))
    date = Column(Date)
    time = Column(Time)
    city = Column(String(100))
    spectators = Column(Integer)
