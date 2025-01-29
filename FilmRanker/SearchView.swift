import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults: [Movie] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchTask: Task<Void, Never>?
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    Text("No results...")
                        .foregroundColor(.secondary)
                } else {
                    List(searchResults) { movie in
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
                                    Text(movie.year)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search Movies")
        }
        .searchable(text: $searchText, prompt: "Search for a movie")
        .onChange(of: searchText) { _ in
            searchTask?.cancel()
            searchTask = Task {
                await searchMovies()
            }
        }
    }
    
    func searchMovies() async {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let results = try await MovieAPIService.shared.searchMovies(query: searchText)
            await MainActor.run {
                searchResults = results
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "An error occurred while searching. Please try again."
                isLoading = false
            }
        }
    }
}

