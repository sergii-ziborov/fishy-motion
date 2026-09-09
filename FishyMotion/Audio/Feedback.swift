import AudioToolbox
import UIKit

@MainActor
enum Feedback {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        AudioServicesPlaySystemSound(1104)
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        AudioServicesPlaySystemSound(1025)
    }

    static func miss() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        AudioServicesPlaySystemSound(1053)
    }

    static func hint() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
