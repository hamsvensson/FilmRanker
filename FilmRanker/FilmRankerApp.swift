import SwiftUI

    @main
struct FilmRankerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(MovieStore())
        }
    }
}

