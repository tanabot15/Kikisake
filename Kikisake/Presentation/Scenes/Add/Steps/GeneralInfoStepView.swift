//
//  GeneralInfoStepView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/15.
//

import SwiftUI

public enum GeneralInfoField {
    case name
    case producer
    case region
    case vintage
    case price
    case extra // 固有項目用
}

/// [Step 1] 一般的な情報（酒種・基本情報・保管場所）入力ビュー
public struct GeneralInfoStepView: View {
    @Bindable var viewModel: AddFlowViewModel
    @FocusState.Binding var focusedField: GeneralInfoField?
    var showAlert: (String) -> Void

    public init(
        viewModel: AddFlowViewModel,
        focusedField: FocusState<GeneralInfoField?>.Binding,
        showAlert: @escaping (String) -> Void
    ) {
        self.viewModel = viewModel
        self._focusedField = focusedField
        self.showAlert = showAlert
    }

    public var body: some View {
        Form {
            Section("酒種") {
                Picker("酒種", selection: $viewModel.selectedCategory) {
                    ForEach(BeverageCategory.allCases, id: \.self) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 4)
            }

            Section("基本情報") {
                TextField("銘柄名 (必須)", text: $viewModel.name)
                    .focused($focusedField, equals: .name)
                
                TextField("生産者 / 蔵元 / ブルワリー", text: $viewModel.producer)
                    .focused($focusedField, equals: .producer)

                // 酒種ごとの固有入力フィールドの動的切り替え
                switch viewModel.selectedCategory {
                case .wine:
                    Picker("ワインタイプ", selection: $viewModel.wineType) {
                        Text("赤").tag("赤")
                        Text("白").tag("白")
                        Text("ロゼ").tag("ロゼ")
                        Text("オレンジ").tag("オレンジ")
                        Text("スパークリング").tag("スパークリング")

                    }
                    .padding(.vertical, 4)
                    
                    TextField("主要品種 (例: カベルネ・ソーヴィニヨン)", text: $viewModel.grapeVarieties)
                        .focused($focusedField, equals: .extra)
                    
                case .sake:
                    Picker("特定名称", selection: $viewModel.sakeSpecificName) {
                        Text("純米大吟醸").tag("純米大吟醸")
                        Text("純米吟醸").tag("純米吟醸")
                        Text("大吟醸").tag("大吟醸")
                        Text("大吟醸").tag("吟醸")
                        Text("特別純米").tag("特別純米")
                        Text("純米酒").tag("純米")
                        Text("本醸造").tag("特別本醸造")
                        Text("本醸造").tag("本醸造")
                        Text("その他").tag("普通酒")
                        Text("その他").tag("その他")
                    }
                    
                    TextField("使用米 (例: 山田錦)", text: $viewModel.riceVariety)
                        .focused($focusedField, equals: .extra)
                    TextField("精米歩合 (例: 50%)", text: $viewModel.polishingRate)
                    TextField("日本酒度 (例: +3.0)", text: $viewModel.sakeMeterValue)
                    
                case .beer:
                    TextField("ビアスタイル (例: IPA, Stout)", text: $viewModel.beerStyle)
                        .focused($focusedField, equals: .extra)
                    TextField("IBU (国際苦味単位)", text: $viewModel.ibu)
                        .keyboardType(.numberPad)
                }

                TextField("生産地 (例: ボルドー, 新潟、チェコ)", text: $viewModel.region)
                    .focused($focusedField, equals: .region)
                
                TextField("ヴィンテージ / 製造年月 (例: 2020)", text: $viewModel.vintage)
                    .focused($focusedField, equals: .vintage)
                
                TextField("価格 (円)", text: $viewModel.priceString)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .price)
            }

            Section("保管場所") {
                Picker("保管場所", selection: $viewModel.storageLocation) {
                    ForEach(AppConstants.Storage.availableLocations, id: \.self) { location in
                        Text(location).tag(location)
                    }
                }
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var vm = AddFlowViewModel()
        @FocusState private var field: GeneralInfoField?

        var body: some View {
            NavigationStack {
                GeneralInfoStepView(
                    viewModel: vm,
                    focusedField: $field
                ) { message in
                    print("Alert: \(message)")
                }
            }
        }
    }

    return PreviewWrapper()
}
