"""Claude AI service for generating Smart Statements."""
import os
import json
import httpx
from dotenv import load_dotenv

load_dotenv()

CLAUDE_API_KEY = os.getenv("CLAUDE_API_KEY")
CLAUDE_API_URL = "https://api.anthropic.com/v1/messages"
MODEL = "claude-sonnet-4-5-20250929"


async def generate_smart_statement(
    month: str,
    year: int,
    total_spent: float,
    categories: list[dict],
    compared_to_last_month: float,
) -> dict:
    """Generate an AI-powered Smart Statement using Claude."""

    categories_text = "\n".join([
        f"- {c['category']}: ${c['amount']:.0f} ({c['percentage']:.1f}%, "
        f"{'+' if c['change'] >= 0 else ''}{c['change']:.0f}% vs last month)"
        for c in categories
    ])

    prompt = f"""You are a financial insights AI for Capital Circles, a Capital One banking product.

Analyze this user's {month} {year} spending and generate:
1. A warm, encouraging 2-3 sentence narrative summary
2. Exactly 4 actionable insights

Monthly total: ${total_spent:.0f}
Change from last month: {compared_to_last_month:+.0f}%

Category breakdown:
{categories_text}

Respond with ONLY valid JSON in this exact format:
{{
  "narrative": "2-3 sentence friendly summary",
  "insights": [
    {{
      "title": "Short title (max 30 chars)",
      "description": "One sentence description",
      "type": "positive",
      "actionable": "Optional tip (or null)"
    }}
  ]
}}

Insight types must be one of: "positive", "warning", "tip", "milestone".
Make insights specific to the data, actionable, and encouraging. Do not include any text outside the JSON."""

    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.post(
            CLAUDE_API_URL,
            headers={
                "x-api-key": CLAUDE_API_KEY,
                "anthropic-version": "2023-06-01",
                "content-type": "application/json",
            },
            json={
                "model": MODEL,
                "max_tokens": 1024,
                "messages": [{"role": "user", "content": prompt}],
            },
        )
        response.raise_for_status()
        data = response.json()

    content = data["content"][0]["text"].strip()
    if content.startswith("```"):
        content = content.split("```")[1]
        if content.startswith("json"):
            content = content[4:]
        content = content.strip()

    return json.loads(content)
