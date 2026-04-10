"""Pydantic models for API requests and responses."""
from datetime import date, datetime
from decimal import Decimal
from typing import Optional
from uuid import UUID
from pydantic import BaseModel, EmailStr


class UserBase(BaseModel):
    name: str
    email: str
    avatar_icon: str = "person.circle.fill"


class UserCreate(UserBase):
    pass


class User(UserBase):
    id: UUID
    created_at: datetime


class CardBase(BaseModel):
    name: str
    last_four: str
    card_type: str
    current_balance: Decimal = Decimal(0)
    credit_limit: Decimal = Decimal(0)
    rewards_balance: Decimal = Decimal(0)


class Card(CardBase):
    id: UUID
    user_id: UUID


class CircleBase(BaseModel):
    name: str
    type: str
    icon_name: str = "person.3.fill"


class CircleCreate(CircleBase):
    created_by: UUID


class Circle(CircleBase):
    id: UUID
    created_by: UUID
    created_at: datetime


class CircleMemberCreate(BaseModel):
    circle_id: UUID
    user_id: UUID
    role: str = "member"
    visibility: str = "goalsOnly"


class CircleMember(CircleMemberCreate):
    id: UUID
    joined_at: datetime


class GoalBase(BaseModel):
    title: str
    icon_name: str = "star.fill"
    target_amount: Decimal
    current_amount: Decimal = Decimal(0)
    deadline: Optional[date] = None
    is_shared: bool = False


class GoalCreate(GoalBase):
    circle_id: Optional[UUID] = None
    owner_id: UUID


class Goal(GoalBase):
    id: UUID
    circle_id: Optional[UUID]
    owner_id: UUID
    created_at: datetime


class ContributionCreate(BaseModel):
    goal_id: UUID
    user_id: UUID
    amount: Decimal
    note: Optional[str] = None


class Contribution(ContributionCreate):
    id: UUID
    created_at: datetime


class StatementRequest(BaseModel):
    """Request model for generating a Smart Statement via Claude."""
    user_id: UUID
    month: str
    year: int
    total_spent: Decimal
    categories: list[dict]
    compared_to_last_month: float


class StatementResponse(BaseModel):
    narrative: str
    insights: list[dict]
