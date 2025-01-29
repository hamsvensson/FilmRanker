import SwiftUI

struct ContentView: View {
    @EnvironmentObject var movieStore: MovieStore
    var body: some View {
        TabView {
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            LoggedMoviesView()
                .environmentObject(movieStore)
                .tabItem {
                    Label("My Movies", systemImage: "film")
                }
        }
    }
}

