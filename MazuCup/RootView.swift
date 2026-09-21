import SwiftUI

enum AppRoute: Hashable {
    case inquiry
    case records
    case culture
    case about
}

struct RootView: View {
    @State private var path: [AppRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(path: $path)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .inquiry: InquiryView()
                    case .records: RecordsView()
                    case .culture: CultureView()
                    case .about: AboutCupView()
                    }
                }
        }
        .tint(MazuTheme.gold)
    }
}

struct HomeView: View {
    @Binding var path: [AppRoute]

    var body: some View {
        ZStack {
            AtmosphereBackground()
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 74)
                    Image(systemName: "water.waves")
                        .font(.system(size: 25, weight: .light))
                        .foregroundStyle(MazuTheme.gold)
                        .padding(.bottom, 18)
                    Text("妈祖 · 圣杯问心")
                        .font(.system(size: 36, weight: .medium, design: .serif))
                        .foregroundStyle(MazuTheme.paleGold)
                    Text("一念诚心 · 静观本心")
                        .font(.subheadline)
                        .tracking(4)
                        .foregroundStyle(.white.opacity(0.58))
                        .padding(.top, 12)
                    Text("以数字方式体验民俗礼仪，在片刻静心中梳理自己的问题。")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.68))
                        .padding(.top, 34)
                        .padding(.horizontal, 32)
                    Button("开始请示") { path.append(.inquiry) }
                        .buttonStyle(GoldButtonStyle())
                        .padding(.top, 44)
                        .accessibilityHint("进入净心与请示流程")
                    HStack(spacing: 12) {
                        HomeTile(title: "我的祈愿", icon: "book.closed") { path.append(.records) }
                        HomeTile(title: "妈祖文化", icon: "building.columns") { path.append(.culture) }
                    }
                    .padding(.top, 14)
                    Button("了解圣杯与体验说明") { path.append(.about) }
                        .font(.footnote)
                        .foregroundStyle(MazuTheme.paleGold.opacity(0.82))
                        .padding(.top, 26)
                    Text("文化体验 · 不作预测或决策依据")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.35))
                        .padding(.top, 60)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 22)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct HomeTile: View {
    let title: String
    let icon: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon).font(.title3)
                Text(title).font(.subheadline.weight(.medium))
            }
            .foregroundStyle(MazuTheme.paleGold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(.thinMaterial.opacity(0.62))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(MazuTheme.gold.opacity(0.16)))
        }
    }
}
