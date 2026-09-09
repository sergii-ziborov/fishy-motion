import SwiftUI

@main
struct FishyMotionApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
        }
    }
}

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Group {
            switch model.screen {
            case .home:
                HomeView()
            case .tutorial:
                TutorialView()
            case .play:
                PlayView()
            case .result:
                ResultView()
            case .worlds:
                WorldsView()
            case .collection:
                CollectionView()
            case .daily:
                DailyView()
            case .settings:
                SettingsView()
            case .fishpedia:
                FishpediaView()
            case .hints:
                HintsView()
            }
        }
        .animation(.easeInOut(duration: 0.22), value: screenKey)
        .tint(Palette.teal)
        .preferredColorScheme(.dark)
    }

    private var screenKey: String {
        switch model.screen {
        case .home: "home"
        case .tutorial: "tutorial"
        case .play: "play"
        case .result: "result"
        case .worlds: "worlds"
        case .collection: "collection"
        case .daily: "daily"
        case .settings: "settings"
        case .fishpedia: "fishpedia"
        case .hints: "hints"
        }
    }
}
