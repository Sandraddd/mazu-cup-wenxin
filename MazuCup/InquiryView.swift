import SwiftUI

struct InquiryView: View {
    @State private var name = ""
    @State private var question = ""
    @State private var category: WishCategory = .career
    @State private var isRitualPresented = false
    @FocusState private var focusedField: Field?

    private enum Field { case name, question }
    private var canContinue: Bool { question.trimmingCharacters(in: .whitespacesAndNewlines).count >= 4 }

    var body: some View {
        ZStack {
            AtmosphereBackground()
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("净心 · 请示")
                            .font(.system(size: 30, weight: .semibold, design: .serif))
                            .foregroundStyle(MazuTheme.paleGold)
                        Text("请静心片刻，将问题写得清楚、具体。")
                            .font(.callout)
                            .foregroundStyle(.white.opacity(0.62))
                    }
                    .padding(.top, 20)
                    GlassCard {
                        VStack(alignment: .leading, spacing: 20) {
                            LabeledField(title: "称呼（选填）", placeholder: "如何称呼你", text: $name, axis: .horizontal)
                                .focused($focusedField, equals: .name)
                            LabeledField(title: "心中所问", placeholder: "例如：我是否已充分准备好接受新的工作机会？", text: $question, axis: .vertical)
                                .focused($focusedField, equals: .question)
                                .lineLimit(3...6)
                            VStack(alignment: .leading, spacing: 12) {
                                Text("所问类别").font(.caption).foregroundStyle(.white.opacity(0.52))
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                                    ForEach(WishCategory.allCases) { item in
                                        Button { category = item } label: {
                                            Label(item.rawValue, systemImage: item.symbol)
                                                .font(.caption.weight(.medium))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 11)
                                                .foregroundStyle(category == item ? MazuTheme.ink : .white.opacity(0.8))
                                                .background(category == item ? MazuTheme.gold : Color.white.opacity(0.06))
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Text("请勿输入身份证号、联系方式等敏感信息。")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.42))
                    Button("向妈祖请示") {
                        focusedField = nil
                        isRitualPresented = true
                    }
                    .buttonStyle(GoldButtonStyle())
                    .disabled(!canContinue)
                    .opacity(canContinue ? 1 : 0.45)
                }
                .padding(22)
            }
        }
        .navigationTitle("开始请示")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $isRitualPresented) {
            RitualView(name: name.trimmingCharacters(in: .whitespacesAndNewlines), question: question.trimmingCharacters(in: .whitespacesAndNewlines), category: category)
        }
    }
}

private struct LabeledField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let axis: Axis
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundStyle(.white.opacity(0.52))
            TextField(placeholder, text: $text, axis: axis)
                .textInputAutocapitalization(.never)
                .padding(14)
                .background(Color.white.opacity(0.055))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08)))
        }
    }
}
