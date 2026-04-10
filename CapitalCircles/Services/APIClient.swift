import Foundation

/// HTTP client that talks to the Capital Circles backend API.
/// All network calls go through here. In production this would include
/// OAuth bearer tokens and retry logic.
enum APIClient {

    static var baseURL: URL {
        URL(string: Secrets.backendBaseURL ?? "http://localhost:8000")!
    }

    enum APIError: Error, LocalizedError {
        case invalidResponse
        case httpError(Int, String?)
        case decoding(String)

        var errorDescription: String? {
            switch self {
            case .invalidResponse: return "Invalid response from server"
            case .httpError(let code, let msg):
                if let msg { return "HTTP \(code): \(msg)" }
                return "HTTP error \(code)"
            case .decoding(let msg): return "Decoding failed: \(msg)"
            }
        }
    }

    // MARK: - Request helpers

    static func get<T: Decodable>(_ path: String) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response, data: data)
        return try decode(data)
    }

    static func post<Body: Encodable, Response: Decodable>(_ path: String, body: Body) async throws -> Response {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(body)
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response, data: data)
        return try decode(data)
    }

    private static func validate(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8)
            throw APIError.httpError(http.statusCode, msg)
        }
    }

    private static func decode<T: Decodable>(_ data: Data) throws -> T {
        let decoder = JSONDecoder()
        // Neon returns timestamps as ISO strings with or without fractional seconds
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            if let d = formatter.date(from: str) { return d }
            formatter.formatOptions = [.withInternetDateTime]
            if let d = formatter.date(from: str) { return d }
            // Fall back to simple date
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            if let d = df.date(from: str) { return d }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unparseable date \(str)")
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error.localizedDescription)
        }
    }
}

// MARK: - API DTOs

struct APIUser: Codable {
    let id: UUID
    let name: String
    let email: String
    let avatarIcon: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case avatarIcon = "avatar_icon"
        case createdAt = "created_at"
    }
}

struct APIUserCreate: Codable {
    let name: String
    let email: String
    let avatarIcon: String

    enum CodingKeys: String, CodingKey {
        case name, email
        case avatarIcon = "avatar_icon"
    }
}

struct APICircle: Codable {
    let id: UUID
    let name: String
    let type: String
    let iconName: String
    let createdBy: UUID
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, type
        case iconName = "icon_name"
        case createdBy = "created_by"
        case createdAt = "created_at"
    }
}

struct APICircleCreate: Codable {
    let name: String
    let type: String
    let iconName: String
    let createdBy: UUID

    enum CodingKeys: String, CodingKey {
        case name, type
        case iconName = "icon_name"
        case createdBy = "created_by"
    }
}

struct APICircleMemberCreate: Codable {
    let circleId: UUID
    let userId: UUID
    let role: String
    let visibility: String

    enum CodingKeys: String, CodingKey {
        case circleId = "circle_id"
        case userId = "user_id"
        case role, visibility
    }
}

struct APICircleMember: Codable {
    let id: UUID
    let circleId: UUID
    let userId: UUID
    let role: String
    let visibility: String
    /// Present when fetched via /circles/{id}/members (joined with users table)
    let name: String?
    let email: String?
    let avatarIcon: String?

    enum CodingKeys: String, CodingKey {
        case id, role, visibility, name, email
        case circleId = "circle_id"
        case userId = "user_id"
        case avatarIcon = "avatar_icon"
    }
}

struct APIGoal: Codable {
    let id: UUID
    let title: String
    let iconName: String
    let targetAmount: Double
    let currentAmount: Double
    let deadline: String?
    let isShared: Bool
    let circleId: UUID?
    let ownerId: UUID

    enum CodingKeys: String, CodingKey {
        case id, title, deadline
        case iconName = "icon_name"
        case targetAmount = "target_amount"
        case currentAmount = "current_amount"
        case isShared = "is_shared"
        case circleId = "circle_id"
        case ownerId = "owner_id"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        iconName = try c.decode(String.self, forKey: .iconName)
        // Backend returns Decimal as String via JSON; handle both
        if let d = try? c.decode(Double.self, forKey: .targetAmount) {
            targetAmount = d
        } else {
            let s = try c.decode(String.self, forKey: .targetAmount)
            targetAmount = Double(s) ?? 0
        }
        if let d = try? c.decode(Double.self, forKey: .currentAmount) {
            currentAmount = d
        } else {
            let s = try c.decode(String.self, forKey: .currentAmount)
            currentAmount = Double(s) ?? 0
        }
        deadline = try c.decodeIfPresent(String.self, forKey: .deadline)
        isShared = try c.decode(Bool.self, forKey: .isShared)
        circleId = try c.decodeIfPresent(UUID.self, forKey: .circleId)
        ownerId = try c.decode(UUID.self, forKey: .ownerId)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(iconName, forKey: .iconName)
        try c.encode(targetAmount, forKey: .targetAmount)
        try c.encode(currentAmount, forKey: .currentAmount)
        try c.encodeIfPresent(deadline, forKey: .deadline)
        try c.encode(isShared, forKey: .isShared)
        try c.encodeIfPresent(circleId, forKey: .circleId)
        try c.encode(ownerId, forKey: .ownerId)
    }
}

struct APIGoalCreate: Codable {
    let title: String
    let iconName: String
    let targetAmount: Double
    let currentAmount: Double
    let deadline: String?
    let isShared: Bool
    let circleId: UUID?
    let ownerId: UUID

    enum CodingKeys: String, CodingKey {
        case title, deadline
        case iconName = "icon_name"
        case targetAmount = "target_amount"
        case currentAmount = "current_amount"
        case isShared = "is_shared"
        case circleId = "circle_id"
        case ownerId = "owner_id"
    }
}

struct APIContributionCreate: Codable {
    let goalId: UUID
    let userId: UUID
    let amount: Double
    let note: String?

    enum CodingKeys: String, CodingKey {
        case amount, note
        case goalId = "goal_id"
        case userId = "user_id"
    }
}

struct APIContribution: Codable {
    let id: UUID
    let goalId: UUID
    let userId: UUID
    let amount: Double
    let note: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, note
        case goalId = "goal_id"
        case userId = "user_id"
        case amount
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        goalId = try c.decode(UUID.self, forKey: .goalId)
        userId = try c.decode(UUID.self, forKey: .userId)
        if let d = try? c.decode(Double.self, forKey: .amount) {
            amount = d
        } else {
            let s = try c.decode(String.self, forKey: .amount)
            amount = Double(s) ?? 0
        }
        note = try c.decodeIfPresent(String.self, forKey: .note)
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt)
    }
}

// MARK: - Endpoints

enum UserAPI {
    static func create(name: String, email: String) async throws -> APIUser {
        try await APIClient.post("/users", body: APIUserCreate(name: name, email: email, avatarIcon: "person.circle.fill"))
    }

    static func get(id: UUID) async throws -> APIUser {
        try await APIClient.get("/users/\(id.uuidString)")
    }

    static func getByEmail(_ email: String) async throws -> APIUser {
        try await APIClient.get("/users/email/\(email)")
    }
}

enum CircleAPI {
    static func list(forUser userId: UUID) async throws -> [APICircle] {
        try await APIClient.get("/users/\(userId.uuidString)/circles")
    }

    static func create(_ payload: APICircleCreate) async throws -> APICircle {
        try await APIClient.post("/circles", body: payload)
    }

    static func addMember(_ payload: APICircleMemberCreate) async throws -> APICircleMember {
        try await APIClient.post("/circles/members", body: payload)
    }

    static func members(circleId: UUID) async throws -> [APICircleMember] {
        try await APIClient.get("/circles/\(circleId.uuidString)/members")
    }
}

enum GoalAPI {
    static func list(forUser userId: UUID) async throws -> [APIGoal] {
        try await APIClient.get("/users/\(userId.uuidString)/goals")
    }

    static func create(_ payload: APIGoalCreate) async throws -> APIGoal {
        try await APIClient.post("/goals", body: payload)
    }

    static func contribute(_ payload: APIContributionCreate) async throws -> APIContribution {
        try await APIClient.post("/contributions", body: payload)
    }
}
