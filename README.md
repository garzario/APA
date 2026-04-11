<p align="center">
  <img src="CapitalCircles/App/Assets.xcassets/AppIcon.appiconset/icon_default.png" width="160" alt="Capital Circles app icon" />
</p>

<h1 align="center">Capital Circles</h1>

<p align="center">
  <em>A new way to reach your financial goals. Together, privately, powered by Capital One.</em>
</p>

---

Capital Circles turns banking from a solo experience into a shared one. Families, couples, roommates, and friends support each other's financial wellness without mixing accounts. Built in twelve hours for the **Capital One Hackathon at Tec de Monterrey**. **Track 2: Human-Centered Connection.**

---

## The problem

Every banking app in the world treats you like an island. One person, one account, one screen. Your family has no idea how you are doing. Your partner hides receipts. Your kids learn about money by accident.

But money is shared in real life. Rent, groceries, trips, weddings, emergencies. Yet the apps we use to manage it are built for someone who lives alone on the moon.

## The belief

> **Money should feel like a team sport.**
> The people you love deserve to know you are doing okay, without you having to hand them your whole bank account.

---

## The innovation: privacy as a product feature

Every other fintech treats privacy as a setting buried three levels deep. We treat it as the product. From the very first screen, Capital Circles asks you exactly what you are comfortable sharing — and the entire experience adapts to your answer.

Each circle type has its own default rules, enforced in code:

| Data                   | Family              | Couple          | Roommates | Friends  |
| ---------------------- | ------------------- | --------------- | --------- | -------- |
| Shared goals           | Everyone            | Everyone        | Everyone  | Everyone |
| Goal progress          | Everyone            | Everyone        | Everyone  | Everyone |
| Personal spending      | Parents see kids    | Configurable    | Private   | Private  |
| Card details           | Parents see kids    | Configurable    | Private   | Private  |
| Spending categories    | Parents see kids    | Configurable    | Private   | Private  |
| Smart Insights         | Private             | Private         | Private   | Private  |
| Card Optimizer         | Private             | Private         | Private   | Private  |
| **Children see parents** | **Never, ever, by design** | N/A    | N/A       | N/A      |

**The last row is the most important one.** Parents should never have to hide from their kids to keep their own financial privacy. It is a dignity decision, not a technical one — so we made it impossible to toggle off.

---

## The product

### 1. Onboarding that respects the moment

Nine steps of editorial, one-question-at-a-time design. Big bold headlines. Pill buttons. No clutter.

1. **Welcome** — "Reach goals together, not alone."
2. **Intro** — Three principles of how it works.
3. **Sign In** — Name and email. Creates a real user in Neon Postgres the second you tap continue.
4. **Circle Type** — Family, couple, roommates, friends.
5. **Circle Name** — With placeholder copy that adapts to the type.
6. **Privacy** — *The most important screen in the app.* Configurable toggles per circle type.
7. **Members** — Live database search or email invite.
8. **First Goal** — Optional. Capital Circles is not a goal tracker.
9. **Review** — Summary before writing to the database.

### 2. The Hub

Your family's financial command center.

- **Hero card** with navy background and the iconic Capital One red swoosh
- **Combined family spending** for the month, privacy-aware
- **Member wellness row** for every person, with lock icons for anyone who chose not to share
- **Shared goals** (only when they exist — goals are optional)
- **Quick actions** for Card Optimizer and personal goals
- **Recent activity** feed

Tap any member to see their cards, transactions, and wellness status — *if and only if* your privacy rules allow it.

### 3. Smart Insights (powered by Claude Sonnet 4.5)

Four months of insight history, chronological picker at the top, every month with a narrative written specifically for you. The Claude prompt is engineered with the Capital Circles voice and includes real context: your circle name, your members, your goals.

Tap **Refresh** and Claude writes a new take on the same data, live, right now. This is a real API call hitting Anthropic's servers — not a mock, not a cache.

### 4. Card Optimizer

Every Capital One card you own, every spending category, every reward rate. Before you swipe, you know which card earns the most. Venture X for travel. Savor for dining. Quicksilver for everything else. This is the kind of feature that should ship inside the Capital One app tomorrow.

### 5. Nudges

Send encouragement to circle members. Six curated prompts, from "Keep going!" to "Let's talk about money over coffee." Because human-centered means the humans actually talk to each other.

### 6. Notifications

Every meaningful event: milestone hit, new member joined, invite sent, goal completed. Tappable, with detail sheets, relative timestamps ("5m ago", "3d ago"), and mark-all-read.

---

## Architecture

```
+----------------------------------------------------+
|                                                    |
|         iOS App (SwiftUI, iOS 17+)                 |
|                                                    |
|   Views  ->  @Observable AppStateManager           |
|                  |                                 |
|                  |  async/await + URLSession       |
|                  v                                 |
+------------------+---------------------------------+
                   |
                   |  HTTPS
                   v
+----------------------------------------------------+
|                                                    |
|   FastAPI backend (Python 3.11)                    |
|                                                    |
|   /users, /circles, /goals, /contributions         |
|   /statements/generate  --->  Claude Sonnet 4.5    |
|                                                    |
+------------------+---------------------------------+
                   |
                   |  psycopg3 + SSL
                   v
+----------------------------------------------------+
|                                                    |
|   Neon PostgreSQL (serverless, cloud-hosted)       |
|                                                    |
|   users, cards, circles, circle_members,           |
|   goals, contributions, transactions               |
|                                                    |
+----------------------------------------------------+
```

Three layers, three responsibilities:

- **iOS**: state management, presentation, local caching
- **Backend**: authentication boundary, privacy enforcement, AI orchestration, data persistence
- **Database**: single source of truth, ACID guarantees, audit history

---

## Tech stack

| Layer       | Technology                                           |
| ----------- | ---------------------------------------------------- |
| iOS         | Swift 5.9, SwiftUI, @Observable, Charts framework    |
| State       | Custom AppStateManager with async write-through      |
| Networking  | URLSession, async/await, typed Codable DTOs          |
| Design      | Custom CCTheme: colors, typography, spacing, buttons |
| Project gen | XcodeGen (`project.yml`)                             |
| Backend     | FastAPI, Pydantic, psycopg3                          |
| Database    | Neon PostgreSQL (serverless, branching, autoscaling) |
| AI          | Claude Sonnet 4.5 via Anthropic API                  |
| Version ctrl| Git with feature branches, PRs, squash merges        |

---

## Repository layout

```
APA/
|-- CapitalCircles/              # iOS app source
|   |-- App/                     # Entry point, asset catalog, ContentView
|   |-- Models/                  # Domain models (User, Circle, Goal, Card, ...)
|   |-- Views/                   # SwiftUI views by feature area
|   |-- Services/                # APIClient, AppStateManager, ClaudeService, ...
|   |-- Components/              # Reusable UI (CCAvatar, CCSwitch, ...)
|   |-- Theme/                   # CCTheme: the design system
|   |-- Secrets.swift            # Gitignored. API keys.
|   \-- Secrets.example.swift    # Template
|-- backend/                     # FastAPI server
|   |-- main.py                  # Routes
|   |-- db.py                    # Postgres connection
|   |-- models.py                # Pydantic schemas
|   |-- claude_service.py        # Claude API integration
|   |-- schema.sql               # Auto-initialized on startup
|   |-- seed_db.py               # Optional seed script
|   \-- requirements.txt
|-- project.yml                  # XcodeGen spec
|-- Capital_Circles_Pitch.pdf    # 4-minute presentation script
\-- README.md                    # You are here
```

---

## Setup

### Prerequisites

- macOS with Xcode 16.3 or newer
- Python 3.11 or newer
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
- A Neon PostgreSQL database (or any Postgres with the schema applied)
- An Anthropic API key with credits

### Backend

```bash
cd backend
pip3 install 'psycopg[binary]' fastapi 'uvicorn[standard]' python-dotenv httpx
```

Create `backend/.env` (gitignored):

```
DATABASE_URL=postgresql://<user>:<pass>@<host>/<db>?sslmode=require
CLAUDE_API_KEY=sk-ant-api03-...
PORT=8000
```

Run the server:

```bash
python3 -m uvicorn main:app --host 0.0.0.0 --port 8000
```

The schema is applied automatically from `schema.sql` on first startup. Verify the server is up:

```bash
curl http://localhost:8000/health
# {"status":"ok"}
```

### iOS

```bash
xcodegen generate
```

Create `CapitalCircles/Secrets.swift` (gitignored):

```swift
import Foundation

enum Secrets {
    static let claudeAPIKey = "sk-ant-api03-..."
    static let databaseURL = "postgresql://..."
    static let backendBaseURL: String? = "http://localhost:8000"
}
```

Open `CapitalCircles.xcodeproj`, set your development team under **Signing & Capabilities**, and run on the **iPhone 17 Pro** simulator.

---

## How it scales

Capital Circles is built as a proof of concept with a real backend and a real database. Here is the roadmap from today's hackathon build to a product that serves every Capital One customer.

### Deployment and infrastructure

- **Compute**: migrate the FastAPI app to AWS ECS Fargate or Capital One's internal Kubernetes, behind an Application Load Balancer with health checks and auto-scaling
- **Database**: Neon already offers serverless Postgres with branching (dev, staging, prod), point-in-time recovery, and autoscaling compute. Capital One would add read replicas for analytical queries
- **Caching**: Redis for session state, hot member lookups, and rate limiting
- **CDN**: CloudFront for the API with caching on idempotent GETs
- **Observability**: OpenTelemetry traces into Datadog, structured JSON logs into Splunk, Sentry for client errors

### Authentication and identity

- **OAuth 2.0** with Capital One's existing identity provider, the same one the main Capital One mobile app uses
- **JWT bearer tokens** on every request, validated server-side with jwks rotation
- **Refresh token rotation** with family-linking for multi-account households
- **Biometric re-auth** (Face ID / Touch ID) for sensitive actions like changing privacy or contributing
- **SCIM provisioning** so family accounts can be linked and managed centrally

### Data security

- **Field-level encryption** for PII (name, email) using AWS KMS or HashiCorp Vault
- **Row-level security** in Postgres so a user can only query rows tied to their identity
- **TLS everywhere** including internal service-to-service traffic
- **Audit log** on every financial read and write, stored in an append-only table with tamper detection
- **Regular penetration testing** and SOC 2 Type II audit

### Privacy enforcement at the API layer

Today the privacy matrix is enforced in the iOS client. In production, the backend becomes the final arbiter:

- A **central policy engine** (Open Policy Agent or AWS Cedar) encodes the privacy matrix
- Every endpoint that returns financial data calls the policy engine before responding
- **Denied queries** return an empty payload, not a 403, so the client can render a clean "private" state
- **Explicit consent flow** with audit trail when a member opts in to share more
- **Privacy impact reports** surfaced to the user every quarter

### AI cost and reliability

Claude insights scale gracefully thanks to Anthropic's features:

- **Prompt caching** on the system prompt cuts input tokens by roughly ninety percent. Our system prompt is around 800 tokens; cached it costs pennies per user per month.
- **Background generation**: insights are created once per user per month in a nightly job, so the iOS app always loads instantly
- **On-demand refresh**: the user can request a fresh take; we budget a maximum refreshes per user per month
- **Smart caching keys**: prompts keyed on circle state hash, so regeneration only happens when underlying data changes
- **Fallback narratives** using rule-based templates when the API is unavailable, so the feature never goes dark

Back-of-envelope economics: with prompt caching and background generation, insights cost well under one cent per user per month. Even at ten million monthly active users, the AI bill is negligible compared to the engagement lift.

### Data model evolution

- **Event sourcing** for financial mutations: every contribution, every goal edit, every member join is stored as an immutable event. Current state is a materialized view. This gives us a perfect audit trail and the ability to replay history.
- **Read replicas** for the analytical queries that power the Hub's per-member wellness view
- **Materialized views** for monthly aggregations, refreshed hourly
- **Horizontal sharding** by user ID when we pass ten million users
- **Time-series storage** (TimescaleDB or ClickHouse) for transaction history beyond ninety days

### Realtime and push

- **WebSocket connection** per active session so contributions, nudges, and new members appear on all devices instantly
- **APNs push notifications** for events that happen while the app is closed: a parent gets pinged when their kid hits an allowance threshold, a partner gets nudged when a shared goal crosses a milestone
- **Optimistic UI updates** with server reconciliation so the app feels instantaneous even on slow networks

### Platform expansion

Capital Circles is designed backend-first so every client is a thin layer on top of the same API.

- **Android** client with Kotlin Jetpack Compose using the same REST endpoints
- **Web dashboard** at circles.capitalone.com for parents who prefer a larger screen, built with Next.js
- **Apple Watch** complication showing the family's combined spending and next milestone
- **Widget** on iOS home screen for one-tap goal progress
- **Deep integration** into the main Capital One app as a first-class feature using the existing identity session
- **Ask our Eno assistant**: "How are we doing on the Cancun trip?" answered from the Capital Circles API

### Compliance and regulation

- **SOC 2 Type II** audit across backend, database, and client
- **PCI DSS** compliance when real card numbers flow through the product
- **GDPR and CCPA** data export and deletion flows exposed in Profile settings
- **PSD2 / Open Banking** alignment for European expansion
- **Financial Conduct Authority** registration for the UK
- **KYC / AML** integration via Capital One's existing identity systems

---

## Why Capital One should ship this

**Loyalty**: families that use Capital One together stay on Capital One longer. When your spouse, your kids, and your in-laws are all in the same hub, switching banks means migrating four people instead of one.

**Cross-sell**: the Card Optimizer surfaces every Capital One product naturally. A household that sees the value of Venture X through the lens of their family trip is more likely to apply.

**Differentiation**: no major US bank has a human-centered financial wellness product. Capital Circles is a wedge into a category Chase, Bank of America, and Wells Fargo cannot replicate without rebuilding their apps from scratch.

**Trust**: the privacy model demonstrates that Capital One understands modern families. "The bank that lets you look after your kids without spying on your spouse" is a positioning no competitor can copy.

**Data**: once families are inside Capital Circles, Capital One sees household-level financial behavior instead of individual behavior. Better risk models, better product recommendations, better fraud detection.

---

## The team

We are three ITC students from Tec de Monterrey who believe banking should feel human.

- **Patricio Garza** — iOS, SwiftUI, design system, onboarding flow
- **Alana Martinez** — Data model, privacy logic, Claude prompt engineering, backend schema
- **Adan Gonzalez** — API layer, goals and contributions, member search, integration testing

Everyone touched everything. Pair-programmed where it mattered. Shipped with real commits from real branches through real pull requests.

---

## Engineering discipline

This project was built in twelve hours under competition conditions. We still held ourselves to production engineering standards:

- **Git**: feature branches merged to dev, dev merged to main, PR descriptions explain the why, commits are signed and timestamped
- **Code quality**: no force-unwraps in production paths, consistent naming, no dead code
- **Separation of concerns**: UI does not talk to the database. Services own side effects. State is a single source of truth.
- **Typed everywhere**: Codable DTOs on iOS, Pydantic models on the backend, no stringly-typed API contracts
- **Graceful degradation**: the app stays useful when the backend is slow or the AI is rate-limited
- **Secrets management**: API keys in gitignored files, with clear templates for collaborators
- **Documentation**: this README, inline code comments where intent is non-obvious, a 4-minute pitch script committed alongside the source

---

## Core design principles

1. **Privacy is a product feature, not a setting.** It lives at the center of onboarding, not in a menu.
2. **The Hub is about people, not numbers.** Wellness first, goals second, transactions third.
3. **Goals are optional.** The product is about ongoing care, not one-time saving.
4. **Respect the brand.** Capital One navy and red from the first pixel. The red swoosh in every hero card.
5. **Editorial over decorative.** Typography-forward, minimal ornament, generous whitespace.
6. **Every interaction is deliberate.** No accidental taps, no dead ends, every screen knows where the user is going next.

---

## Closing

Most banking apps are built for one person, managing one account, in isolation. Capital Circles is built for the people you love, and for a version of money that feels less like a scoreboard and more like a team sport.

Built in twelve hours. Ready to ship.

**Team APA**
Patricio Garza · Alana Martinez · Adan Gonzalez
Capital One Hackathon · Tec de Monterrey · April 2026
