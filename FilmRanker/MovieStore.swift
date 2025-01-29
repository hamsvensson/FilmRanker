import Foundation

class MovieStore: ObservableObject {
    @Published var movies: [Movie] = []
    
    private let userDefaults = UserDefaults.standard
    private let moviesKey = "loggedMovies"
    
    init() {
        loadMovies()
    }
    
    func loadMovies() {
        if let data = userDefaults.data(forKey: moviesKey),
           let decodedMovies = try? JSONDecoder().decode([Movie].self, from: data) {
            movies = decodedMovies
        }
    }
    
    func saveMovies() {
        if let encodedMovies = try? JSONEncoder().encode(movies) {
            userDefaults.set(encodedMovies, forKey: moviesKey)
        }
    }
    
    func addOrUpdateMovie(_ movie: Movie) -> Bool {
        let isFirstMovie = movies.isEmpty
        
        if let index = movies.firstIndex(where: { $0.id == movie.id }) {
            let oldRank = movies[index].rank
            movies[index] = movie
            if oldRank != nil {
                // Remove the old rank and shift other movies up
                shiftRanksAfterRemoval(oldRank!)
            }
        } else {
            var updatedMovie = movie
            if isFirstMovie {
                updatedMovie.rank = 1
                updatedMovie.isRankingComplete = true
            }
            movies.append(updatedMovie)
        }
        saveMovies()
        
        return isFirstMovie
    }
    
    func updateMovieRank(_ movie: Movie, newRank: Int) {
        guard let index = movies.firstIndex(where: { $0.id == movie.id }) else { return }
        
        let oldRank = movies[index].rank
        var updatedMovie = movies[index]
        updatedMovie.rank = newRank
        updatedMovie.isRankingComplete = true
        movies[index] = updatedMovie
        
        // Adjust ranks of other movies
        if let oldRank = oldRank {
            if oldRank < newRank {
                // Movie moved down, shift other movies up
                for i in 0..<movies.count {
                    if i != index && movies[i].isRankingComplete {
                        if let rank = movies[i].rank, rank > oldRank && rank <= newRank {
                            movies[i].rank = rank - 1
                        }
                    }
                }
            } else if oldRank > newRank {
                // Movie moved up, shift other movies down
                for i in 0..<movies.count {
                    if i != index && movies[i].isRankingComplete {
                        if let rank = movies[i].rank, rank >= newRank && rank < oldRank {
                            movies[i].rank = rank + 1
                        }
                    }
                }
            }
        } else {
            // New ranking, shift other movies down
            for i in 0..<movies.count {
                if i != index && movies[i].isRankingComplete {
                    if let rank = movies[i].rank, rank >= newRank {
                        movies[i].rank = rank + 1
                    }
                }
            }
        }
        
        saveMovies()
    }
    
    private func shiftRanksAfterRemoval(_ removedRank: Int) {
        for i in 0..<movies.count {
            if movies[i].isRankingComplete, let rank = movies[i].rank, rank > removedRank {
                movies[i].rank = rank - 1
            }
        }
    }
    
    func getNextUnrankedMovie() -> Movie? {
        return movies.first { !$0.isRankingComplete }
    }
}
