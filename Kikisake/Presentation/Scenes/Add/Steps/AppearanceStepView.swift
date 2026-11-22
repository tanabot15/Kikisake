//
//  AppearanceStepView.swift
//  Kikisake
//

import SwiftUI

/// Step 2 view for selecting beverage appearance color and notes.
public struct AddStep2AppearanceView: View {
    @Bindable var viewModel: AddFlowViewModel
    @State private var showPaywall: Bool = false

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    private var currentWineType: String {
        guard viewModel.selectedCategory == .wine,
              let json = viewModel.sourceItem?.specificMetadataJSON ?? buildCurrentWineJSON(),
              let data = json.data(using: .utf8),
              let meta = try? JSONDecoder().decode(WineSpecificMetadata.self, from: data) else {
            return viewModel.wineType
        }
        return meta.wineType
    }

    private func buildCurrentWineJSON() -> String? {
        let meta = WineSpecificMetadata(
            wineType: viewModel.wineType,
            grapeVarieties: viewModel.grapeVarieties,
            blendComponents: viewModel.blendComponents.filter { !$0.variety.isEmpty }
        )
        guard let data = try? JSONEncoder().encode(meta) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private var colorOptions: [ColorOption] {
        TastingOptions.colorOptions(for: viewModel.selectedCategory, wineType: currentWineType)
    }

    private var selectedColorOption: ColorOption? {
        colorOptions.first { $0.hex.lowercased() == viewModel.appearanceColorHex.lowercased() }
            ?? colorOptions.first { viewModel.appearanceNotes.contains($0.name) }
    }

    public var body: some View {
        Form {
            colorPaletteSection
            selectedColorNotesSection
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var colorPaletteSection: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

        return Section {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.selectedCategory.displayName)の色調")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("グラスを傾けて見える最も近い色をタップしてください。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(colorOptions) { option in
                        colorOptionButton(for: option)
                    }
                }
                .padding(.vertical, 6)
            }
            .padding(.vertical, 4)
        }
    }

    private func colorOptionButton(for option: ColorOption) -> some View {
        let isSelected = viewModel.appearanceColorHex.lowercased() == option.hex.lowercased()
        let isFree = TastingOptions.isFreeColorOption(option, in: colorOptions)
        let isLocked = !AppState.shared.isProVersion && !isFree

        return Button {
            if isLocked {
                showPaywall = true
            } else {
                viewModel.appearanceColorHex = option.hex
                viewModel.appearanceNotes = option.name
            }
        } label: {
            ZStack {
                Circle()
                    .fill(option.color)
                    .frame(width: 44, height: 44)
                    .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 2)
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected ? Color.accentColor : Color.primary.opacity(0.2),
                                lineWidth: isSelected ? 3 : 1
                            )
                    )

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(isLightColor(hex: option.hex) ? .black : .white)
                }

                if isLocked {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "lock.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(.white)
                                .padding(3)
                                .background(Color.orange)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .frame(width: 44, height: 44)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var selectedColorNotesSection: some View {
        Section("選択された外観・詳細メモ") {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text("選択中の色名:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let currentOption = selectedColorOption {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(currentOption.color)
                                .frame(width: 14, height: 14)
                                .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 0.5))

                            Text(currentOption.name)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.accentColor)
                        }
                    } else {
                        Text("未選択")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                }

                Divider()

                TextField(
                    "外観の表現・補足メモ (例: 深みのあるルビーレッド。粘性が高く輝きがある)",
                    text: $viewModel.appearanceNotes,
                    axis: .vertical
                )
                .lineLimit(2...4)
            }
            .padding(.vertical, 4)
        }
    }

    private func isLightColor(hex: String) -> Bool {
        let cleanedHex = hex.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&rgb)
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        return brightness > 0.65
    }
}

#Preview {
    AppearanceStepViewPreviewHost()
}

private struct AppearanceStepViewPreviewHost: View {
    @State private var vm = AddFlowViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("カテゴリ", selection: $vm.selectedCategory) {
                    ForEach(BeverageCategory.allCases, id: \.self) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top)

                if vm.selectedCategory == .wine {
                    Picker("ワインタイプ", selection: $vm.wineType) {
                        Text("赤").tag("赤")
                        Text("白").tag("白")
                        Text("ロゼ").tag("ロゼ")
                        Text("オレンジ").tag("オレンジ")
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                AddStep2AppearanceView(viewModel: vm)
            }
            .navigationTitle("外観選択プレビュー")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
