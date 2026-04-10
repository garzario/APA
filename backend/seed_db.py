"""Seed the Neon database with real APA team data so the app can connect for real."""
import uuid
import psycopg

DATABASE_URL = "postgresql://neondb_owner:REDACTED@ep-divine-frost-am8junnx-pooler.c-5.us-east-1.aws.neon.tech/neondb?sslmode=require"

# Fixed UUIDs for predictable team members
PATRICIO_ID = "11111111-1111-1111-1111-111111111111"
MARIA_ID = "22222222-2222-2222-2222-222222222222"
DIEGO_ID = "33333333-3333-3333-3333-333333333333"
ADAN_ID = "44444444-4444-4444-4444-444444444444"
ALANA_ID = "55555555-5555-5555-5555-555555555555"

FAMILY_CIRCLE_ID = "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"
TEAM_CIRCLE_ID = "ffffffff-ffff-ffff-ffff-ffffffffffff"


def seed():
    with psycopg.connect(DATABASE_URL) as conn:
        with conn.cursor() as cur:
            # Clean existing data
            cur.execute("TRUNCATE users, cards, circles, circle_members, goals, contributions, transactions RESTART IDENTITY CASCADE")

            # Users
            users = [
                (PATRICIO_ID, "Patricio Garza", "patriciogzaa@gmail.com", "person.circle.fill"),
                (MARIA_ID, "Maria Garza", "maria.garza@gmail.com", "person.circle"),
                (DIEGO_ID, "Diego Garza", "diego.garza@gmail.com", "figure.child.circle.fill"),
                (ADAN_ID, "Adan Gonzalez", "ehecatl16@hotmail.com", "person.fill"),
                (ALANA_ID, "Alana Martinez", "A00841524@tec.mx", "person.crop.circle.fill"),
            ]
            cur.executemany(
                "INSERT INTO users (id, name, email, avatar_icon) VALUES (%s, %s, %s, %s)",
                users,
            )

            # Cards
            cards = [
                (str(uuid.uuid4()), PATRICIO_ID, "Venture X", "4821", "ventureX", 2340.50, 15000, 45200),
                (str(uuid.uuid4()), PATRICIO_ID, "Savor One", "7193", "savor", 890.25, 8000, 12500),
                (str(uuid.uuid4()), MARIA_ID, "Quicksilver", "3056", "quicksilver", 1200, 10000, 8900),
                (str(uuid.uuid4()), ADAN_ID, "Venture", "9247", "venture", 3100, 12000, 32000),
                (str(uuid.uuid4()), ALANA_ID, "Savor One", "5544", "savor", 450, 6000, 6700),
            ]
            cur.executemany(
                """INSERT INTO cards (id, user_id, name, last_four, card_type, current_balance, credit_limit, rewards_balance)
                   VALUES (%s, %s, %s, %s, %s, %s, %s, %s)""",
                cards,
            )

            # Circles
            cur.execute(
                "INSERT INTO circles (id, name, type, icon_name, created_by) VALUES (%s, %s, %s, %s, %s)",
                (FAMILY_CIRCLE_ID, "Garza Family", "family", "house.fill", PATRICIO_ID),
            )
            cur.execute(
                "INSERT INTO circles (id, name, type, icon_name, created_by) VALUES (%s, %s, %s, %s, %s)",
                (TEAM_CIRCLE_ID, "Team APA", "friends", "person.3.fill", PATRICIO_ID),
            )

            # Circle members
            members = [
                (str(uuid.uuid4()), FAMILY_CIRCLE_ID, PATRICIO_ID, "admin", "goalsOnly"),
                (str(uuid.uuid4()), FAMILY_CIRCLE_ID, MARIA_ID, "admin", "goalsOnly"),
                (str(uuid.uuid4()), FAMILY_CIRCLE_ID, DIEGO_ID, "junior", "goalsOnly"),
                (str(uuid.uuid4()), TEAM_CIRCLE_ID, PATRICIO_ID, "admin", "goalsOnly"),
                (str(uuid.uuid4()), TEAM_CIRCLE_ID, ADAN_ID, "member", "goalsOnly"),
                (str(uuid.uuid4()), TEAM_CIRCLE_ID, ALANA_ID, "member", "goalsOnly"),
            ]
            cur.executemany(
                "INSERT INTO circle_members (id, circle_id, user_id, role, visibility) VALUES (%s, %s, %s, %s, %s)",
                members,
            )

            # Goals
            vacation_id = str(uuid.uuid4())
            emergency_id = str(uuid.uuid4())
            trip_id = str(uuid.uuid4())
            macbook_id = str(uuid.uuid4())

            goals = [
                (vacation_id, "Cancun Vacation", "sun.max.fill", 45000, 28500, "2026-07-15", True, FAMILY_CIRCLE_ID, PATRICIO_ID),
                (emergency_id, "Emergency Fund", "shield.fill", 60000, 42000, None, True, FAMILY_CIRCLE_ID, PATRICIO_ID),
                (trip_id, "Team Trip CDMX", "airplane", 15000, 9200, "2026-05-20", True, TEAM_CIRCLE_ID, PATRICIO_ID),
                (macbook_id, "MacBook Pro", "laptopcomputer", 35000, 21000, "2026-08-01", False, None, PATRICIO_ID),
            ]
            cur.executemany(
                """INSERT INTO goals (id, title, icon_name, target_amount, current_amount, deadline, is_shared, circle_id, owner_id)
                   VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)""",
                goals,
            )

        conn.commit()
        print("Database seeded successfully")

        # Verify
        with conn.cursor() as cur:
            for table in ["users", "cards", "circles", "circle_members", "goals"]:
                cur.execute(f"SELECT COUNT(*) FROM {table}")
                count = cur.fetchone()[0]
                print(f"  {table}: {count} rows")


if __name__ == "__main__":
    seed()
