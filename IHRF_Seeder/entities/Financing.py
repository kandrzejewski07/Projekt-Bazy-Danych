from sqlalchemy import Column, Integer, String, Date, Numeric
from entities.Base import Base

class Financing(Base):
    __tablename__ = 'financings'

    financing_id = Column(Integer, primary_key=True)
    source = Column(String(100))
    value = Column(Numeric(12,2))
    income_date = Column(Date)
