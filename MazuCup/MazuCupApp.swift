import SwiftUI

@main
struct MazuCupApp: App {
    @StateObject private var recordStore = RecordStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(recordStore)
                .preferredColorScheme(.dark)
        }
    }
}
