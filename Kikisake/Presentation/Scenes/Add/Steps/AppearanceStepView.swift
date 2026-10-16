//
//  AppearanceStepView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/15.
//

import SwiftUI

/// [Step 2] 色・外観入力ビュー
public struct AppearanceStepView: View {
    @Bindable var viewModel: AddFlowViewModel

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section("色・外観") {
                ColorAppearancePicker(
                    category: viewModel.selectedCategory,
                    selectedAppearance: $viewModel.appearanceNotes
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var vm = AddFlowViewModel()
    return AppearanceStepView(viewModel: vm)
}
