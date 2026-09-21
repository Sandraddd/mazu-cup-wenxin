import SwiftUI

struct CultureArticle: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let body: String
}

private let cultureArticles = [
    CultureArticle(title: "妈祖故事", subtitle: "从林默娘到海上守护", icon: "water.waves", body: "妈祖信俗发源于福建湄洲岛。民间传说中的林默娘慈悲助人、护佑航海者，后世逐渐形成跨地域传播的妈祖信仰与丰富民俗。今天，妈祖文化也承载着崇德、行善、大爱的精神价值。"),
    CultureArticle(title: "掷筊由来", subtitle: "人与信仰之间的礼仪表达", icon: "moonphase.first.quarter", body: "掷筊是闽南、台湾及华人社会常见的传统民俗仪式。参与者通常先净心、说明所问，再掷出一对筊杯。不同地区、宫庙的礼仪细节可能有所差异，应尊重当地传统。"),
    CultureArticle(title: "三种杯象", subtitle: "圣杯、笑杯与阴杯", icon: "circle.lefthalf.filled", body: "常见解释中，一平一凸称为圣杯；两平面称为笑杯；两凸面称为阴杯。各地对正反面名称和具体含义可能略有不同，本应用采用通行的简化说明。"),
    CultureArticle(title: "民俗礼仪", subtitle: "敬意、节制与善念", icon: "hands.sparkles", body: "体验时宜保持尊重，不以戏谑、赌博或反复追问的心态对待传统礼仪。重大现实问题仍应依靠充分信息、专业意见与个人判断。")
]

struct CultureView: View {
    var body: some View {
        ZStack {
            AtmosphereBackground()
            ScrollView {
                LazyVStack(spacing: 14) {
                    Text("海不辞水，故能成其大。妈祖文化跨越海洋，也连接着人们对平安与善意的共同愿望。")
                        .font(.system(.body, design: .serif)).lineSpacing(7).foregroundStyle(.white.opacity(0.72)).padding(.vertical, 12)
                    ForEach(cultureArticles) { article in
                        NavigationLink {
                            CultureArticleView(article: article)
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: article.icon).font(.title2).foregroundStyle(MazuTheme.gold).frame(width: 42)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(article.title).font(.headline).foregroundStyle(MazuTheme.paleGold)
                                    Text(article.subtitle).font(.caption).foregroundStyle(.white.opacity(0.48))
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.white.opacity(0.3))
                            }
                            .padding(18).background(.thinMaterial.opacity(0.72)).clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                    }
                }.padding(22)
            }
        }
        .navigationTitle("妈祖文化")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CultureArticleView: View {
    let article: CultureArticle
    var body: some View {
        ZStack {
            AtmosphereBackground()
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: article.icon).font(.system(size: 42, weight: .light)).foregroundStyle(MazuTheme.gold).padding(.top, 30)
                    Text(article.title).font(.system(size: 30, weight: .semibold, design: .serif)).foregroundStyle(MazuTheme.paleGold)
                    GlassCard { Text(article.body).font(.body).lineSpacing(9).foregroundStyle(.white.opacity(0.82)).frame(maxWidth: .infinity, alignment: .leading) }
                    Text("文化内容为通识性简述；具体仪轨请以当地宫庙传统及权威文化资料为准。")
                        .font(.caption).foregroundStyle(.white.opacity(0.4))
                }.padding(22)
            }
        }
    }
}

struct AboutCupView: View {
    var body: some View {
        ZStack {
            AtmosphereBackground()
            ScrollView {
                VStack(spacing: 18) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("什么是筊杯？").font(.title3.bold()).foregroundStyle(MazuTheme.paleGold)
                            Text("筊杯通常成对使用，形似弯月，是华人民间信俗中的礼仪器具。掷出后以杯面组合表达请示结果。")
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("关于连续圣杯").font(.title3.bold()).foregroundStyle(MazuTheme.paleGold)
                            Text("部分传统在重大事项中会以连续三次圣杯作为确认，但不同地区与宫庙做法不一。本应用 MVP 只模拟单次掷杯，不鼓励反复追问。")
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("体验边界", systemImage: "checkmark.shield").font(.title3.bold()).foregroundStyle(MazuTheme.paleGold)
                            Text("本应用不提供算命、人生预测或玄学评分。结果由设备本地随机产生，目的是帮助用户短暂停顿、整理问题并了解传统文化。")
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("模拟规则", systemImage: "function").font(.title3.bold()).foregroundStyle(MazuTheme.paleGold)
                            Text("程序分别模拟两枚筊杯的平、凸两面：一平一凸为圣杯，两平为笑杯，两凸为阴杯。对应概率约为 50%、25%、25%。结果生成后即锁定，不会按问题内容调整。")
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                }.padding(22)
            }
        }
        .navigationTitle("关于圣杯")
        .navigationBarTitleDisplayMode(.inline)
    }
}
