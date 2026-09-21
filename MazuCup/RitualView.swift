import SwiftUI

struct RitualView: View {
    let name: String
    let question: String
    let category: WishCategory
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: RecordStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: RitualPhase = .ready
    @State private var result: CupResult?
    @State private var saved = false
    @State private var rotation = 0.0
    @State private var lift = 0.0

    enum RitualPhase { case ready, lifting, turning, landed, result }

    var body: some View {
        ZStack {
            AtmosphereBackground()
            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: { Image(systemName: "xmark").padding(12).background(.thinMaterial).clipShape(Circle()) }
                    Spacer()
                    Text(phaseTitle).font(.caption).tracking(3).foregroundStyle(.white.opacity(0.55))
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding()
                if phase == .result, let result {
                    ResultView(result: result, question: question, saved: saved, onSave: save, onAgain: reset, onDone: { dismiss() })
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                } else {
                    ritualStage
                }
            }
        }
        .interactiveDismissDisabled(phase != .ready && phase != .result)
    }

    private var ritualStage: some View {
        VStack(spacing: 24) {
            Spacer()
            VStack(spacing: 7) {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(MazuTheme.gold)
                    .symbolEffect(.pulse, options: .repeating, isActive: phase != .landed)
                Text(question)
                    .font(.system(size: 20, weight: .medium, design: .serif))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(MazuTheme.paleGold)
                    .lineLimit(3)
                Text("先深呼吸，再轻触筊杯")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            ZStack {
                Ellipse().fill(Color.black.opacity(0.28)).frame(width: 270, height: 52).blur(radius: 12).offset(y: 75)
                HStack(spacing: 26) {
                    MoonBlock(faceUp: result?.faces.0 ?? true)
                        .rotation3DEffect(.degrees(rotation), axis: (1, 0.6, 0.2))
                        .rotationEffect(.degrees(rotation * 0.25))
                    MoonBlock(faceUp: result?.faces.1 ?? false)
                        .rotation3DEffect(.degrees(-rotation * 1.2), axis: (0.7, 1, 0.2))
                        .rotationEffect(.degrees(-rotation * 0.3))
                }
                .offset(y: lift)
            }
            .frame(height: 230)
            Text(stageCaption)
                .font(.subheadline)
                .foregroundStyle(MazuTheme.paleGold.opacity(0.85))
            Spacer()
            Button(phase == .ready ? "轻触掷杯" : "请静候") { beginRitual() }
                .buttonStyle(GoldButtonStyle())
                .disabled(phase != .ready)
                .opacity(phase == .ready ? 1 : 0.55)
                .padding(.horizontal, 22)
                .padding(.bottom, 34)
        }
    }

    private var phaseTitle: String {
        switch phase { case .ready: "静心"; case .lifting: "起杯"; case .turning: "掷杯"; case .landed: "落杯"; case .result: "问心" }
    }
    private var stageCaption: String {
        switch phase { case .ready: "筊杯已备"; case .lifting: "诚心起杯"; case .turning: "杯行问心"; case .landed: "杯落有声"; case .result: "" }
    }

    private func beginRitual() {
        let selected = CupResult.cast()
        result = selected
        if reduceMotion {
            phase = .landed
            lift = 30
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(300))
                withAnimation(.easeOut(duration: 0.25)) { phase = .result }
            }
            return
        }
        phase = .lifting
        withAnimation(.easeOut(duration: 0.7)) { lift = -72 }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(720))
            phase = .turning
            withAnimation(.easeInOut(duration: 1.35)) { rotation = 900; lift = -15 }
            try? await Task.sleep(for: .milliseconds(1380))
            phase = .landed
            withAnimation(.bouncy(duration: 0.55, extraBounce: 0.16)) { lift = 30; rotation += 180 }
            try? await Task.sleep(for: .milliseconds(800))
            withAnimation(.easeInOut(duration: 0.45)) { phase = .result }
        }
    }

    private func save() {
        guard let result, !saved else { return }
        store.add(CupRecord(name: name, question: question, category: category, result: result))
        saved = true
    }

    private func reset() {
        phase = .ready; result = nil; saved = false; rotation = 0; lift = 0
    }
}

private struct MoonBlock: View {
    let faceUp: Bool
    var body: some View {
        ZStack {
            Capsule()
                .fill(LinearGradient(colors: faceUp ? [MazuTheme.cinnabar, .red.opacity(0.45)] : [.brown.opacity(0.9), MazuTheme.cinnabar], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 84, height: 144)
                .clipShape(CrescentBlockShape())
                .shadow(color: .black.opacity(0.45), radius: 12, y: 10)
            CrescentBlockShape().stroke(MazuTheme.paleGold.opacity(faceUp ? 0.42 : 0.16), lineWidth: 1)
                .frame(width: 84, height: 144)
            if faceUp { Capsule().fill(MazuTheme.paleGold.opacity(0.17)).frame(width: 30, height: 90).rotationEffect(.degrees(12)) }
        }
        .accessibilityLabel(faceUp ? "平面朝上" : "凸面朝上")
    }
}

private struct CrescentBlockShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.height), control: CGPoint(x: rect.maxX * 1.25, y: rect.midY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: 0), control: CGPoint(x: -rect.width * 0.12, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

private struct ResultView: View {
    let result: CupResult
    let question: String
    let saved: Bool
    let onSave: () -> Void
    let onAgain: () -> Void
    let onDone: () -> Void
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(result.accent)
                    .font(.system(size: 44, weight: .regular, design: .serif))
                    .foregroundStyle(MazuTheme.ink)
                    .frame(width: 88, height: 88)
                    .background(MazuTheme.gold)
                    .clipShape(Circle())
                    .shadow(color: MazuTheme.gold.opacity(0.3), radius: 26)
                VStack(spacing: 8) {
                    Text(result.rawValue).font(.system(size: 38, weight: .semibold, design: .serif)).foregroundStyle(MazuTheme.paleGold)
                    Text(result.subtitle).font(.subheadline).foregroundStyle(.white.opacity(0.55))
                }
                GlassCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("你所问").font(.caption).foregroundStyle(.white.opacity(0.46))
                        Text(question).font(.headline)
                        Divider().overlay(MazuTheme.gold.opacity(0.2))
                        Text("问心提示").font(.caption).foregroundStyle(.white.opacity(0.46))
                        Text(result.guidance).font(.body).foregroundStyle(.white.opacity(0.84)).lineSpacing(6)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
                Text("结果由本地随机模拟产生，仅供传统民俗文化体验，不代表神意，也不应替代医疗、法律、财务或人生决策。")
                    .font(.caption).lineSpacing(4).foregroundStyle(.white.opacity(0.42))
                Button(saved ? "已保存到祈愿记录" : "保存记录", action: onSave)
                    .buttonStyle(GoldButtonStyle()).disabled(saved)
                HStack {
                    Button("重新请示", action: onAgain)
                    Spacer()
                    Button("完成", action: onDone)
                }
                .font(.subheadline.weight(.medium)).foregroundStyle(MazuTheme.paleGold)
                .padding(.horizontal, 4)
            }
            .padding(22)
        }
    }
}
