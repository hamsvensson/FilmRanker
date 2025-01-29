import Foundation

class MovieAPIService {
    static let shared = MovieAPIService()
    private let apiKey = "52ee102a"
    private let baseURL = "https://www.omdbapi.com/"
    
    private init() {}
    
    func searchMovies(query: String) async throws -> [Movie] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?apikey=\(apiKey)&s=\(encodedQuery)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
        
        if searchResponse.Search.isEmpty {
            return []
        }
        
        return try await withThrowingTaskGroup(of: Movie?.self) { group in
            for searchResult in searchResponse.Search {
                group.addTask {
                    do {
                        return try await self.getMovieDetails(id: searchResult.imdbID)
                    } catch {
                        print("Error fetching details for movie \(searchResult.imdbID): \(error)")
                        return nil
                    }
                }
            }
            
            var movies: [Movie] = []
            for try await movie in group {
                if let movie = movie {
                    movies.append(movie)
                }
            }
            
            return movies
        }
    }
    
    func getMovieDetails(id: String) async throws -> Movie {
        guard let url = URL(string: "\(baseURL)?apikey=\(apiKey)&i=\(id)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let movieDetails = try JSONDecoder().decode(MovieDetails.self, from: data)
        
        return Movie(id: movieDetails.imdbID,
                     title: movieDetails.Title,
                     year: movieDetails.Year,
                     director: movieDetails.Director,
                     poster: movieDetails.Poster,
                     rank: nil,
                     watchDate: nil,
                     review: nil,
                     isRankingComplete: false)
    }
}

struct SearchResponse: Codable {
    let Search: [SearchResult]
    let totalResults: String
    let Response: String
}

struct SearchResult: Codable {
    let Title: String
    let Year: String
    let imdbID: String
    let Poster: String
}

struct MovieDetails: Codable {
    let Title: String
    let Year: String
    let Director: String
    let Poster: String
    let imdbID: String
}

