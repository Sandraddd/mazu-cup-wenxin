import Foundation
import Combine

enum WishCategory: String, Codable, CaseIterable, Identifiable {
    case career = "事业"
    case love = "感情"
    case health = "健康"
    case family = "家庭"
    case other = "其他"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .career: "briefcase.fill"
        case .love: "heart.fill"
        case .health: "cross.case.fill"
        case .family: "house.fill"
        case .other: "ellipsis.circle.fill"
        }
    }
}

enum CupResult: String, Codable, CaseIterable {
    case sheng = "圣杯"
    case xiao = "笑杯"
    case yin = "阴杯"

    var faces: (Bool, Bool) {
        switch self {
        case .sheng: (true, false)
        case .xiao: (true, true)
        case .yin: (false, false)
        }
    }

    var subtitle: String {
        switch self {
        case .sheng: "一平一凸 · 较肯定的象征"
        case .xiao: "两面皆平 · 问题仍需厘清"
        case .yin: "两面皆凸 · 提醒暂缓审视"
        }
    }

    var guidance: String {
        switch self {
        case .sheng: "心中已有方向，可在审慎评估后坚定行动。"
        case .xiao: "问题或时机尚未清晰，不妨换个角度再想一想。"
        case .yin: "此刻宜暂缓决定，补足信息、调整方向后再行动。"
        }
    }

    var accent: String {
        switch self {
        case .sheng: "允"
        case .xiao: "思"
        case .yin: "缓"
        }
    }

    /// Simulates two independent moon-block faces. This yields the traditional
    /// 50% sheng / 25% xiao / 25% yin distribution without weighting a label.
    static func cast() -> CupResult {
        let first = Bool.random()
        let second = Bool.random()
        if first != second { return .sheng }
        return first ? .xiao : .yin
    }
}

struct CupRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let createdAt: Date
    let name: String
    let question: String
    let category: WishCategory
    let result: CupResult

    init(id: UUID = UUID(), createdAt: Date = .now, name: String, question: String, category: WishCategory, result: CupResult) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        self.question = question
        self.category = category
        self.result = result
    }
}

@MainActor
final class RecordStore: ObservableObject {
    @Published private(set) var records: [CupRecord] = []
    private let storageKey = "mazu.cup.records.v1"

    init() { load() }

    func add(_ record: CupRecord) {
        records.insert(record, at: 0)
        save()
    }

    func delete(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            records.remove(at: index)
        }
        save()
    }

    func removeAll() {
        records.removeAll()
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([CupRecord].self, from: data) else { return }
        records = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
