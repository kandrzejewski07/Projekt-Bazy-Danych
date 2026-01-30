from sqlalchemy import Column, Integer, String, Date, Numeric, Boolean
from entities.Base import Base

class Employee(Base):
    __tablename__ = 'employees'

    employee_id = Column(Integer, primary_key=True)
    first_name = Column(String(50))
    last_name = Column(String(50))
    birth_date = Column(Date)
    email = Column(String(255))
    phone = Column(String(30))
    address = Column(String(255))
    hire_date = Column(Date)
    position = Column(String(100))
    employment_type = Column(String(40))
    salary = Column(Numeric(10, 2))
    is_active = Column(Boolean)