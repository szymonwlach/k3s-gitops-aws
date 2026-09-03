from sqlalchemy.orm import declarative_base
from sqlalchemy import Column,Integer,String, DateTime
from datetime import datetime

Base = declarative_base()

class Incident(Base):
  __tablename__ = "incidents"

  id = Column(Integer, primary_key=True, index=True)
  service_name = Column(String)
  status = Column(String)
  description = Column(String, nullable=True)
  created_at = Column(DateTime, default=datetime.utcnow)