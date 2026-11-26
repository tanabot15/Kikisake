//
//  AddBlindGuessView.swift
//  Kikisake
//

import SwiftUI

/// ブラインドテイスティングの予想入力画面（Step 4 / 7）
public struct AddBlindGuessView: View {
    @Bindable var viewModel: AddFlowViewModel

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    private let percentagePresets: [Int] = Array(stride(from: 5, through: 100, by: 5))

    private var totalWineBlendPercentage: Int {
        viewModel.guessedWineBlend
            .filter { !$0.variety.isEmpty }
            .compactMap(\.percentage)
            .reduce(0, +)
    }

    public var body: some View {
        Form {
            headerBannerSection

            switch viewModel.selectedCategory {
            case .wine:
                wineGuessSection
            case .sake:
                sakeGuessSection
            case .beer:
                beerGuessSection
            }
        }
    }

    // MARK: - Header Banner

    private var headerBannerSection: some View {
        Section {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.indigo.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "eye.slash.fill")
                        .font(.headline)
                        .foregroundStyle(.indigo)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(String(localized: "ブラインド予想（アンサー入力）"))
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Text(String(localized: "外観・香り・味わいの印象から正体を推理して選択してください。次の画面で答え合わせを行います。"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Wine Guess (ブドウ品種 + 割合 + 地域)

    @ViewBuilder
    private var wineGuessSection: some View {
        Section {
            ForEach(Array(viewModel.guessedWineBlend.enumerated()), id: \.element.id) { index, _ in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(
                            viewModel.guessedWineBlend.count > 1
                                ? String(format: String(localized: "予想ブドウ品種 %d"), index + 1)
                                : String(localized: "予想ブドウ品種")
                        )
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                        Spacer()

                        if viewModel.guessedWineBlend.count > 1 {
                            Button(role: .destructive) {
                                viewModel.guessedWineBlend.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red.opacity(0.8))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    HStack(spacing: 10) {
                        // ブドウ品種選択（選択式）
                        Menu {
                            ForEach(BeveragePresetOptions.grapeVarieties.filter { $0 != String(localized: "その他") }, id: \.self) { variety in
                                Button(variety) {
                                    viewModel.guessedWineBlend[index].variety = variety
                                    if viewModel.guessedWineBlend[index].percentage == nil {
                                        viewModel.guessedWineBlend[index].percentage = index == 0 ? 100 : 20
                                    }
                                }
                            }
                        } label: {
                            selectorBox(
                                text: viewModel.guessedWineBlend[index].variety,
                                placeholder: String(localized: "品種を選択...")
                            )
                        }

                        // 割合選択（5%刻みの選択式）
                        Menu {
                            ForEach(percentagePresets, id: \.self) { pct in
                                Button("\(pct)%") {
                                    viewModel.guessedWineBlend[index].percentage = pct
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("\(viewModel.guessedWineBlend[index].percentage ?? 0)%")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Button {
                viewModel.addGuessedBlendComponent()
            } label: {
                Label(String(localized: "ブレンド品種を追加"), systemImage: "plus.circle.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            HStack {
                Text(String(localized: "ブレンド割合合計"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(totalWineBlendPercentage)%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(totalWineBlendPercentage == 100 ? .green : .orange)
            }
        } header: {
            Text(String(localized: "ブドウ品種と割合の予想"))
        }

        Section(String(localized: "生産地の予想")) {
            regionPickerMenu(selectedRegion: $viewModel.guessedWineRegion)
        }
    }

    // MARK: - Sake Guess (特定名称 + 使用米 + 地域)

    @ViewBuilder
    private var sakeGuessSection: some View {
        Section(String(localized: "特定名称の予想")) {
            Picker(String(localized: "特定名称"), selection: $viewModel.guessedSakeSpecificName) {
                Text(String(localized: "純米大吟醸")).tag("純米大吟醸")
                Text(String(localized: "純米吟醸")).tag("純米吟醸")
                Text(String(localized: "大吟醸")).tag("大吟醸")
                Text(String(localized: "特別純米")).tag("特別純米")
                Text(String(localized: "純米酒")).tag("純米")
                Text(String(localized: "本醸造")).tag("本醸造")
            }
            .pickerStyle(.menu)
        }

        Section(String(localized: "酒米（使用米）の予想")) {
            Menu {
                ForEach(BeveragePresetOptions.riceVarieties.filter { $0 != String(localized: "その他") }, id: \.self) { rice in
                    Button(rice) {
                        viewModel.guessedSakeRiceVariety = rice
                    }
                }
            } label: {
                selectorBox(
                    text: viewModel.guessedSakeRiceVariety,
                    placeholder: String(localized: "タップして使用米を選択...")
                )
            }
        }

        Section(String(localized: "生産地（都道府県）の予想")) {
            regionPickerMenu(selectedRegion: $viewModel.guessedSakeRegion)
        }
    }

    // MARK: - Beer Guess (ビアスタイル + 生産地)

    @ViewBuilder
    private var beerGuessSection: some View {
        Section(String(localized: "ビアスタイルの予想")) {
            Menu {
                ForEach(BeveragePresetOptions.beerStyles.filter { $0 != String(localized: "その他") }, id: \.self) { style in
                    Button(style) {
                        viewModel.guessedBeerStyle = style
                    }
                }
            } label: {
                selectorBox(
                    text: viewModel.guessedBeerStyle,
                    placeholder: String(localized: "タップしてビアスタイルを選択...")
                )
            }
        }

        Section(String(localized: "生産地の予想")) {
            regionPickerMenu(selectedRegion: $viewModel.guessedBeerRegion)
        }
    }

    // MARK: - Shared Region Menu

    private func regionPickerMenu(selectedRegion: Binding<String>) -> some View {
        Menu {
            ForEach(RegionPresetOptions.regions(for: viewModel.selectedCategory)) { hierarchy in
                if hierarchy.children.isEmpty {
                    Button(hierarchy.parent) {
                        selectedRegion.wrappedValue = hierarchy.parent
                    }
                } else {
                    Menu(hierarchy.parent) {
                        Button(String(format: String(localized: "%@ (全体)"), hierarchy.parent)) {
                            selectedRegion.wrappedValue = hierarchy.parent
                        }
                        Divider()
                        ForEach(hierarchy.children, id: \.self) { child in
                            Button(child) {
                                selectedRegion.wrappedValue = "\(hierarchy.parent), \(child)"
                            }
                        }
                    }
                }
            }
        } label: {
            selectorBox(
                text: selectedRegion.wrappedValue,
                placeholder: String(localized: "タップして生産地を選択...")
            )
        }
    }

    private func selectorBox(text: String, placeholder: String) -> some View {
        HStack {
            Text(text.isEmpty ? placeholder : text)
                .foregroundStyle(text.isEmpty ? .secondary : .primary)
                .lineLimit(1)
            Spacer()
            Image(systemName: "chevron.up.chevron.down")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview("Wine") {
    let vm = AddFlowViewModel()
    vm.selectedCategory = .wine
    vm.guessedWineBlend = [
        BlendComponent(variety: "カベルネ・ソーヴィニヨン", percentage: 70),
        BlendComponent(variety: "メルロ", percentage: 30)
    ]
    vm.guessedWineRegion = "フランス, ボルドー"

    return NavigationStack {
        AddBlindGuessView(viewModel: vm)
            .navigationTitle("ブラインド予想")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Sake") {
    let vm = AddFlowViewModel()
    vm.selectedCategory = .sake
    vm.guessedSakeSpecificName = "純米大吟醸"
    vm.guessedSakeRiceVariety = "山田錦"
    vm.guessedSakeRegion = "日本, 山口県"

    return NavigationStack {
        AddBlindGuessView(viewModel: vm)
            .navigationTitle("ブラインド予想")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Beer") {
    let vm = AddFlowViewModel()
    vm.selectedCategory = .beer
    vm.guessedBeerStyle = "IPA"
    vm.guessedBeerRegion = "アメリカ"

    return NavigationStack {
        AddBlindGuessView(viewModel: vm)
            .navigationTitle("ブラインド予想")
            .navigationBarTitleDisplayMode(.inline)
    }
}
