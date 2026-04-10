# Capital Circles

Your financial hub for families, friends, and roommates. Care for your circle's finances together without mixing accounts.

## Track 2: Human-Centered Connection

Capital Circles transforms banking from a solo experience into a shared one. Families and friends support each other's financial wellness without compromising privacy, powered by AI insights and deep Capital One card integration.

## Team APA

- **Patricio Garza**
- **Adan Gonzalez**
- **Alana Martinez**

## Architecture

```
iOS app (SwiftUI)
      |
      v
FastAPI backend (localhost:8000)
      |
      v
Neon PostgreSQL (serverless, cloud-hosted)

Claude API (for AI insights)
```

## Setup

### Prerequisites

- Xcode 16.3+
- Python 3.11+
- XcodeGen (`brew install xcodegen`)

### Backend

1. Create `backend/.env`:

```
DATABASE_URL=postgresql://neondb_owner:...@...neon.tech/neondb?sslmode=require
CLAUDE_API_KEY=sk-ant-api03-...
PORT=8000
```

2. Install Python dependencies:

```bash
pip3 install 'psycopg[binary]' fastapi 'uvicorn[standard]' python-dotenv httpx
```

3. Run the server:

```bash
cd backend
python3 -m uvicorn main:app --host 0.0.0.0 --port 8000
```

The schema is auto-initialized on startup.

### iOS

1. Generate the Xcode project:

```bash
xcodegen generate
```

2. Create `CapitalCircles/Secrets.swift` from `Secrets.example.swift` and fill in:
   - `claudeAPIKey`: Your Anthropic API key
   - `databaseURL`: Your Neon connection string (for reference)
   - `backendBaseURL`: Defaults to `http://localhost:8000`

3. Open `CapitalCircles.xcodeproj`, set your dev team, build and run.

## Features

- **Hub** - Family financial wellness view with shared goals, member activity, and privacy-respecting spending views
- **Smart Insights** - AI-generated monthly summaries with month-by-month history powered by Claude
- **Circles** - Multi-step creation flow with visibility configuration per circle type
- **Goals** - Shared or personal, with contribution tracking
- **Card Optimizer** - Best Capital One card per spending category
- **Nudges** - Send encouragement to circle members

## Privacy Model

Capital Circles enforces privacy rules automatically based on circle type:

| Data            | Family           | Roommates | Friends | Couple        |
| --------------- | ---------------- | --------- | ------- | ------------- |
| Shared goals    | All              | All       | All     | All           |
| Personal spend  | Parents see kids | Private   | Private | Configurable  |
| Cards           | Parents see kids | Private   | Private | Configurable  |
| Smart Statement | Private          | Private   | Private | Private       |

## Tech Stack

- **Frontend**: SwiftUI, Charts framework, `@Observable`
- **Backend**: FastAPI, psycopg3
- **Database**: Neon PostgreSQL
- **AI**: Claude Sonnet 4.5 via Anthropic API
