//
//  GeneralInfoStepView.swift
//  Kikisake
//

import SwiftUI
import SwiftData
import PhotosUI
import UIKit

public enum GeneralInfoField {
    case name
    case producer
    case region
    case vintage
    case abv
    case price
    case extra
}

/// Step 1 view for entering beverage category, photos, and basic metadata.
public struct AddStep1GeneralInfoView: View {
    @Bindable var viewModel: AddFlowViewModel
    @FocusState<GeneralInfoField?>.Binding var focusedField: GeneralInfoField?
    var showAlert: (String) -> Void

    @State private var isShowingFrontCamera: Bool = false
    @State private var isShowingFrontLibrary: Bool = false
    @State private var isShowingFrontActionDialog: Bool = false
    @State private var frontPhotoItem: PhotosPickerItem? = nil

    @State private var pendingPickedImage: UIImage? = nil
    @State private var isShowingMattingChoiceDialog: Bool = false

    @State private var isShowingBackCamera: Bool = false
    @State private var isShowingBackLibrary: Bool = false
    @State private var isShowingBackActionDialog: Bool = false
    @State private var backPhotoItem: PhotosPickerItem? = nil

    @State private var isCustomRegionInput: Bool = false
    @State private var isCustomRiceInput: Bool = false
    @State private var isCustomBeerStyleInput: Bool = false

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
            labelPhotoSection
            categorySection
            basicInfoSection
        }
        .onAppear {
            syncCustomInputStates()
            initializeNumericDefaultsIfNeeded()
        }
        .onChange(of: viewModel.selectedCategory) { _, newCategory in
            let current = Double(viewModel.abvString)
            if current == nil || current == 13.5 || current == 15.0 || current == 5.0 {
                viewModel.abvString = String(format: "%.1f", defaultABV(for: newCategory))
            }
        }
        .confirmationDialog(String(localized: "表面の写真を選択"), isPresented: $isShowingFrontActionDialog, titleVisibility: .visible) {
            frontPhotoActionButtons
        }
        .confirmationDialog(String(localized: "裏面の写真を選択"), isPresented: $isShowingBackActionDialog, titleVisibility: .visible) {
            backPhotoActionButtons
        }
        .confirmationDialog(String(localized: "写真の処理方法を選択"), isPresented: $isShowingMattingChoiceDialog, titleVisibility: .visible) {
            mattingChoiceButtons
        } message: {
            Text(String(localized: "ワインや料理と一緒に撮影した写真の場合、「そのままの写真を使用する」を選択すると背景が維持されます。"))
        }
        .sheet(isPresented: $isShowingFrontCamera) {
            ImagePickerView(sourceType: .camera) { image in
                pendingPickedImage = image
                isShowingMattingChoiceDialog = true
            }
        }
        .photosPicker(isPresented: $isShowingFrontLibrary, selection: $frontPhotoItem, matching: .images)
        .onChange(of: frontPhotoItem) { _, newValue in
            handleFrontPhotoPicked(newValue)
        }
        .sheet(isPresented: $isShowingBackCamera) {
            ImagePickerView(sourceType: .camera) { image in
                if let data = image.normalized().jpegData(compressionQuality: 0.8) {
                    viewModel.selectedBackImageData = data
                }
            }
        }
        .photosPicker(isPresented: $isShowingBackLibrary, selection: $backPhotoItem, matching: .images)
        .onChange(of: backPhotoItem) { _, newValue in
            handleBackPhotoPicked(newValue)
        }
    }

    // MARK: - Setup & Photo Handlers

    private func initializeNumericDefaultsIfNeeded() {
        if viewModel.vintage.isEmpty {
            viewModel.vintage = "2024"
        }
        if viewModel.abvString.isEmpty {
            viewModel.abvString = String(format: "%.1f", defaultABV(for: viewModel.selectedCategory))
        }
    }

    private func syncCustomInputStates() {
        if !viewModel.region.isEmpty {
            let validRegions = RegionPresetOptions.regions(for: viewModel.selectedCategory).flatMap { hierarchy in
                [hierarchy.parent] + hierarchy.children.map { "\(hierarchy.parent), \($0)" }
            }
            if !validRegions.contains(viewModel.region) {
                isCustomRegionInput = true
            }
        }
        if !viewModel.riceVariety.isEmpty && !BeveragePresetOptions.riceVarieties.contains(viewModel.riceVariety) {
            isCustomRiceInput = true
        }
        if !viewModel.beerStyle.isEmpty && !BeveragePresetOptions.beerStyles.contains(viewModel.beerStyle) {
            isCustomBeerStyleInput = true
        }
    }

    private func handleFrontPhotoPicked(_ item: PhotosPickerItem?) {
        guard let newItem = item else { return }
        Task {
            if let data = try? await newItem.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                let normalizedImage = uiImage.normalized()
                if let normalizedData = normalizedImage.jpegData(compressionQuality: 0.8) {
                    await MainActor.run {
                        viewModel.originalImageData = normalizedData
                        pendingPickedImage = normalizedImage
                        frontPhotoItem = nil
                        isShowingMattingChoiceDialog = true
                    }
                    return
                }
            }
            await MainActor.run { frontPhotoItem = nil }
        }
    }

    private func handleBackPhotoPicked(_ item: PhotosPickerItem?) {
        guard let newItem = item else { return }
        Task {
            if let data = try? await newItem.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data),
               let normalizedData = uiImage.normalized().jpegData(compressionQuality: 0.8) {
                await MainActor.run {
                    viewModel.selectedBackImageData = normalizedData
                    backPhotoItem = nil
                }
            } else {
                await MainActor.run { backPhotoItem = nil }
            }
        }
    }

    private func removeBackgroundForFrontImage() {
        guard let data = viewModel.originalImageData ?? viewModel.selectedImageData,
              let uiImage = UIImage(data: data) else { return }
        if viewModel.originalImageData == nil {
            viewModel.originalImageData = data
        }
        Task {
            let processedImage = await BottleMattingHelper.removeBackground(from: uiImage)
            if let newData = processedImage.pngData() {
                await MainActor.run {
                    viewModel.selectedImageData = newData
                    viewModel.isBackgroundRemoved = true
                }
            }
        }
    }

    // MARK: - Dialog Buttons

    @ViewBuilder
    private var frontPhotoActionButtons: some View {
        Button(String(localized: "写真を撮る")) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                isShowingFrontCamera = true
            } else {
                showAlert(String(localized: "このデバイスではカメラを利用できません。"))
            }
        }
        Button(String(localized: "ライブラリから選ぶ")) {
            isShowingFrontLibrary = true
        }

        if viewModel.selectedImageData != nil {
            if viewModel.isBackgroundRemoved {
                if let original = viewModel.originalImageData {
                    Button(String(localized: "背景ありの写真に戻す")) {
                        viewModel.selectedImageData = original
                        viewModel.isBackgroundRemoved = false
                    }
                    .tint(.accentColor)
                }
            } else {
                Button(String(localized: "背景を自動で透過にする")) {
                    removeBackgroundForFrontImage()
                }
                .tint(.accentColor)
            }

            Button(String(localized: "写真を削除"), role: .destructive) {
                viewModel.clearFrontImage()
                frontPhotoItem = nil
            }
        }

        Button(String(localized: "キャンセル"), role: .cancel) {}
    }

    @ViewBuilder
    private var backPhotoActionButtons: some View {
        Button(String(localized: "写真を撮る")) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                isShowingBackCamera = true
            } else {
                showAlert(String(localized: "このデバイスではカメラを利用できません。"))
            }
        }
        Button(String(localized: "ライブラリから選ぶ")) {
            isShowingBackLibrary = true
        }

        if viewModel.selectedBackImageData != nil {
            Button(String(localized: "写真を削除"), role: .destructive) {
                viewModel.clearBackImage()
                backPhotoItem = nil
            }
        }

        Button(String(localized: "キャンセル"), role: .cancel) {}
    }

    @ViewBuilder
    private var mattingChoiceButtons: some View {
        Button {
            guard let image = pendingPickedImage else { return }
            let normalized = image.normalized()
            guard let originalData = normalized.jpegData(compressionQuality: 0.8) else { return }

            viewModel.originalImageData = originalData

            Task {
                let processedImage = await BottleMattingHelper.removeBackground(from: normalized)
                if let data = processedImage.pngData() {
                    await MainActor.run {
                        viewModel.selectedImageData = data
                        viewModel.isBackgroundRemoved = true
                        pendingPickedImage = nil
                    }
                }
            }
        } label: {
            Label(String(localized: "ボトルのみ自動で切り抜く"), systemImage: "wand.and.stars")
        }
        .tint(.accentColor)

        Button {
            guard let image = pendingPickedImage else { return }
            let normalized = image.normalized()
            if let data = normalized.jpegData(compressionQuality: 0.8) {
                viewModel.originalImageData = data
                viewModel.selectedImageData = data
                viewModel.isBackgroundRemoved = false
            }
            pendingPickedImage = nil
        } label: {
            Label(String(localized: "そのままの写真を使用する"), systemImage: "photo")
        }
        .tint(.accentColor)

        Button(String(localized: "キャンセル"), role: .cancel) {
            pendingPickedImage = nil
        }
    }

    // MARK: - Sections

    private var labelPhotoSection: some View {
        Section(String(localized: "写真")) {
            VStack(spacing: 16) {
                HStack {
                    Label(String(localized: "ボトル・ラベル写真"), systemImage: "camera.viewfinder")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.top, 4)

                HStack(spacing: 12) {
                    photoCard(
                        title: String(localized: "表面"),
                        subtitle: String(localized: "メイン写真"),
                        imageData: viewModel.selectedImageData,
                        hasImage: viewModel.selectedImageData != nil,
                        action: { isShowingFrontActionDialog = true }
                    )

                    photoCard(
                        title: String(localized: "裏面"),
                        subtitle: String(localized: "詳細・スペック"),
                        imageData: viewModel.selectedBackImageData,
                        hasImage: viewModel.selectedBackImageData != nil,
                        action: { isShowingBackActionDialog = true }
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func photoCard(
        title: String,
        subtitle: String,
        imageData: Data?,
        hasImage: Bool,
        action: @escaping () -> Void
    ) -> some View {
        let cardSize: CGFloat = 140

        return VStack(alignment: .center, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray6))
                    .frame(width: cardSize, height: cardSize)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(.systemGray4).opacity(0.6), lineWidth: 1)
                    )

                if let data = imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: cardSize, height: cardSize)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .clipped()
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: title == "表面" ? "camera.viewfinder" : "text.document")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.accentColor.opacity(0.8))
                        Text(subtitle)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(width: cardSize, height: cardSize)

            Button(action: action) {
                HStack(spacing: 4) {
                    Image(systemName: hasImage ? "ellipsis.circle.fill" : "plus.circle.fill")
                        .font(.caption)
                    Text(hasImage ? String(localized: "編集・削除") : title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .frame(width: cardSize)
                .padding(.vertical, 8)
                .background(hasImage ? Color(.systemGray5) : Color.accentColor.opacity(0.1))
                .foregroundStyle(hasImage ? .primary : Color.accentColor)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    private var categorySection: some View {
        Section(String(localized: "酒種")) {
            Picker(String(localized: "酒種"), selection: $viewModel.selectedCategory) {
                ForEach(BeverageCategory.allCases, id: \.self) { category in
                    Text(category.displayName).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 4)
        }
    }

    private var basicInfoSection: some View {
        Section(String(localized: "基本情報")) {
            TextField(String(localized: "銘柄名 (必須)"), text: $viewModel.name)
                .focused($focusedField, equals: .name)

            TextField(String(localized: "生産者 / 蔵元 / ブルワリー"), text: $viewModel.producer)
                .focused($focusedField, equals: .producer)

            categorySpecificFields
            regionSelectorRow

            SteppedNumberField(
                title: String(localized: "ヴィンテージ / 製造年月 (例: 2024)"),
                text: $viewModel.vintage,
                step: 1.0,
                range: 1950...2030,
                defaultValue: 2024.0,
                isInteger: true,
                focusedField: $focusedField,
                fieldTag: .vintage,
                keyboardType: .numberPad
            )

            SteppedNumberField(
                title: String(localized: "アルコール度数 (例: 14.5)"),
                text: $viewModel.abvString,
                step: 0.5,
                range: 0.0...70.0,
                defaultValue: defaultABV(for: viewModel.selectedCategory),
                isInteger: false,
                focusedField: $focusedField,
                fieldTag: .abv,
                keyboardType: .decimalPad
            )

            TextField(String(localized: "価格 (円)"), text: $viewModel.priceString)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .price)
        }
    }

    private var regionSelectorRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(String(localized: "生産地"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(
                    isCustomRegionInput
                        ? String(localized: "選択肢から選択する")
                        : String(localized: "直接入力（その他）に切り替え")
                ) {
                    isCustomRegionInput.toggle()
                }
                .font(.caption)
            }

            if isCustomRegionInput {
                TextField(String(localized: "生産地を自由入力 (例: スペイン, リオハ)"), text: $viewModel.region)
                    .focused($focusedField, equals: .region)
                    .textFieldStyle(.roundedBorder)
            } else {
                Menu {
                    ForEach(RegionPresetOptions.regions(for: viewModel.selectedCategory)) { hierarchy in
                        if hierarchy.children.isEmpty {
                            Button(hierarchy.parent) {
                                viewModel.region = hierarchy.parent
                            }
                        } else {
                            Menu(hierarchy.parent) {
                                Button(String(format: String(localized: "%@ (全体)"), hierarchy.parent)) {
                                    viewModel.region = hierarchy.parent
                                }
                                Divider()
                                ForEach(hierarchy.children, id: \.self) { child in
                                    Button(child) {
                                        viewModel.region = "\(hierarchy.parent), \(child)"
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    menuSelectorLabel(
                        text: viewModel.region,
                        placeholder: String(localized: "タップして生産地を選択...")
                    )
                }
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var categorySpecificFields: some View {
        switch viewModel.selectedCategory {
        case .wine:
            Picker(String(localized: "ワインタイプ"), selection: $viewModel.wineType) {
                Text(String(localized: "赤")).tag("赤")
                Text(String(localized: "白")).tag("白")
                Text(String(localized: "ロゼ")).tag("ロゼ")
                Text(String(localized: "オレンジ")).tag("オレンジ")
                Text(String(localized: "スパークリング")).tag("スパークリング")
            }
            .padding(.vertical, 4)

            Group {
                ForEach(Array(viewModel.blendComponents.enumerated()), id: \.element.id) { index, _ in
                    WineBlendComponentRow(
                        component: $viewModel.blendComponents[index],
                        index: index,
                        totalCount: viewModel.blendComponents.count,
                        focusedField: $focusedField
                    )
                }
                .onDelete(perform: viewModel.removeBlendComponent)

                Button {
                    viewModel.addBlendComponent()
                } label: {
                    Label(String(localized: "品種を追加"), systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }

            TextField(String(localized: "原産地呼称 (例: AOC ボルドー / DOCG バローロ)"), text: $viewModel.appellation)
                .focused($focusedField, equals: .extra)

        case .sake:
            Picker(String(localized: "特定名称"), selection: $viewModel.sakeSpecificName) {
                Text(String(localized: "純米大吟醸")).tag("純米大吟醸")
                Text(String(localized: "純米吟醸")).tag("純米吟醸")
                Text(String(localized: "大吟醸")).tag("大吟醸")
                Text(String(localized: "特別純米")).tag("特別純米")
                Text(String(localized: "純米酒")).tag("純米")
                Text(String(localized: "本醸造")).tag("本醸造")
                Text(String(localized: "その他")).tag("その他")
            }

            presetOrCustomField(
                label: String(localized: "使用米"),
                isCustomInput: $isCustomRiceInput,
                text: $viewModel.riceVariety,
                customPlaceholder: String(localized: "使用米を自由入力 (例: 山田錦)"),
                menuPlaceholder: String(localized: "タップして使用米を選択..."),
                options: BeveragePresetOptions.riceVarieties
            )

            TextField(String(localized: "精米歩合 (例: 50%)"), text: $viewModel.polishingRate)
            TextField(String(localized: "日本酒度 (例: +3.0)"), text: $viewModel.sakeMeterValue)

        case .beer:
            presetOrCustomField(
                label: String(localized: "ビアスタイル"),
                isCustomInput: $isCustomBeerStyleInput,
                text: $viewModel.beerStyle,
                customPlaceholder: String(localized: "ビアスタイルを自由入力 (例: IPA)"),
                menuPlaceholder: String(localized: "タップしてビアスタイルを選択..."),
                options: BeveragePresetOptions.beerStyles
            )

            TextField(String(localized: "IBU (国際苦味単位)"), text: $viewModel.ibu)
                .keyboardType(.numberPad)
        }
    }

    private func presetOrCustomField(
        label: String,
        isCustomInput: Binding<Bool>,
        text: Binding<String>,
        customPlaceholder: String,
        menuPlaceholder: String,
        options: [String]
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(
                    isCustomInput.wrappedValue
                        ? String(localized: "選択肢から選択する")
                        : String(localized: "直接入力（その他）に切り替え")
                ) {
                    isCustomInput.wrappedValue.toggle()
                }
                .font(.caption)
            }

            if isCustomInput.wrappedValue {
                TextField(customPlaceholder, text: text)
                    .focused($focusedField, equals: .extra)
                    .textFieldStyle(.roundedBorder)
            } else {
                Menu {
                    ForEach(options, id: \.self) { option in
                        Button(option) {
                            if option == String(localized: "その他") {
                                text.wrappedValue = ""
                                isCustomInput.wrappedValue = true
                            } else {
                                text.wrappedValue = option
                            }
                        }
                    }
                } label: {
                    menuSelectorLabel(text: text.wrappedValue, placeholder: menuPlaceholder)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func menuSelectorLabel(text: String, placeholder: String) -> some View {
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

    private func defaultABV(for category: BeverageCategory) -> Double {
        switch category {
        case .wine: 13.5
        case .sake: 15.0
        case .beer: 5.0
        }
    }
}

private struct WineBlendComponentRow: View {
    @Binding var component: BlendComponent
    let index: Int
    let totalCount: Int
    @FocusState<GeneralInfoField?>.Binding var focusedField: GeneralInfoField?

    @State private var isCustomInput: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(
                    totalCount > 1
                        ? String(format: String(localized: "ブドウ品種 %d"), index + 1)
                        : String(localized: "ブドウ品種")
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                Spacer()
                Button(
                    isCustomInput
                        ? String(localized: "選択肢から選択する")
                        : String(localized: "直接入力（その他）に切り替え")
                ) {
                    isCustomInput.toggle()
                }
                .font(.caption)
            }

            HStack(spacing: 8) {
                if isCustomInput {
                    TextField(String(localized: "品種を自由入力 (例: カベルネ・ソーヴィニヨン)"), text: $component.variety)
                        .focused($focusedField, equals: .extra)
                        .textFieldStyle(.roundedBorder)
                } else {
                    Menu {
                        ForEach(BeveragePresetOptions.grapeVarieties, id: \.self) { variety in
                            Button(variety) {
                                if variety == String(localized: "その他") {
                                    component.variety = ""
                                    isCustomInput = true
                                } else {
                                    component.variety = variety
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(component.variety.isEmpty ? String(localized: "タップして品種を選択...") : component.variety)
                                .foregroundStyle(component.variety.isEmpty ? .secondary : .primary)
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

                TextField(String(localized: "割合"), value: $component.percentage, format: .number)
                    .keyboardType(.numberPad)
                    .frame(width: 48)
                    .multilineTextAlignment(.trailing)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                Text("%")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            if !component.variety.isEmpty && !BeveragePresetOptions.grapeVarieties.contains(component.variety) {
                isCustomInput = true
            }
        }
    }
}

private extension UIImage {
    func normalized() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage ?? self
    }
}

#Preview {
    GeneralInfoStepViewPreviewHost()
}

private struct GeneralInfoStepViewPreviewHost: View {
    private let container: ModelContainer
    @State private var viewModel = AddFlowViewModel()
    @FocusState private var field: GeneralInfoField?

    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        self.container = try! ModelContainer(
            for: StorageLocation.self,
            BeverageItem.self,
            TastingLog.self,
            configurations: config
        )
    }

    var body: some View {
        NavigationStack {
            AddStep1GeneralInfoView(viewModel: viewModel, focusedField: $field) { _ in }
        }
        .modelContainer(container)
    }
}
