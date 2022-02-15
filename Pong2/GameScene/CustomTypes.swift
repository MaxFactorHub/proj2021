import SpriteKit

// MARK: - User
struct User: Encodable {
    var id: Int
    var position: CGPoint
    var ping: Double
}

// MARK: - Identifiers
struct Identifiers: Decodable {
    var id: Int
}

// MARK: - Enemy
struct Enemy: Decodable {
    var position: CGPoint
    var ping: Double
}

// MARK: - Connection
struct Connection: Decodable {
    var isConnected: Bool
}

// MARK: - Disconnect
struct Disconnect: Codable {
    var id: Int
    let disconnect = true
}

// MARK: - GameType
enum GameType {
    case offline
    case player2
    case online
}

// MARK: - GameType
enum DecodeType {
    case enemy
    case identifiers
    case connection
}

// MARK: - GameType
enum PositionType {
    case zero
    case negative
    case positive
}
