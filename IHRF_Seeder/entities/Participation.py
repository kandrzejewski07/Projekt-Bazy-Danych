from sqlalchemy import Column, Integer, Boolean
from entities.Base import Base

class Participation(Base):
    __tablename__ = 'participations'

    participation_id = Column(Integer, primary_key=True)
    competition_id= Column(Integer)
    hamster_id = Column(Integer)
    place = Column(Integer)
    disqualified = Column(Boolean)