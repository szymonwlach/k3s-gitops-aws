from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class IncidentCreate(BaseModel):
    service_name: str
    status: str
    description: Optional[str] = None

class IncidentResponse(BaseModel):
    id: int
    service_name: str
    status: str
    description: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True