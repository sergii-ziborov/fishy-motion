import SwiftUI

enum Palette {
    static let deep = Color(red: 0.02, green: 0.07, blue: 0.14)
    static let navy = Color(red: 0.05, green: 0.14, blue: 0.24)
    static let navyCard = Color(red: 0.08, green: 0.18, blue: 0.30)
    static let teal = Color(red: 0.18, green: 0.72, blue: 0.78)
    static let aqua = Color(red: 0.42, green: 0.86, blue: 0.92)
    static let play = Color(red: 0.22, green: 0.62, blue: 0.98)
    static let playPressed = Color(red: 0.16, green: 0.48, blue: 0.88)
    static let ocean = Color(red: 0.18, green: 0.48, blue: 0.86)
    static let oceanDeep = Color(red: 0.12, green: 0.38, blue: 0.74)
    static let success = Color(red: 0.22, green: 0.78, blue: 0.48)
    static let danger = Color(red: 0.95, green: 0.32, blue: 0.40)
    static let gold = Color(red: 1.0, green: 0.82, blue: 0.32)
    static let ink = Color.white
    static let muted = Color.white.opacity(0.62)
}

extension Font {
    static func fmDisplay(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    static func fmBody(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func fmScript(_ size: CGFloat) -> Font {
        .system(size: size, design: .serif).italic()
    }
}

struct FMButton: View {
    enum Kind { case play, success, quiet, danger, ocean }

    var title: String
    var kind: Kind = .play
    var icon: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.fmBody(18))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(background, in: Capsule())
            .shadow(color: .black.opacity(0.22), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var background: Color {
        switch kind {
        case .play, .ocean: Palette.ocean
        case .success: Palette.success
        case .quiet: Color.white.opacity(0.14)
        case .danger: Palette.danger
        }
    }

    private var foreground: Color {
        .white
    }
}

struct FeaturePill: View {
    var icon: String
    var title: String
    var tint: Color
    var compact: Bool = false

    var body: some View {
        VStack(spacing: compact ? 4 : 6) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.18))
                    .frame(width: compact ? 42 : 50, height: compact ? 42 : 50)
                Image(systemName: icon)
                    .font(.system(size: compact ? 16 : 18, weight: .semibold))
                    .foregroundStyle(tint)
            }
            Text(title)
                .font(.fmBody(12))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StarRow: View {
    var stars: Int
    var size: CGFloat = 22

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < stars ? "star.fill" : "star")
                    .font(.system(size: size, weight: .bold))
                    .foregroundStyle(index < stars ? Palette.gold : Color.white.opacity(0.22))
            }
        }
        .accessibilityLabel("\(stars) of 3 stars")
    }
}

struct ScreenHeader: View {
    var title: String
    var back: () -> Void

    var body: some View {
        HStack {
            Button(action: back) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
            }
            .accessibilityIdentifier("back-button")
            Spacer()
            Text(title)
                .font(.fmDisplay(22))
                .foregroundStyle(.white)
            Spacer()
            Color.clear.frame(width: 18)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

struct OceanBackdrop: View {
    var asset: String? = nil
    var dim: Double = 0.38

    var body: some View {
        ZStack {
            Palette.deep
            if let asset {
                Image(asset)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.92)
                    .overlay(Palette.deep.opacity(dim))
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.06, green: 0.28, blue: 0.42),
                        Palette.deep
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
