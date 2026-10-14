//
//  SelectCategoryStepView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI
import SwiftData

/// [Step 1] 酒種選択および既存在庫からの読み込み選択ビュー
public struct SelectCategoryStepView: View {
    @Bindable var viewModel: AddFlowViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var inventoryItems: [BeverageItem]

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section("酒種を選択") {
                Picker("酒種", selection: $viewModel.selectedCategory) {
                    ForEach(BeverageCategory.allCases, id: \.self) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 4)
            }

            Section("セラー・冷蔵庫の在庫から選んで開ける") {
                let availableItems = inventoryItems.filter { $0.stockQuantity > 0 }
                if availableItems.isEmpty {
                    Text("在庫中のアイテムはありません")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(availableItems) { item in
                        Button {
                            viewModel.configureWithItem(item)
                            viewModel.currentStep = 2
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                    Text("\(item.producer) / 残り \(item.stockQuantity)本")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var vm = AddFlowViewModel()
    return SelectCategoryStepView(viewModel: vm)
        .modelContainer(for: [BeverageItem.self, TastingLog.self], inMemory: true)
}
