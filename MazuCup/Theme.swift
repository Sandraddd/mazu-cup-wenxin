import SwiftUI

enum MazuTheme {
    static let navy = Color(red: 0.025, green: 0.10, blue: 0.16)
    static let ocean = Color(red: 0.04, green: 0.22, blue: 0.28)
    static let gold = Color(red: 0.86, green: 0.69, blue: 0.36)
    static let paleGold = Color(red: 0.96, green: 0.88, blue: 0.68)
    static let cinnabar = Color(red: 0.62, green: 0.15, blue: 0.12)
    static let ink = Color(red: 0.015, green: 0.045, blue: 0.07)
}

struct AtmosphereBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [MazuTheme.ink, MazuTheme.navy, MazuTheme.ocean.opacity(0.9)], startPoint: .top, endPoint: .bottom)
            Circle()
                .fill(MazuTheme.gold.opacity(0.12))
                .frame(width: 260)
                .blur(radius: 24)
                .offset(x: 130, y: -260)
            ForEach(0..<5, id: \.self) { index in
                Capsule()
                    .fill(Color.white.opacity(0.025))
                    .frame(width: 320, height: 42)
                    .blur(radius: 14)
                    .rotationEffect(.degrees(index.isMultiple(of: 2) ? -8 : 8))
                    .offset(x: CGFloat(index * 30 - 70), y: CGFloat(index * 105 - 180))
            }
            VStack {
                Spacer()
                WaveShape(amplitude: 11, phase: 0.1)
                    .stroke(MazuTheme.gold.opacity(0.14), lineWidth: 1)
                    .frame(height: 125)
            }
        }
        .ignoresSafeArea()
    }
}

struct WaveShape: Shape {
    let amplitude: CGFloat
    let phase: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        for x in stride(from: 0, through: rect.width, by: 2) {
            let y = rect.midY + sin((x / rect.width * .pi * 3) + phase) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }
}

struct GoldButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(MazuTheme.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(LinearGradient(colors: [MazuTheme.paleGold, MazuTheme.gold], startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: MazuTheme.gold.opacity(0.2), radius: 18, y: 7)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct GlassCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content
            .padding(20)
            .background(.ultraThinMaterial.opacity(0.84))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(MazuTheme.gold.opacity(0.22)))
    }
}
