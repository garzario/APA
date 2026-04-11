"""Capital Circles backend API.

FastAPI server that provides REST endpoints for the iOS app.
Connects to Neon PostgreSQL for persistence and Claude AI for insights.
"""
import uuid
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from db import get_connection, init_schema
from models import (
    User, UserCreate, Card, Circle, CircleCreate,
    CircleMember, CircleMemberCreate, Goal, GoalCreate,
    Contribution, ContributionCreate, StatementRequest, StatementResponse,
)
from claude_service import generate_smart_statement

app = FastAPI(title="Capital Circles API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def startup():
    init_schema()


@app.get("/health")
def health():
    return {"status": "ok"}


# Users

@app.post("/users", response_model=User)
def create_user(payload: UserCreate):
    user_id = uuid.uuid4()
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO users (id, name, email, avatar_icon)
                VALUES (%s, %s, %s, %s)
                RETURNING *
                """,
                (str(user_id), payload.name, payload.email, payload.avatar_icon),
            )
            return cur.fetchone()


# Search must come BEFORE /users/{user_id} so it matches first
@app.get("/users/search")
def search_users(q: str, exclude: str | None = None):
    """Search users by partial name or email match."""
    if len(q) < 2:
        return []
    with get_connection() as conn:
        with conn.cursor() as cur:
            if exclude:
                cur.execute(
                    """
                    SELECT * FROM users
                    WHERE (LOWER(name) LIKE %s OR LOWER(email) LIKE %s)
                    AND id::text != %s
                    ORDER BY created_at DESC
                    LIMIT 20
                    """,
                    (f"%{q.lower()}%", f"%{q.lower()}%", exclude),
                )
            else:
                cur.execute(
                    """
                    SELECT * FROM users
                    WHERE LOWER(name) LIKE %s OR LOWER(email) LIKE %s
                    ORDER BY created_at DESC
                    LIMIT 20
                    """,
                    (f"%{q.lower()}%", f"%{q.lower()}%"),
                )
            return cur.fetchall()


@app.get("/users/email/{email}", response_model=User)
def get_user_by_email(email: str):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM users WHERE email = %s", (email,))
            user = cur.fetchone()
            if not user:
                raise HTTPException(404, "User not found")
            return user


@app.get("/users/{user_id}", response_model=User)
def get_user(user_id: uuid.UUID):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM users WHERE id = %s", (str(user_id),))
            user = cur.fetchone()
            if not user:
                raise HTTPException(404, "User not found")
            return user


# Circles

@app.post("/circles", response_model=Circle)
def create_circle(payload: CircleCreate):
    circle_id = uuid.uuid4()
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO circles (id, name, type, icon_name, created_by)
                VALUES (%s, %s, %s, %s, %s)
                RETURNING *
                """,
                (str(circle_id), payload.name, payload.type, payload.icon_name, str(payload.created_by)),
            )
            circle = cur.fetchone()

            # Auto-add creator as admin
            cur.execute(
                """
                INSERT INTO circle_members (id, circle_id, user_id, role, visibility)
                VALUES (%s, %s, %s, 'admin', 'goalsOnly')
                """,
                (str(uuid.uuid4()), str(circle_id), str(payload.created_by)),
            )

            return circle


@app.get("/users/{user_id}/circles", response_model=list[Circle])
def get_user_circles(user_id: uuid.UUID):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT c.* FROM circles c
                JOIN circle_members cm ON cm.circle_id = c.id
                WHERE cm.user_id = %s
                ORDER BY c.created_at DESC
                """,
                (str(user_id),),
            )
            return cur.fetchall()


@app.post("/circles/members", response_model=CircleMember)
def add_circle_member(payload: CircleMemberCreate):
    member_id = uuid.uuid4()
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO circle_members (id, circle_id, user_id, role, visibility)
                VALUES (%s, %s, %s, %s, %s)
                RETURNING *
                """,
                (str(member_id), str(payload.circle_id), str(payload.user_id), payload.role, payload.visibility),
            )
            return cur.fetchone()


@app.get("/circles/{circle_id}/members")
def get_circle_members(circle_id: uuid.UUID):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT cm.*, u.name, u.email, u.avatar_icon
                FROM circle_members cm
                JOIN users u ON u.id = cm.user_id
                WHERE cm.circle_id = %s
                """,
                (str(circle_id),),
            )
            return cur.fetchall()


# Goals

@app.post("/goals", response_model=Goal)
def create_goal(payload: GoalCreate):
    goal_id = uuid.uuid4()
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO goals (id, title, icon_name, target_amount, current_amount, deadline, is_shared, circle_id, owner_id)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING *
                """,
                (
                    str(goal_id), payload.title, payload.icon_name,
                    payload.target_amount, payload.current_amount, payload.deadline,
                    payload.is_shared,
                    str(payload.circle_id) if payload.circle_id else None,
                    str(payload.owner_id),
                ),
            )
            return cur.fetchone()


@app.get("/users/{user_id}/goals", response_model=list[Goal])
def get_user_goals(user_id: uuid.UUID):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT DISTINCT g.* FROM goals g
                LEFT JOIN circle_members cm ON cm.circle_id = g.circle_id
                WHERE g.owner_id = %s OR cm.user_id = %s
                ORDER BY g.created_at DESC
                """,
                (str(user_id), str(user_id)),
            )
            return cur.fetchall()


@app.post("/contributions", response_model=Contribution)
def add_contribution(payload: ContributionCreate):
    contrib_id = uuid.uuid4()
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO contributions (id, goal_id, user_id, amount, note)
                VALUES (%s, %s, %s, %s, %s)
                RETURNING *
                """,
                (str(contrib_id), str(payload.goal_id), str(payload.user_id), payload.amount, payload.note),
            )
            contrib = cur.fetchone()

            # Update goal current_amount
            cur.execute(
                "UPDATE goals SET current_amount = current_amount + %s WHERE id = %s",
                (payload.amount, str(payload.goal_id)),
            )

            return contrib


# Smart Statements

@app.post("/statements/generate", response_model=StatementResponse)
async def generate_statement(payload: StatementRequest):
    """Generate an AI-powered Smart Statement using Claude."""
    try:
        result = await generate_smart_statement(
            month=payload.month,
            year=payload.year,
            total_spent=float(payload.total_spent),
            categories=payload.categories,
            compared_to_last_month=payload.compared_to_last_month,
        )
        return StatementResponse(**result)
    except Exception as e:
        raise HTTPException(500, f"Failed to generate statement: {str(e)}")
