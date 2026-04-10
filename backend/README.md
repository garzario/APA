# Capital Circles Backend

FastAPI backend that powers the Capital Circles iOS app.

## Tech Stack

- FastAPI for REST API
- Neon PostgreSQL for data persistence
- Claude AI for Smart Statements
- psycopg3 for database connectivity

## Setup

```bash
pip install -r requirements.txt
cp .env.example .env
# Fill in DATABASE_URL and CLAUDE_API_KEY
uvicorn main:app --reload --port 8000
```

## Endpoints

### Users
- `POST /users` - Create user
- `GET /users/{id}` - Get user by ID
- `GET /users/email/{email}` - Get user by email

### Circles
- `POST /circles` - Create a new circle
- `GET /users/{user_id}/circles` - Get circles for a user
- `POST /circles/members` - Add a member to a circle
- `GET /circles/{id}/members` - Get members of a circle

### Goals
- `POST /goals` - Create a new goal
- `GET /users/{user_id}/goals` - Get goals accessible to a user
- `POST /contributions` - Add a contribution to a goal

### Smart Statements
- `POST /statements/generate` - Generate an AI Smart Statement via Claude

## Database

Schema is auto-initialized on startup from `schema.sql`.
