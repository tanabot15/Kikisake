//  GeneralInfoStepView.swift
//  Kikisake

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

/// [Step 1] 一般的な情報（酒種・基本情報）入力ビュー
public struct GeneralInfoStepView: View {
    @Bindable var viewModel: AddFlowViewModel
    @FocusState<GeneralInfoField?>.Binding var focusedField: GeneralInfoField?
    var showAlert: (String) -> Void

    // ── 表面ラベル用の状態 ──
    @State private var isShowingFrontCamera: Bool = false
    @State private var isShowingFrontLibrary: Bool = false
    @State private var isShowingFrontActionDialog: Bool = false
    @State private var frontPhotoItem: PhotosPickerItem? = nil

    // ✨ 撮影または選択した直後の一時保持用（切り抜き選択ダイアログ用）
    @State private var pendingPickedImage: UIImage? = nil
    @State private var isShowingMattingChoiceDialog: Bool = false

    // ── 裏面ラベル用の状態 ──
    @State private var isShowingBackCamera: Bool = false
    @State private var isShowingBackLibrary: Bool = false
    @State private var isShowingBackActionDialog: Bool = false
    @State private var backPhotoItem: PhotosPickerItem? = nil

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
        .confirmationDialog(String(localized: "表面の写真を選択"), isPresented: $isShowingFrontActionDialog, titleVisibility: .visible) {
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
            
            // 写真が存在する場合の追加アクション（背景透過の切り替え・削除）
            if viewModel.selectedImageData != nil {
                if viewModel.isBackgroundRemoved {
                    // 現在透過されている場合は「背景ありの写真に戻す」オプションを表示
                    Button(String(localized: "背景ありの写真に戻す")) {
                        // 保持していたオリジナル画像に戻す
                        if let original = viewModel.originalImageData {
                            viewModel.selectedImageData = original
                            viewModel.isBackgroundRemoved = false
                        }
                    }
                    .foregroundColor(Color.accentColor)
                } else {
                    // 現在背景ありの場合は「背景を自動で透過にする」オプションを表示
                    Button(String(localized: "背景を自動で透過にする")) {
                        guard let data = viewModel.originalImageData ?? viewModel.selectedImageData,
                              let uiImage = UIImage(data: data) else { return }
                        Task {
                            let processedImage = await BottleMattingHelper.removeBackground(from: uiImage)
                            if let newData = processedImage.jpegData(compressionQuality: 0.8) {
                                await MainActor.run {
                                    viewModel.selectedImageData = newData
                                    viewModel.isBackgroundRemoved = true
                                }
                            }
                        }
                    }
                    .foregroundColor(Color.accentColor)
                }

                Button(String(localized: "写真を削除"), role: .destructive) {
                    viewModel.selectedImageData = nil
                    viewModel.originalImageData = nil // ✨ オリジナルもクリア
                    viewModel.isBackgroundRemoved = true
                    frontPhotoItem = nil
                }
            }
            
            Button(String(localized: "キャンセル"), role: .cancel) {}
        }
        // 写真の背景処理（くり抜き）を選択する確認ダイアログ
        .confirmationDialog(String(localized: "写真の処理方法を選択"), isPresented: $isShowingMattingChoiceDialog, titleVisibility: .visible) {
            Button {
                guard let image = pendingPickedImage else { return }
                let normalized = image.normalized()
                guard let originalData = normalized.jpegData(compressionQuality: 0.8) else { return }
                
                // ✨ オリジナルデータを保持した上で背景をくり抜く
                viewModel.originalImageData = originalData
                
                Task {
                    let processedImage = await BottleMattingHelper.removeBackground(from: normalized)
                    if let data = processedImage.jpegData(compressionQuality: 0.8) {
                        await MainActor.run {
                            viewModel.selectedImageData = data
                            viewModel.isBackgroundRemoved = true
                            pendingPickedImage = nil
                        }
                    }
                }
            } label: {
                HStack {
                    Text(String(localized: "ボトルのみ自動で切り抜く"))
                    Image(systemName: "wand.and.stars")
                }
            }
            .foregroundColor(Color.accentColor)

            Button {
                guard let image = pendingPickedImage else { return }
                let normalized = image.normalized()
                if let data = normalized.jpegData(compressionQuality: 0.8) {
                    viewModel.originalImageData = data // ✨ オリジナルとしても保存
                    viewModel.selectedImageData = data
                    viewModel.isBackgroundRemoved = false
                }
                pendingPickedImage = nil
            } label: {
                HStack {
                    Text(String(localized: "そのままの写真を使用する"))
                    Image(systemName: "photo")
                }
            }
            .foregroundColor(Color.accentColor)

            Button(String(localized: "キャンセル"), role: .cancel) {
                pendingPickedImage = nil
            }
        } message: {
            Text(String(localized: "ワインや料理と一緒に撮影した写真の場合、「そのままの写真を使用する」を選択すると背景が維持されます。"))
        }
        // ── 表面のシート・ピッカーモダール ──
        .sheet(isPresented: $isShowingFrontCamera) {
            ImagePickerView(sourceType: .camera) { image in
                pendingPickedImage = image
                isShowingMattingChoiceDialog = true
            }
        }
        .photosPicker(isPresented: $isShowingFrontLibrary, selection: $frontPhotoItem, matching: .images)
        .onChange(of: frontPhotoItem) { _, newValue in
            guard let newItem = newValue else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    
                    let normalizedImage = uiImage.normalized()
                    
                    if let normalizedData = normalizedImage.jpegData(compressionQuality: 0.8) {
                        await MainActor.run {
                            // 1. ユーザーがいつでも「背景あり」に戻せるよう、オリジナルデータを保持
                            viewModel.originalImageData = normalizedData
                            
                            // 2. 処理前の画像を一時保持して、ダイアログを表示
                            pendingPickedImage = normalizedImage
                            frontPhotoItem = nil
                            isShowingMattingChoiceDialog = true
                        }
                    } else {
                        await MainActor.run {
                            frontPhotoItem = nil
                        }
                    }
                } else {
                    await MainActor.run {
                        frontPhotoItem = nil
                    }
                }
            }
        }
        // ── 裏面のシート・ピッカーモダール ──
        .sheet(isPresented: $isShowingBackCamera) {
            ImagePickerView(sourceType: .camera) { image in
                if let data = image.jpegData(compressionQuality: 0.8) {
                    viewModel.selectedBackImageData = data
                }
            }
        }
        .photosPicker(isPresented: $isShowingBackLibrary, selection: $backPhotoItem, matching: .images)
        .onChange(of: backPhotoItem) { _, newValue in
            guard let newItem = newValue else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        viewModel.selectedBackImageData = data
                    }
                }
                await MainActor.run {
                    backPhotoItem = nil
                }
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
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
                        action: {
                            isShowingFrontActionDialog = true
                        }
                    )

                    photoCard(
                        title: String(localized: "裏面"),
                        subtitle: String(localized: "詳細・スペック"),
                        imageData: viewModel.selectedBackImageData,
                        hasImage: viewModel.selectedBackImageData != nil,
                        action: {
                            isShowingBackActionDialog = true
                        }
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func photoCard(
        title: String,
        subtitle: String,
        imageData: Data?,
        hasImage: Bool,
        action: @escaping () -> Void
    ) -> some View {
        let cardSize: CGFloat = 140

        VStack(alignment: .center, spacing: 10) {
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

    @ViewBuilder
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

    @ViewBuilder
    private var basicInfoSection: some View {
        Section(String(localized: "基本情報")) {
            TextField(String(localized: "銘柄名 (必須)"), text: $viewModel.name)
                .focused($focusedField, equals: .name)
            
            TextField(String(localized: "生産者 / 蔵元 / ブルワリー"), text: $viewModel.producer)
                .focused($focusedField, equals: .producer)

            categorySpecificFields

            HStack(spacing: 8) {
                TextField(String(localized: "生産地 (例: ボルドー, 新潟)"), text: $viewModel.region)
                    .focused($focusedField, equals: .region)

                Menu {
                    ForEach(RegionPresetOptions.regions(for: viewModel.selectedCategory)) { hierarchy in
                        if hierarchy.children.isEmpty {
                            Button(hierarchy.parent) {
                                viewModel.region = hierarchy.parent
                            }
                        } else {
                            Menu(hierarchy.parent) {
                                // 「国/都道府県」のみを選択する場合のオプション
                                Button(String(format: String(localized: "%@ (全体)"), hierarchy.parent)) {
                                    viewModel.region = hierarchy.parent
                                }
                                Divider()
                                // 子エリア（地区・詳細産地）の選択
                                ForEach(hierarchy.children, id: \.self) { child in
                                    Button(child) {
                                        viewModel.region = "\(hierarchy.parent), \(child)"
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "mappin.and.ellipse.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                }
            }
            
            TextField(String(localized: "ヴィンテージ / 製造年月 (例: 2020)"), text: $viewModel.vintage)
                .focused($focusedField, equals: .vintage)
            
            TextField(String(localized: "アルコール度数 (例: 14.5 または 5)"), text: $viewModel.abvString)
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .abv)
            
            TextField(String(localized: "価格 (円)"), text: $viewModel.priceString)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .price)
        }
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
                ForEach($viewModel.blendComponents) { $component in
                    HStack(spacing: 8) {
                        TextField(String(localized: "品種 (例: カベルネ・ソーヴィニヨン)"), text: $component.variety)
                            .focused($focusedField, equals: .extra)
                        
                        Menu {
                            ForEach(BeveragePresetOptions.grapeVarieties, id: \.self) { variety in
                                Button(variety) {
                                    component.variety = variety
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.down.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color.accentColor)
                        }
                        
                        TextField(String(localized: "割合"), value: $component.percentage, format: .number)
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                            .multilineTextAlignment(.trailing)
                        
                        Text("%")
                            .foregroundStyle(.secondary)
                    }
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
            
            HStack(spacing: 8) {
                TextField(String(localized: "使用米 (例: 山田錦)"), text: $viewModel.riceVariety)
                    .focused($focusedField, equals: .extra)
                
                Menu {
                    ForEach(BeveragePresetOptions.riceVarieties, id: \.self) { rice in
                        Button(rice) {
                            viewModel.riceVariety = rice
                        }
                    }
                } label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                }
            }
            
            TextField(String(localized: "精米歩合 (例: 50%)"), text: $viewModel.polishingRate)
            TextField(String(localized: "日本酒度 (例: +3.0)"), text: $viewModel.sakeMeterValue)
            
        case .beer:
            HStack(spacing: 8) {
                TextField(String(localized: "ビアスタイル (例: IPA, Stout)"), text: $viewModel.beerStyle)
                    .focused($focusedField, equals: .extra)
                
                Menu {
                    ForEach(BeveragePresetOptions.beerStyles, id: \.self) { style in
                        Button(style) {
                            viewModel.beerStyle = style
                        }
                    }
                } label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                }
            }
            
            TextField(String(localized: "IBU (国際苦味単位)"), text: $viewModel.ibu)
                .keyboardType(.numberPad)
        }
    }
}

// 補助的なUIImage正規化拡張
fileprivate extension UIImage {
    func normalized() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage ?? self
    }
}

/// 保管場所選択ビューなど
public struct StoragePickerWithGridMappingView: View {
    @Bindable var viewModel: AddFlowViewModel
    @Query(sort: \StorageLocation.createdAt, order: .forward) private var locations: [StorageLocation]
    @Query private var allItems: [BeverageItem]

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker(String(localized: "保管場所"), selection: $viewModel.storageLocation) {
                if locations.isEmpty {
                    Text(String(localized: "未設定 (自動作成)")).tag("未設定")
                } else {
                    ForEach(locations, id: \.name) { loc in
                        Text(loc.name).tag(loc.name)
                    }
                }
            }
            .onChange(of: viewModel.storageLocation) { _, _ in
                viewModel.selectedGridRow = nil
                viewModel.selectedGridColumn = nil
            }

            if let currentLocation = locations.first(where: { $0.name == viewModel.storageLocation }),
               currentLocation.isGridEnabled {
                
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "square.grid.3x3.fill")
                            .foregroundStyle(Color.accentColor)
                        Text(String(localized: "棚・スロット位置の指定 (任意)"))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    HStack(spacing: 12) {
                        Picker(String(localized: "段 (Row)"), selection: Binding(
                            get: { viewModel.selectedGridRow ?? 1 },
                            set: { viewModel.selectedGridRow = $0 }
                        )) {
                            ForEach(1...currentLocation.gridRows, id: \.self) { row in
                                Text(String(format: String(localized: "第 %d 段"), row)).tag(row)
                            }
                        }
                        .pickerStyle(.menu)

                        Picker(String(localized: "列 (Column)"), selection: Binding(
                            get: { viewModel.selectedGridColumn ?? 1 },
                            set: { viewModel.selectedGridColumn = $0 }
                        )) {
                            ForEach(1...currentLocation.gridColumns, id: \.self) { col in
                                Text(String(format: String(localized: "%d 列目"), col)).tag(col)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    if let row = viewModel.selectedGridRow,
                       let col = viewModel.selectedGridColumn {
                        let isOccupied = allItems.contains { item in
                            item.storageLocation == currentLocation.name &&
                            item.gridRow == row &&
                            item.gridColumn == col &&
                            item.id != viewModel.sourceItem?.id
                        }

                        if isOccupied {
                            Label(String(localized: "このスロットにはすでに別のボトルが配置されています"), systemImage: "exclamationmark.triangle.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        } else {
                            Label(String(localized: "このスロットは空いています"), systemImage: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(.green)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .onAppear {
            if locations.isEmpty {
                viewModel.storageLocation = "未設定"
            } else if viewModel.storageLocation.isEmpty || !locations.contains(where: { $0.name == viewModel.storageLocation }) {
                if let first = locations.first {
                    viewModel.storageLocation = first.name
                }
            }
        }
    }
}

/// UIKitのカメラ（UIImagePickerController）ラッパー
public struct ImagePickerView: UIViewControllerRepresentable {
    public var sourceType: UIImagePickerController.SourceType
    public var onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }

        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: StorageLocation.self, BeverageItem.self, TastingLog.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    struct PreviewWrapper: View {
        @State private var vm = AddFlowViewModel()
        @FocusState private var field: GeneralInfoField?
        var body: some View {
            NavigationStack {
                GeneralInfoStepView(viewModel: vm, focusedField: $field) { _ in }
            }
        }
    }
    return PreviewWrapper().modelContainer(container)
}
