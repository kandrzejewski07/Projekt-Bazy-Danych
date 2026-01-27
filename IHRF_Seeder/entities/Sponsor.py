from sqlalchemy import Column, Integer, String
from entities.Base import Base

class Sponsor(Base):
    __tablename__ = 'sponsors'

    sponsor_id = Column(Integer, primary_key=True)
    company_name = Column(String(255))
    tax_number = Column(String(30))
    country = Column(String(80))
    city = Column(String(120))
    rep_first_name = Column(String(50))
    rep_last_name = Column(String(50))
    rep_email = Column(String(255))
    rep_phone = Column(String(30))
