import SwiftUI

struct RankingView: View {
    @EnvironmentObject var movieStore: MovieStore
    @State private var movie: Movie
    @State private var comparisonMovie: Movie?
    @State private var currentRank: Int
    @State private var lowerBound: Int
    @State private var upperBound: Int
    @Environment(\.presentationMode) var presentationMode
    
    init(movie: Movie) {
        _movie = State(initialValue: movie)
        _currentRank = State(initialValue: 0)
        _lowerBound = State(initialValue: 1)
        _upperBound = State(initialValue: 0)
    }
    
    var body: some View {
        VStack {
            if let comparisonMovie = comparisonMovie {
                Text("Tap the poster of the movie you prefer")
                    .font(.headline)
                    .padding()
                
                HStack(spacing: 20) {
                    MoviePosterView(movie: movie, action: { updateRanking(preferred: movie) })
                    MoviePosterView(movie: comparisonMovie, action: { updateRanking(preferred: comparisonMovie) })
                }
            } else {
                Text("Ranking complete!")
                Text("Final rank: \(currentRank)")
                
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        .navigationTitle("Rank Movie")
        .onAppear {
            initializeRanking()
        }
    }
    
    private func initializeRanking() {
        let rankedMovies = movieStore.movies.filter { $0.isRankingComplete }
        upperBound = rankedMovies.count + 1
        
        if rankedMovies.count == 1 {
            // If this is the second movie, compare it directly with the first one
            comparisonMovie = rankedMovies.first
        } else if rankedMovies.count > 1 {
            selectComparisonMovie()
        } else {
            finalizeRanking()
        }
    }
    
    private func selectComparisonMovie() {
        let midRank = (lowerBound + upperBound) / 2
        comparisonMovie = movieStore.movies
            .filter { $0.isRankingComplete && $0.id != movie.id }
            .min(by: { abs($0.rank! - midRank) < abs($1.rank! - midRank) })
        
        if comparisonMovie == nil {
            finalizeRanking()
        }
    }
    
    private func updateRanking(preferred: Movie) {
        if preferred.id == movie.id {
            upperBound = (lowerBound + upperBound) / 2
        } else {
            lowerBound = (lowerBound + upperBound) / 2 + 1
        }
        
        if lowerBound == upperBound {
            finalizeRanking()
        } else {
            selectComparisonMovie()
        }
    }
    
    private func finalizeRanking() {
        currentRank = lowerBound
        movieStore.updateMovieRank(movie, newRank: currentRank)
        comparisonMovie = nil
    }
}

struct MoviePosterView: View {
    let movie: Movie
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                AsyncImage(url: URL(string: movie.poster)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 200)
                .cornerRadius(10)
                .shadow(radius: 5)
                
                Text(movie.title)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text(movie.year)
                    .font(.caption2)
                
                Text(movie.director)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 150)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

