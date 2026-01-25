from sqlalchemy import Column, Integer, Boolean, String
from entities.Base import Base

class DopingTest(Base):
    __tablename__ = 'doping_tests'

    test_id = Column(Integer, primary_key=True)
    employee_id = Column(Integer)
    participation_id = Column(Integer)
    substance_name = Column(String(50))
    positive = Column(Boolean)