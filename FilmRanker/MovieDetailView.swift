import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    let isLogged: Bool
    @EnvironmentObject var movieStore: MovieStore
    @State private var watchDate: Date
    @State private var review: String
    @State private var isEditing: Bool = false
    @State private var showingRankingView = false
    @State private var showingFirstMovieAlert = false
    @State private var showingRelogAlert = false
    @State private var loggedMovie: Movie?
    @Environment(\.presentationMode) var presentationMode
    
    init(movie: Movie, isLogged: Bool = false) {
        self.movie = movie
        self.isLogged = isLogged
        _watchDate = State(initialValue: movie.watchDate ?? Date())
        _review = State(initialValue: movie.review ?? "")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: movie.poster)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                
                Text(movie.title)
                    .font(.title)
                
                Text("Directed by \(movie.director)")
                    .font(.subheadline)
                
                DatePicker("Watch Date", selection: $watchDate, displayedComponents: .date)
                    .disabled(!isEditing && isLogged)
                
                TextEditor(text: $review)
                    .frame(height: 100)
                    .border(Color.gray, width: 1)
                    .disabled(!isEditing && isLogged)
                
                if isLogged {
                    HStack {
                        Button(isEditing ? "Save" : "Edit") {
                            if isEditing {
                                saveChanges()
                            }
                            isEditing.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if isEditing {
                            Button("Cancel") {
                                cancelChanges()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                
                Button("Log Movie") {
                    if movieStore.movies.contains(where: { $0.id == movie.id }) {
                        showingRelogAlert = true
                    } else {
                        logMovie()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isEditing) // Disable log button when editing
            }
            .padding()
        }
        .navigationTitle("Movie Details")
        .sheet(isPresented: $showingRankingView) {
            if let movieToRank = loggedMovie {
                RankingView(movie: movieToRank)
            }
        }
        .alert(isPresented: $showingFirstMovieAlert) {
            Alert(
                title: Text("First Movie Logged"),
                message: Text("Congratulations! You've logged your first movie. It has been automatically ranked as #1."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .alert("Re-log Movie", isPresented: $showingRelogAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Continue") {
                logMovie()
            }
        } message: {
            Text("You're about to log a film you've already seen. This will overwrite the film's previous rank. Do you want to continue?")
        }
    }
    
    func saveChanges() {
        // Save the changes to the movie
        let updatedMovie = Movie(id: movie.id,
                                 title: movie.title,
                                 year: movie.year,
                                 director: movie.director,
                                 poster: movie.poster,
                                 rank: movie.rank,
                                 watchDate: watchDate,
                                 review: review,
                                 isRankingComplete: movie.isRankingComplete)
        movieStore.addOrUpdateMovie(updatedMovie)
    }
    
    func cancelChanges() {
        // Revert the changes
        watchDate = movie.watchDate ?? Date()
        review = movie.review ?? ""
        isEditing = false
    }
    
    func logMovie() {
        let newMovie = Movie(id: movie.id,
                             title: movie.title,
                             year: movie.year,
                             director: movie.director,
                             poster: movie.poster,
                             rank: nil,
                             watchDate: watchDate,
                             review: review,
                             isRankingComplete: false)
        
        let isFirstMovie = movieStore.addOrUpdateMovie(newMovie)
        
        if isFirstMovie {
            showingFirstMovieAlert = true
        } else {
            loggedMovie = newMovie
            showingRankingView = true
        }
    }
}
