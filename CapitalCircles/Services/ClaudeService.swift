import Foundation

/// Service for calling the Claude API to generate AI-powered Smart Statements.
/// In production this call would go through the Capital One backend to avoid
/// exposing API keys in the client, but for this POC we call the API directly.
enum ClaudeService {

    private static let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private static let model = "claude-sonnet-4-5-20250929"

    enum ClaudeError: Error, LocalizedError {
        case invalidResponse
        case decodingFailed(String)
        case httpError(Int)

        var errorDescription: String? {
            switch self {
            case .invalidResponse: return "Invalid response from Claude API"
            case .decodingFailed(let msg): return "Could not decode response: \(msg)"
            case .httpError(let code): return "HTTP error \(code)"
            }
        }
    }

    struct GeneratedStatement: Decodable {
        let narrative: String
        let insights: [GeneratedInsight]
    }

    struct GeneratedInsight: Decodable {
        let title: String
        let description: String
        let type: String
        let actionable: String?
    }

    static func generateSmartStatement(
        month: String,
        year: Int,
        totalSpent: Double,
        comparedToLastMonth: Double,
        categories: [CategorySpending]
    ) async throws -> GeneratedStatement {

        let categoriesText = categories.map { c in
            "- \(c.category.rawValue): $\(Int(c.amount)) (\(String(format: "%.1f", c.percentage))%, \(c.changeFromLastMonth >= 0 ? "+" : "")\(Int(c.changeFromLastMonth))% vs last month)"
        }.joined(separator: "\n")

        let prompt = """
        You are a financial insights AI for Capital Circles, a Capital One banking product.

        Analyze this user's \(month) \(year) spending and generate:
        1. A warm, encouraging 2-3 sentence narrative summary
        2. Exactly 4 actionable insights

        Monthly total: $\(Int(totalSpent))
        Change from last month: \(comparedToLastMonth >= 0 ? "+" : "")\(Int(comparedToLastMonth))%

        Category breakdown:
        \(categoriesText)

        Respond with ONLY valid JSON in this exact format:
        {
          "narrative": "2-3 sentence friendly summary",
          "insights": [
            {
              "title": "Short title (max 30 chars)",
              "description": "One sentence description",
              "type": "positive",
              "actionable": "Optional tip (or null)"
            }
          ]
        }

        Insight types must be one of: "positive", "warning", "tip", "milestone".
        Make insights specific to the data, actionable, and encouraging. Do not include any text outside the JSON.
        """

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue(Secrets.claudeAPIKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 1024,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw ClaudeError.httpError(http.statusCode)
        }

        // Parse Claude API response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let contentArray = json["content"] as? [[String: Any]],
              let firstContent = contentArray.first,
              let text = firstContent["text"] as? String else {
            throw ClaudeError.invalidResponse
        }

        // Strip markdown code fences if present
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

        guard let jsonData = cleaned.data(using: .utf8) else {
            throw ClaudeError.decodingFailed("Could not convert to data")
        }

        do {
            return try JSONDecoder().decode(GeneratedStatement.self, from: jsonData)
        } catch {
            throw ClaudeError.decodingFailed(error.localizedDescription)
        }
    }
}
