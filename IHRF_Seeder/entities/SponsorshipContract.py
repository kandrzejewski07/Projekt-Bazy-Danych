from sqlalchemy import Column, Integer, String, Date, Numeric
from entities.Base import Base

class SponsorshipContract(Base):
    __tablename__ = 'sponsorship_contracts'

    contract_id = Column(Integer, primary_key=True)
    sponsor_id = Column(Integer)
    start_date = Column(Date)
    end_date = Column(Date)
    contract_value_gbp = Column(Numeric(12,2))
    offer_type = Column(String(30))
