from sqlalchemy import Column, Integer, String
from entities.Base import Base

class Owner(Base):
    __tablename__ = 'owners'

    owner_id = Column(Integer, primary_key=True)
    first_name = Column(String(50))
    last_name = Column(String(50))
    wealth_rating = Column(Integer)