from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from typing import List

from database import engine, get_db
from models import Base, Incident
from schemas import IncidentCreate, IncidentResponse

Base.metadata.create_all(bind=engine)

app = FastAPI()

@app.get("/incidents", response_model=List[IncidentResponse])
def list_incidents(db: Session = Depends(get_db)):
    return db.query(Incident).all()

@app.post("/incidents", response_model=IncidentResponse)
def create_incident(incident: IncidentCreate, db: Session = Depends(get_db)):
    db_incident = Incident(**incident.dict())
    db.add(db_incident)
    db.commit()
    db.refresh(db_incident)
    return db_incident