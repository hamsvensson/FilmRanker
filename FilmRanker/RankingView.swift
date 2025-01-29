import SwiftUI

struct RankingView: View {
    let movie: Movie
    @EnvironmentObject var movieStore: MovieStore
    @State private var newRank: Int = 1
    
    var body: some View {
        VStack {
            Text("Rank \(movie.title)")
                .font(.title)
            
            Stepper(value: $newRank, in: 1...movieStore.movies.count) {
                Text("Rank: \(newRank)")
            }
            .padding()
            
            Button("Update Rank") {
                updateRank()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    func updateRank() {
        movieStore.updateMovieRank(movie, newRank: newRank)
    }
}

struct RankingView_Previews: PreviewProvider {
    static var previews: some View {
        RankingView(movie: Movie(id: "1", title: "Sample Movie", year: "2021", director: "Director", poster: "", rank: nil, watchDate: nil, review: "", isRankingComplete: false))
            .environmentObject(MovieStore())
    }
}
