import enum

from sqlalchemy import Column, Integer, String, Enum
from entities.Base import Base

class Surface(enum.Enum):
    Tarmac = "Tarmac"
    Gravel = "Gravel"
    Sand = "Sand"
    Ice = "Ice"
    Snow = "Snow"

class Category(enum.Enum):
    Natural = "Natural"
    Formula_H = "Formula H"


class Discipline(Base):
    __tablename__ = 'disciplines'

    discipline_id = Column(Integer, primary_key=True)
    name = Column(String(100))
    category = Column(Enum(Category))
    surface = Column(Enum(Surface))
    distance = Column(Integer)
