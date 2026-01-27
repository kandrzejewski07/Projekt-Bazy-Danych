from sqlalchemy import Column, Integer, String, Date, Numeric
from entities.Base import Base

class Cost(Base):
    __tablename__ = 'costs'

    cost_id = Column(Integer, primary_key=True)
    year = Column(Integer)
    value_gbp = Column(Numeric(12,2))