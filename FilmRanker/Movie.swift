import Foundation

struct Movie: Identifiable, Codable {
    var id: String
    var title: String
    var year: String
    var director: String
    var poster: String
    var rank: Int?
    var watchDate: Date?
    var review: String?
    var isRankingComplete: Bool
}
