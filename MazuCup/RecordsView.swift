import SwiftUI

struct RecordsView: View {
    @EnvironmentObject private var store: RecordStore
    @State private var showClearConfirmation = false

    var body: some View {
        ZStack {
            AtmosphereBackground()
            if store.records.isEmpty {
                ContentUnavailableView("尚无祈愿记录", systemImage: "book.closed", description: Text("完成一次请示并保存后，会显示在这里。"))
            } else {
                List {
                    ForEach(store.records) { record in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label(record.category.rawValue, systemImage: record.category.symbol)
                                    .font(.caption).foregroundStyle(MazuTheme.gold)
                                Spacer()
                                Text(record.createdAt, format: .dateTime.year().month().day().hour().minute())
                                    .font(.caption2).foregroundStyle(.secondary)
                            }
                            Text(record.question).font(.headline).foregroundStyle(.white.opacity(0.9))
                            HStack {
                                Text(record.result.rawValue).font(.system(.title3, design: .serif).weight(.semibold)).foregroundStyle(MazuTheme.paleGold)
                                Text(record.result.subtitle).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 10)
                        .listRowBackground(Color.white.opacity(0.055))
                    }
                    .onDelete(perform: store.delete)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("我的祈愿")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !store.records.isEmpty {
                Button("清空", role: .destructive) { showClearConfirmation = true }
            }
        }
        .confirmationDialog("清空全部祈愿记录？", isPresented: $showClearConfirmation, titleVisibility: .visible) {
            Button("清空全部", role: .destructive) { store.removeAll() }
            Button("取消", role: .cancel) {}
        } message: {
            Text("此操作无法撤销，记录只保存在当前设备。")
        }
    }
}
