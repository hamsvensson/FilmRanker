import SwiftUI

struct LoggedMoviesView: View {
    @EnvironmentObject var movieStore: MovieStore
    
    var body: some View {
        NavigationView {
            List(movieStore.movies.sorted(by: { ($0.rank ?? 0) < ($1.rank ?? 0) })) { movie in
                NavigationLink(destination: MovieDetailView(movie: movie)) {
                    HStack {
                        AsyncImage(url: URL(string: movie.poster)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 50, height: 75)
                        
                        VStack(alignment: .leading) {
                            Text(movie.title)
                                .font(.headline)
                            if let rank = movie.rank {
                                Text("Rank: \(rank)")
                                    .font(.subheadline)
                            } else {
                                Text("Unranked")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Movies")
        }
    }
}

