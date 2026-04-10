import Foundation

/// Service for calling the Claude API to generate Smart Insights.
/// The voice is Capital One editorial: confident, warm, concise, human.
/// Insights connect spending to what the user and their circle are working toward.
enum ClaudeService {

    private static let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private static let model = "claude-sonnet-4-5-20250929"

    enum ClaudeError: Error, LocalizedError {
        case notConfigured
        case httpError(Int, String?)
        case invalidResponse
        case decodingFailed(String)

        var errorDescription: String? {
            switch self {
            case .notConfigured: return "Claude API is not configured"
            case .httpError(let code, let message):
                if let message { return "Server error \(code): \(message)" }
                return "Server error \(code)"
            case .invalidResponse: return "Could not read Claude's response"
            case .decodingFailed(let msg): return "Response format unexpected: \(msg)"
            }
        }
    }

    struct GeneratedStatement {
        let narrative: String
        let insights: [GeneratedInsight]
    }

    struct GeneratedInsight {
        let title: String
        let description: String
        let type: String
        let actionable: String?
    }

    /// Context the user gives us about their circles and goals, so Claude
    /// can write insights that reference real people and real saving goals.
    struct Context {
        let userName: String
        let circleName: String?
        let circleMembers: [String]
        let sharedGoals: [(title: String, progress: Double)]
        let personalGoals: [(title: String, progress: Double)]
    }

    static func generateSmartStatement(
        month: String,
        year: Int,
        totalSpent: Double,
        comparedToLastMonth: Double,
        categories: [CategorySpending],
        context: Context
    ) async throws -> GeneratedStatement {

        let categoriesText = categories.map { c in
            "- \(c.category.rawValue): $\(Int(c.amount)) (\(String(format: "%.1f", c.percentage))%, \(c.changeFromLastMonth >= 0 ? "+" : "")\(Int(c.changeFromLastMonth))% vs last month)"
        }.joined(separator: "\n")

        let membersText = context.circleMembers.isEmpty ? "None" : context.circleMembers.joined(separator: ", ")
        let sharedGoalsText = context.sharedGoals.isEmpty
            ? "None"
            : context.sharedGoals.map { "\($0.title) (\(Int($0.progress * 100))% complete)" }.joined(separator: ", ")
        let personalGoalsText = context.personalGoals.isEmpty
            ? "None"
            : context.personalGoals.map { "\($0.title) (\(Int($0.progress * 100))% complete)" }.joined(separator: ", ")

        let systemPrompt = """
        You are the voice of Capital Circles, a Capital One banking product for families, friends, and roommates who want to reach financial goals together without combining their accounts. Your personality:

        - Warm, human, and specific. Not corporate. Not AI-generic.
        - Confident but never preachy. You sound like a trusted friend who happens to be a financial expert.
        - Editorial and direct. Every sentence earns its place.
        - Focused on relationships and shared progress, not just numbers.
        - Writes in American English. Simple vocabulary. No jargon. No em dashes. No emoji.

        You are writing for \(context.userName), who is part of the circle "\(context.circleName ?? "their circle")".
        Their circle members are: \(membersText).
        Their circle's shared goals: \(sharedGoalsText).
        \(context.userName)'s personal goals: \(personalGoalsText).

        When you write insights, reference the circle and the goals by name when it's relevant. Make the user feel seen. Make progress feel like a team effort.
        """

        let userPrompt = """
        Write a Smart Insights summary for \(context.userName)'s \(month) \(year) spending.

        Monthly total: $\(Int(totalSpent).formatted())
        Change from last month: \(comparedToLastMonth >= 0 ? "+" : "")\(Int(comparedToLastMonth))%

        Category breakdown:
        \(categoriesText)

        Generate exactly:
        1. A narrative: 2-3 sentences, warm and specific to \(context.userName). Reference the circle or a goal by name if it feels natural. Do NOT start with "You" as the very first word.
        2. Exactly 4 insights. Each one should be honest and actionable.

        Insight types must be one of: "positive", "warning", "tip", "milestone".
        - positive: celebrating something they did well
        - warning: something to watch
        - tip: an actionable suggestion
        - milestone: progress toward a goal

        At least one insight should reference a specific goal from their list if possible.

        Respond with ONLY valid JSON in this exact shape, nothing else:
        {
          "narrative": "...",
          "insights": [
            {"title": "max 32 chars", "description": "one sentence", "type": "positive", "actionable": "short tip or null"}
          ]
        }
        """

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue(Secrets.claudeAPIKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 1500,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": userPrompt]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            // Extract error message from response body if possible
            var serverMessage: String?
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                serverMessage = message
            }
            throw ClaudeError.httpError(http.statusCode, serverMessage)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let contentArray = json["content"] as? [[String: Any]],
              let firstContent = contentArray.first,
              let text = firstContent["text"] as? String else {
            throw ClaudeError.invalidResponse
        }

        // Strip any markdown code fences
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("```") {
            if let range = cleaned.range(of: "\n") {
                cleaned = String(cleaned[range.upperBound...])
            }
            if cleaned.hasSuffix("```") {
                cleaned = String(cleaned.dropLast(3))
            }
            cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        guard let jsonData = cleaned.data(using: .utf8),
              let parsed = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let narrative = parsed["narrative"] as? String,
              let insightsData = parsed["insights"] as? [[String: Any]] else {
            throw ClaudeError.decodingFailed("Could not parse JSON from Claude response")
        }

        let insights = insightsData.compactMap { dict -> GeneratedInsight? in
            guard let title = dict["title"] as? String,
                  let description = dict["description"] as? String,
                  let type = dict["type"] as? String else { return nil }
            let actionable = dict["actionable"] as? String
            return GeneratedInsight(
                title: title,
                description: description,
                type: type,
                actionable: actionable == "null" ? nil : actionable
            )
        }

        return GeneratedStatement(narrative: narrative, insights: insights)
    }
}
