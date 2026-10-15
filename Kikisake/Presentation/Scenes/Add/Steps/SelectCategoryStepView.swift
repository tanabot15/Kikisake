//
//  SelectCategoryStepView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI

/// [Step 1] 新規追加の酒種選択ビュー
public struct SelectCategoryStepView: View {
    @Bindable var viewModel: AddFlowViewModel

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section("追加するお酒の酒種を選択") {
                Picker("酒種", selection: $viewModel.selectedCategory) {
                    ForEach(BeverageCategory.allCases, id: \.self) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 8)
            }
        }
    }
}

#Preview {
    @Previewable @State var vm = AddFlowViewModel()
    return SelectCategoryStepView(viewModel: vm)
}
