# Capital Circles

**Your financial hub for families, friends, and roommates.**
Care for your circle's finances together without mixing accounts.

Built for the **Capital One Hackathon** at Tec de Monterrey.
**Track 2: Human-Centered Connection.**

---

## The idea

Most banking apps treat you like an island. One person, one account, one screen. But real life is shared: families plan together, couples save for a home, roommates split bills, friends go on trips. Capital Circles is a Capital One product that lets people care for each other's financial wellness without ever combining accounts.

**Core principle:** privacy is a product feature, not a setting. Each circle type (family, couple, roommates, friends) has its own privacy rules, and those rules are enforced in code, not just a toggle.

---

## Team APA

| Person | Role |
| --- | --- |
| **Patricio Garza** | iOS, SwiftUI, design system, onboarding |
| **Alana Martinez** | Data model, privacy logic, Claude prompt, backend schema |
| **Adan Gonzalez** | API layer, goals/contributions, member search, integration |

Everyone touched everything. Roles above are a rough lead, not a wall.

---

## Demo in 30 seconds

1. User signs up with name + email (real write to Neon Postgres)
2. Picks a circle type and configures privacy up front
3. Invites members (live search against the DB) or by email
4. Creates optional shared goals
5. Enters the Hub: sees combined family spending, per-member wellness, Claude-generated AI insights, and a Capital One card optimizer

The full 4-minute pitch script lives in `Capital_Circles_Pitch.pdf` on the presenter's Desktop.

---

## Architecture

```
+----------------------------------------------------+
|                                                    |
|         iOS App (SwiftUI, iOS 17+)                 |
|                                                    |
|   Views  ->  @Observable AppStateManager           |
|                  |                                 |
|                  |  URLSession                     |
|                  v                                 |
+------------------+---------------------------------+
                   |
                   |  HTTPS (localhost for dev,
                   |         deployed server in prod)
                   v
+----------------------------------------------------+
|                                                    |
|   FastAPI backend (Python 3.11+)                   |
|                                                    |
|   /users, /circles, /goals, /contributions         |
|   /statements/generate  --->  Claude Sonnet 4.5    |
|                                                    |
+------------------+---------------------------------+
                   |
                   |  psycopg3
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

---

## Repository layout

```
APA/
|-- CapitalCircles/              # iOS app source
|   |-- App/                     # Entry point + asset catalog + ContentView
|   |-- Models/                  # User, Circle, Goal, Card, Transaction, SmartStatement
|   |-- Views/                   # SwiftUI views by feature area
|   |-- ViewModels/              # (future) reserved for dedicated VMs
|   |-- Services/                # APIClient, AppStateManager, ClaudeService, MockCardGenerator
|   |-- Components/              # Reusable UI (CCAvatar, CCSwitch, TransactionRow, etc.)
|   |-- Theme/                   # CCTheme: colors, typography, spacing, button styles
|   |-- Secrets.swift            # Gitignored. Claude key + backend URL
|   \-- Secrets.example.swift    # Template to copy into Secrets.swift
|-- backend/                     # Python FastAPI server
|   |-- main.py                  # API routes
|   |-- db.py                    # Postgres connection helpers
|   |-- models.py                # Pydantic request/response models
|   |-- claude_service.py        # Claude API integration
|   |-- schema.sql               # Postgres schema (auto-initialized)
|   |-- seed_db.py               # Optional: seed test users into Neon
|   \-- requirements.txt
|-- project.yml                  # XcodeGen spec
\-- README.md                    # You are here
```

---

## Feature overview

### Onboarding (multi-step)
1. **Welcome** — editorial headline
2. **Intro** — three principles
3. **Sign In** — name + email saved to Neon DB
4. **Circle Type** — family, couple, roommates, friends
5. **Circle Name** — with type-specific placeholder
6. **Privacy** — configurable sharing rules (the innovation)
7. **Members** — live search of DB or email invite
8. **First Goal** — optional
9. **Review** — summary before creating
10. **Enter your hub** — everything lands in the Hub

### The Hub
- **Hero card** with navy background and real Capital One red swoosh
- **Combined circle spending** for the month (respects privacy rules)
- **Financial Wellness** per-member rows with lock icons for private members
- **Goals** section only appears when goals exist (optional)
- **Quick actions** for Card Optimizer and Personal Goals
- **Recent activity** feed

### Insights (AI-powered)
- 4 months of history (Jan to Apr) with chronological picker
- Per-month narrative generated by **Claude Sonnet 4.5**
- Context-aware prompt includes circle name, members, and goals
- Refresh button triggers a live API call, gets a fresh take
- Category breakdown chart with Capital Circles navy bars

### Card Optimizer
- Every Capital One card the user owns
- Category picker with pills (Dining, Travel, Groceries, etc.)
- Highlights the BEST card for the selected category
- Shows reward rates from real Capital One products (Venture X, Venture, Savor, SavorOne, Quicksilver, Platinum)

### Circles and members
- Multi-step circle creation from the hub (type, name, members, privacy, goal, review)
- Privacy step per type with custom toggles
- Live search of existing users in the DB
- Email invite fallback for people not yet on the platform
- Member detail shows cards, transactions, and wellness **only if privacy allows**
- Nudges: send encouragement messages to circle members

### Goals
- Shared (circle-level) or personal (user-level)
- Progress bars and contribution history
- Real-time updates when contributing (UI + DB)
- Quick contribution amounts ($100, $500, $1000, $5000)
- Deletion with confirmation

### Notifications
- Tappable notifications with detail sheets
- Relative time ("5m ago", "2h ago", "3d ago")
- Mark as read, mark all as read
- Generated for milestones, new members, invites, nudges

---

## Privacy model

The heart of the product. Each circle type enforces different default rules.

| Data                    | Family              | Roommates | Friends  | Couple        |
| ----------------------- | ------------------- | --------- | -------- | ------------- |
| Shared goals            | Everyone            | Everyone  | Everyone | Everyone      |
| Goal progress           | Everyone            | Everyone  | Everyone | Everyone      |
| Personal spending       | Parents see kids    | Private   | Private  | Configurable  |
| Card details            | Parents see kids    | Private   | Private  | Configurable  |
| Spending categories     | Parents see kids    | Private   | Private  | Configurable  |
| Smart Statement         | Private             | Private   | Private  | Private       |
| Card Optimizer          | Private             | Private   | Private  | Private       |
| Children see parents    | **NEVER**           | N/A       | N/A      | N/A           |

**Hard-coded rules** (cannot be changed by toggles):
- Children (junior role in family circles) NEVER see parent finances
- Smart Statements and Card Optimizer are always private
- Each user can leave any circle at any time

**Configurable in onboarding:**
- Family: "Parents see kids" toggle, "Parents see each other" toggle
- Couple: "Share categories" toggle, "Share amounts" toggle
- Roommates and friends: locked to goals-only (informational)

---

## Tech stack

### iOS app
- **Language**: Swift 5.9
- **Framework**: SwiftUI with `@Observable` (iOS 17+)
- **Networking**: URLSession with async/await
- **Charts**: Apple Charts framework
- **State**: Single `@Observable` `AppStateManager` as source of truth
- **Design system**: Custom `CCTheme` (colors, typography, spacing, button styles)
- **Project generation**: XcodeGen (`project.yml`)

### Backend
- **Language**: Python 3.11+
- **Framework**: FastAPI with Pydantic models
- **Database driver**: psycopg3 (binary)
- **AI**: Anthropic Claude API (Claude Sonnet 4.5)
- **CORS**: Enabled for all origins (dev only)

### Database
- **Provider**: Neon (serverless PostgreSQL, cloud-hosted)
- **Schema**: auto-initialized from `schema.sql` on first startup
- **Tables**: users, cards, circles, circle_members, goals, contributions, transactions
- **Indexes**: on foreign keys and common query paths

### AI
- **Model**: Claude Sonnet 4.5 (`claude-sonnet-4-5-20250929`)
- **Prompt**: System prompt with the Capital Circles voice + context
- **Context injection**: Circle name, members, shared goals, personal goals
- **Output**: Strict JSON with narrative + insights

---

## Setup

### Prerequisites

- macOS with Xcode 16.3+
- Python 3.11+ with pip
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`

### Backend

```bash
cd backend
pip3 install 'psycopg[binary]' fastapi 'uvicorn[standard]' python-dotenv httpx
```

Create `backend/.env` (this file is gitignored):

```
DATABASE_URL=postgresql://<user>:<pass>@<host>/<db>?sslmode=require
CLAUDE_API_KEY=sk-ant-api03-...
PORT=8000
```

Run the server:

```bash
python3 -m uvicorn main:app --host 0.0.0.0 --port 8000
```

On first startup the schema is auto-initialized (`schema.sql` is executed automatically).

### iOS app

```bash
# From the project root
xcodegen generate
```

Create `CapitalCircles/Secrets.swift` (gitignored) with:

```swift
import Foundation

enum Secrets {
    static let claudeAPIKey = "sk-ant-api03-..."
    static let databaseURL = "postgresql://..."
    static let backendBaseURL: String? = "http://localhost:8000"
}
```

Open `CapitalCircles.xcodeproj`, set your signing team under **Signing & Capabilities**, and run on the iPhone 17 Pro simulator.

### Test flow

1. Open the app. Onboarding shows.
2. Tap `Get started`, `Continue`, `Continue` to reach Sign In.
3. Enter any name and email. The user is created in Neon.
4. Pick circle type, name it, configure privacy, invite members (search live), create a goal, review, and enter the hub.
5. Tap Insights to see AI-generated narratives. Tap refresh for a live Claude call.
6. Tap any member to see their data (enforced by privacy).

---

## How it scales

What we built is a **POC with a real backend**. Here is how it becomes a production-grade Capital One product.

### 1. Backend deployment

**Today**: FastAPI runs on localhost:8000 for development.

**Production path**:
- Deploy the backend to **AWS ECS**, **Fly.io**, or **Capital One's internal Kubernetes** with multiple replicas behind a load balancer
- Neon scales automatically via their serverless Postgres (autoscaling compute, branching for dev/staging/prod)
- Add **Redis** for session caching and rate limiting
- **OpenTelemetry** tracing for every request, exported to Datadog or Honeycomb

### 2. Authentication

**Today**: Email-based sign in, no password. For hackathon demo only.

**Production path**:
- Integrate **Capital One's existing OAuth 2.0 identity provider** (same as the Capital One mobile app)
- JWT bearer tokens on every request, validated server-side
- Refresh token rotation
- Biometric re-auth for sensitive operations (contributions, changing privacy)
- SCIM provisioning for family account linking

### 3. Data security

**Today**: Plain Postgres storage with SSL in transit.

**Production path**:
- **Field-level encryption** for personally identifiable information (email, name) using AWS KMS or Vault
- **Row-level security** in Postgres so users can only query their own rows
- **Audit logs** for every read/write on financial data, stored in a separate append-only log
- **PCI compliance** for any card data surfacing (we currently mock the card numbers; in prod they would come from Capital One's card API)
- GDPR/CCPA data export and deletion flows built into Profile settings

### 4. Privacy enforcement

**Today**: Privacy rules enforced in the iOS client (`canViewSpending`) and the backend trusts the client.

**Production path**:
- **Backend enforces privacy at the API layer**. Every query that returns financial data includes a `WHERE` clause that checks the requesting user's permissions
- A **policy engine** (OPA / Cedar) that encodes the privacy matrix centrally, called by every endpoint
- **Explicit consent flow** for cross-member data access, with audit trail
- Regular privacy audits and penetration testing

### 5. AI cost and reliability

**Today**: Every Insights refresh hits Claude directly with a fresh prompt.

**Production path**:
- **Prompt caching** (Anthropic's native feature) for the system prompt — reduces input tokens by ~90%
- Insights **cached per-user per-month**, regenerated on demand or when transactions change
- **Background job** that pre-generates insights overnight so the user sees them instantly
- **Fallback narratives** using rule-based templates when the API is unavailable
- **Cost ceiling per user per month** with graceful degradation

Back-of-envelope cost: with prompt caching, ~$0.002 per insight generation. Even with a million users refreshing weekly, that's ~$8k/month in AI costs. Negligible compared to the engagement lift.

### 6. Data model evolution

**Today**: Single Postgres schema with foreign keys.

**Production path**:
- **Event sourcing** for financial mutations (contributions, goal changes) so we can rebuild state and audit any change
- **Read replicas** for the analytical queries that power the Hub's per-member wellness view
- **Materialized views** for monthly aggregations that the Hub displays
- **Database sharding** by user ID when we cross 10M users
- **Time-series database** (TimescaleDB or ClickHouse) for transaction history beyond the last 90 days

### 7. Multi-device sync

**Today**: The iOS app reads from the backend on launch. Changes from other devices are not pushed in real time.

**Production path**:
- **WebSocket connection** per session for real-time updates (new contributions, circle changes, new members)
- **Push notifications** via APNs for events that happen while the app is closed
- **Optimistic UI updates** with conflict resolution when the server state disagrees
- **Offline mode** with local SwiftData cache that syncs on reconnect

### 8. Expansion beyond iOS

- **Android** via a React Native or native Kotlin port. The backend API is the single source of truth, so both clients work identically.
- **Web dashboard** for parents who prefer a desktop experience (same backend, Next.js frontend)
- **Embedded in the main Capital One app** as a first-class feature, sharing identity and card data natively
- **Apple Watch** widget showing the combined family spending and next goal milestone

### 9. Observability and operations

- **Structured logs** (JSON) shipped to Datadog or Splunk
- **Error tracking** via Sentry, grouped by user and release
- **Feature flags** (LaunchDarkly or Statsig) for gradual rollout of privacy changes
- **SLIs/SLOs**: p99 latency under 500ms for the Hub, 99.9% availability, AI refresh success rate above 99%
- **On-call rotation** for the backend and AI service

### 10. Compliance and regulation

- **SOC 2 Type II** audit for the backend and data stores
- **PSD2 / Open Banking** alignment for European expansion
- **Financial Conduct Authority** registration if operating outside the US
- **KYC/AML** integration via Capital One's existing identity systems

---

## What is and is not built

### Built and working
- Full iOS app with 20+ screens
- FastAPI backend with typed DTOs
- Neon Postgres with auto-initialized schema
- Real sign-in flow creating users in the DB
- Circle creation with privacy configuration
- Goal creation and contribution with live UI updates
- Member search against the database
- Claude AI insights with context injection
- 4 months of insight history
- Card optimizer with real Capital One card data
- Privacy model enforced in the UI
- Nudge system between members
- Multi-step onboarding with 9 steps
- Capital One design language end-to-end

### Mocked for the POC
- **Cards and transactions**: generated deterministically per user in the iOS client. In production these come from Capital One's card API.
- **Authentication**: email-based, no password. Production uses Capital One OAuth.
- **Backend deployment**: runs on localhost for development. Production is deployed.

### Not yet built
- Real-time sync between devices
- Push notifications
- Apple Watch app
- Android app
- Web dashboard

---

## Key decisions we made

**Why a Hub focused on wellness, not goals?**
Goals are a tool, not the point. Real families care about each other's ongoing financial health, not just saving for one thing at a time. So the Hub leads with financial wellness and shows goals as an optional section.

**Why enforce children cannot see parents as hard code?**
Because parents should never feel they have to hide from their kids to keep their own financial privacy. It is a dignity decision, not a technical one.

**Why Capital One red and navy?**
This is a Capital One product first and foremost. The design language is deliberately theirs, with the iconic red swoosh in the Hub hero.

**Why use Claude instead of a mock?**
Because a real Capital One product would use real AI, and we wanted to show we can integrate with production AI infrastructure. The prompt is engineered for the Capital Circles voice.

**Why SwiftUI with @Observable instead of UIKit?**
Faster to build, easier to iterate, and SwiftUI's declarative nature matches our editorial design language. `@Observable` removes most of the boilerplate of previous state management approaches.

---

## License

Built for the Capital One Hackathon at Tec de Monterrey. All code by Team APA (Patricio Garza, Alana Martinez, Adan Gonzalez).
