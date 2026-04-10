import Foundation

/// HTTP client for the Capital Circles backend API.
/// The base URL is read from `Secrets.backendBaseURL` when available.
/// When not set, the app operates in local-only mode using AppStateManager.
enum NetworkService {

    static var baseURL: URL? {
        guard let urlString = Secrets.backendBaseURL, !urlString.isEmpty else {
            return nil
        }
        return URL(string: urlString)
    }

    static var isConfigured: Bool {
        baseURL != nil
    }

    enum NetworkError: Error, LocalizedError {
        case notConfigured
        case invalidResponse
        case httpError(Int)
        case decoding(String)

        var errorDescription: String? {
            switch self {
            case .notConfigured: return "Backend not configured"
            case .invalidResponse: return "Invalid response from server"
            case .httpError(let code): return "Server error \(code)"
            case .decoding(let msg): return "Decoding failed: \(msg)"
            }
        }
    }

    // MARK: - Users

    static func fetchUser(id: UUID) async throws -> APIUser {
        try await get("/users/\(id.uuidString)")
    }

    static func fetchUserByEmail(_ email: String) async throws -> APIUser {
        try await get("/users/email/\(email)")
    }

    // MARK: - Circles

    static func fetchCircles(for userId: UUID) async throws -> [APICircle] {
        try await get("/users/\(userId.uuidString)/circles")
    }

    static func createCircle(_ payload: APICircleCreate) async throws -> APICircle {
        try await post("/circles", body: payload)
    }

    // MARK: - Goals

    static func fetchGoals(for userId: UUID) async throws -> [APIGoal] {
        try await get("/users/\(userId.uuidString)/goals")
    }

    static func createGoal(_ payload: APIGoalCreate) async throws -> APIGoal {
        try await post("/goals", body: payload)
    }

    static func addContribution(_ payload: APIContributionCreate) async throws -> APIContribution {
        try await post("/contributions", body: payload)
    }

    // MARK: - HTTP helpers

    private static func get<T: Decodable>(_ path: String) async throws -> T {
        guard let baseURL else { throw NetworkError.notConfigured }
        let url = baseURL.appendingPathComponent(path)
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response)
        return try decode(data)
    }

    private static func post<Body: Encodable, Response: Decodable>(_ path: String, body: Body) async throws -> Response {
        guard let baseURL else { throw NetworkError.notConfigured }
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response)
        return try decode(data)
    }

    private static func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.httpError(http.statusCode)
        }
    }

    private static func decode<T: Decodable>(_ data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error.localizedDescription)
        }
    }
}

// MARK: - API DTOs

struct APIUser: Codable {
    let id: UUID
    let name: String
    let email: String
    let avatarIcon: String

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case avatarIcon = "avatar_icon"
    }
}

struct APICircle: Codable {
    let id: UUID
    let name: String
    let type: String
    let iconName: String
    let createdBy: UUID

    enum CodingKeys: String, CodingKey {
        case id, name, type
        case iconName = "icon_name"
        case createdBy = "created_by"
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

struct APIGoal: Codable {
    let id: UUID
    let title: String
    let iconName: String
    let targetAmount: Double
    let currentAmount: Double
    let isShared: Bool
    let circleId: UUID?
    let ownerId: UUID

    enum CodingKeys: String, CodingKey {
        case id, title
        case iconName = "icon_name"
        case targetAmount = "target_amount"
        case currentAmount = "current_amount"
        case isShared = "is_shared"
        case circleId = "circle_id"
        case ownerId = "owner_id"
    }
}

struct APIGoalCreate: Codable {
    let title: String
    let iconName: String
    let targetAmount: Double
    let isShared: Bool
    let circleId: UUID?
    let ownerId: UUID

    enum CodingKeys: String, CodingKey {
        case title
        case iconName = "icon_name"
        case targetAmount = "target_amount"
        case isShared = "is_shared"
        case circleId = "circle_id"
        case ownerId = "owner_id"
    }
}

struct APIContribution: Codable {
    let id: UUID
    let goalId: UUID
    let userId: UUID
    let amount: Double

    enum CodingKeys: String, CodingKey {
        case id, amount
        case goalId = "goal_id"
        case userId = "user_id"
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
