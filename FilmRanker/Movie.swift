import Foundation

struct Movie: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let year: String
    let director: String
    let poster: String
    var rank: Int?
    var watchDate: Date?
    var review: String?
    var isRankingComplete: Bool = false

    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
}

