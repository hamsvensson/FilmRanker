import SwiftUI

struct EntryCardCreationView: View {
    @EnvironmentObject var movieStore: MovieStore
    @Environment(\.presentationMode) var presentationMode
    let movie: Movie
    @State private var watchDate = Date()
    @State private var review = ""
    @State private var showingRankingView = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Movie Info")) {
                    Text(movie.title)
                    Text("Directed by \(movie.director)")
                    Text("Year: \(movie.year)")
                }
                
                Section(header: Text("Your Entry")) {
                    DatePicker("Watch Date", selection: $watchDate, displayedComponents: .date)
                    TextEditor(text: $review)
                        .frame(height: 100)
                }
                
                Section {
                    Button("Create Entry") {
                        createEntryCard()
                    }
                }
            }
            .navigationTitle("Create Entry")
        }
        .sheet(isPresented: $showingRankingView) {
            if let entryCardToRank = movieStore.getNextUnrankedEntryCard() {
                RankingView(entryCard: entryCardToRank)
            }
        }
    }
    
    private func createEntryCard() {
        let newEntryCard = EntryCard(movie: movie, watchDate: watchDate, review: review)
        let isFirstEntry = movieStore.addEntryCard(newEntryCard)
        
        if isFirstEntry {
            presentationMode.wrappedValue.dismiss()
        } else {
            showingRankingView = true
        }
    }
}

