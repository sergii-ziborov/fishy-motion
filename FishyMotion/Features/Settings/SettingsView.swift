import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var confirmReset = false

    var body: some View {
        @Bindable var model = model
        ZStack {
            OceanBackdrop(asset: "DeepTrenchBackground", dim: 0.45)
            VStack(spacing: 0) {
                ScreenHeader(title: "Settings") { model.goHome() }

                VStack(spacing: 0) {
                    row("Sound", isOn: $model.progress.soundEnabled)
                    Divider().overlay(Color.white.opacity(0.08))
                    row("Music", isOn: $model.progress.musicEnabled)
                    Divider().overlay(Color.white.opacity(0.08))
                    row("Haptic Feedback", isOn: $model.progress.hapticsEnabled)
                    Divider().overlay(Color.white.opacity(0.08))
                    row("Reduce Motion", isOn: $model.progress.reduceMotion)
                }
                .padding(.horizontal, 8)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .padding(20)

                VStack(alignment: .leading, spacing: 10) {
                    LabeledContent("Stars", value: "\(model.progress.totalStars)")
                    LabeledContent("Solves", value: "\(model.progress.totalSolves)")
                    Button("Reset progress", role: .destructive) { confirmReset = true }
                }
                .padding(20)
                .foregroundStyle(.white)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .onChange(of: model.progress.hapticsEnabled) { _, _ in model.saveProgress() }
        .onChange(of: model.progress.soundEnabled) { _, _ in model.saveProgress() }
        .onChange(of: model.progress.musicEnabled) { _, _ in model.saveProgress() }
        .onChange(of: model.progress.reduceMotion) { _, _ in model.saveProgress() }
        .confirmationDialog("Reset all stars and collection?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Reset", role: .destructive) { model.resetProgress() }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func row(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .font(.fmBody(18))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .tint(Palette.success)
    }
}
