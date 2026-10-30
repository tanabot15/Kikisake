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
        // ── 全体のルート階層にモダールを一本化し、二重提示エラーを完全に防止 ──
        .confirmationDialog("表面の写真を選択", isPresented: $isShowingFrontActionDialog, titleVisibility: .visible) {
            Button("写真を撮る") {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    isShowingFrontCamera = true
                } else {
                    showAlert("このデバイスではカメラを利用できません。")
                }
            }
            Button("ライブラリから選ぶ") {
                isShowingFrontLibrary = true
            }
            if viewModel.selectedImageData != nil {
                Button("写真を削除", role: .destructive) {
                    viewModel.selectedImageData = nil
                    frontPhotoItem = nil
                }
            }
            Button("キャンセル", role: .cancel) {}
        }
        .confirmationDialog("裏面の写真を選択", isPresented: $isShowingBackActionDialog, titleVisibility: .visible) {
            Button("写真を撮る") {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    isShowingBackCamera = true
                } else {
                    showAlert("このデバイスではカメラを利用できません。")
                }
            }
            Button("ライブラリから選ぶ") {
                isShowingBackLibrary = true
            }
            if viewModel.selectedBackImageData != nil {
                Button("写真を削除", role: .destructive) {
                    viewModel.selectedBackImageData = nil
                    backPhotoItem = nil
                }
            }
            Button("キャンセル", role: .cancel) {}
        }
        // ── 表面のシート・ピッカーモダール ──
        .sheet(isPresented: $isShowingFrontCamera) {
            ImagePickerView(sourceType: .camera) { image in
                if let data = image.jpegData(compressionQuality: 0.8) {
                    viewModel.selectedImageData = data
                }
            }
        }
        .photosPicker(isPresented: $isShowingFrontLibrary, selection: $frontPhotoItem, matching: .images)
        .onChange(of: frontPhotoItem) { _, newValue in
            guard let newItem = newValue else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        viewModel.selectedImageData = data
                    }
                }
                await MainActor.run {
                    frontPhotoItem = nil
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
        Section("写真") {
            VStack(spacing: 16) {
                HStack {
                    Label("ボトル・ラベル写真", systemImage: "camera.viewfinder")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.top, 4)

                // 2カラムの洗練されたフォトカード配置
                HStack(spacing: 12) {
                    // 1. 表面ラベルカード
                    photoCard(
                        title: "表面",
                        subtitle: "メイン写真",
                        imageData: viewModel.selectedImageData,
                        hasImage: viewModel.selectedImageData != nil,
                        action: {
                            isShowingFrontActionDialog = true
                        },
                        onDelete: {
                            viewModel.selectedImageData = nil
                            frontPhotoItem = nil
                        }
                    )

                    // 2. 裏面ラベルカード
                    photoCard(
                        title: "裏面",
                        subtitle: "詳細・スペック",
                        imageData: viewModel.selectedBackImageData,
                        hasImage: viewModel.selectedBackImageData != nil,
                        action: {
                            isShowingBackActionDialog = true
                        },
                        onDelete: {
                            viewModel.selectedBackImageData = nil
                            backPhotoItem = nil
                        }
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }

    /// 縦横の大きさが完全に固定された洗練されたフォトカード
    @ViewBuilder
    private func photoCard(
        title: String,
        subtitle: String,
        imageData: Data?,
        hasImage: Bool,
        action: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) -> some View {
        let cardSize: CGFloat = 140

        VStack(alignment: .center, spacing: 10) {
            ZStack {
                // 固定背景枠（正方形）
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray6))
                    .frame(width: cardSize, height: cardSize)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(.systemGray4).opacity(0.6), lineWidth: 1)
                    )

                if let data = imageData, let uiImage = UIImage(data: data) {
                    // 写真表示（縦横固定・フレーム内でクロップ）
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: cardSize, height: cardSize)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .clipped()

                    // 右上の削除バッジボタン
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: onDelete) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, Color.black.opacity(0.65))
                            }
                            .padding(6)
                        }
                        Spacer()
                    }
                } else {
                    // 未選択時プレースホルダー
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

            // 下部アクションボタン
            Button(action: action) {
                HStack(spacing: 4) {
                    Image(systemName: hasImage ? "ellipsis.circle.fill" : "plus.circle.fill")
                        .font(.caption)
                    Text(hasImage ? "編集・削除" : title)
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
        Section("酒種") {
            Picker("酒種", selection: $viewModel.selectedCategory) {
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
        Section("基本情報") {
            TextField("銘柄名 (必須)", text: $viewModel.name)
                .focused($focusedField, equals: .name)
            
            TextField("生産者 / 蔵元 / ブルワリー", text: $viewModel.producer)
                .focused($focusedField, equals: .producer)

            categorySpecificFields

            TextField("生産地 (例: ボルドー, 新潟、チェコ)", text: $viewModel.region)
                .focused($focusedField, equals: .region)
            
            TextField("ヴィンテージ / 製造年月 (例: 2020)", text: $viewModel.vintage)
                .focused($focusedField, equals: .vintage)
            
            TextField("アルコール度数 (例: 14.5 または 5)", text: $viewModel.abvString)
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .abv)
            
            TextField("価格 (円)", text: $viewModel.priceString)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .price)
        }
    }

    @ViewBuilder
    private var categorySpecificFields: some View {
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
            
            Group {
                ForEach($viewModel.blendComponents) { $component in
                    HStack(spacing: 12) {
                        TextField("品種 (例: カベルネ・ソーヴィニヨン)", text: $component.variety)
                            .focused($focusedField, equals: .extra)
                        
                        TextField("割合", value: $component.percentage, format: .number)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                            .multilineTextAlignment(.trailing)
                        
                        Text("%")
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete(perform: viewModel.removeBlendComponent)

                Button {
                    viewModel.addBlendComponent()
                } label: {
                    Label("品種を追加", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            
            TextField("原産地呼称 (例: AOC ボルドー / DOCG バローロ)", text: $viewModel.appellation)
                .focused($focusedField, equals: .extra)
            
        case .sake:
            Picker("特定名称", selection: $viewModel.sakeSpecificName) {
                Text("純米大吟醸").tag("純米大吟醸")
                Text("純米吟醸").tag("純米吟醸")
                Text("大吟醸").tag("大吟醸")
                Text("特別純米").tag("特別純米")
                Text("純米酒").tag("純米")
                Text("本醸造").tag("本醸造")
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
    }
}

/// 保管場所選択に加え、選択したセラーがグリッド有効な場合に棚番（段・列）を選択できる専用コンポーネント
public struct StoragePickerWithGridMappingView: View {
    @Bindable var viewModel: AddFlowViewModel
    @Query(sort: \StorageLocation.createdAt, order: .forward) private var locations: [StorageLocation]
    @Query private var allItems: [BeverageItem]

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("保管場所", selection: $viewModel.storageLocation) {
                if locations.isEmpty {
                    Text("未設定 (自動作成)").tag("未設定")
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
                        Text("棚・スロット位置の指定 (任意)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    HStack(spacing: 12) {
                        Picker("段 (Row)", selection: Binding(
                            get: { viewModel.selectedGridRow ?? 1 },
                            set: { viewModel.selectedGridRow = $0 }
                        )) {
                            ForEach(1...currentLocation.gridRows, id: \.self) { row in
                                Text("第 \(row) 段").tag(row)
                            }
                        }
                        .pickerStyle(.menu)

                        Picker("列 (Column)", selection: Binding(
                            get: { viewModel.selectedGridColumn ?? 1 },
                            set: { viewModel.selectedGridColumn = $0 }
                        )) {
                            ForEach(1...currentLocation.gridColumns, id: \.self) { col in
                                Text("\(col) 列目").tag(col)
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
                            Label("このスロットにはすでに別のボトルが配置されています", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        } else {
                            Label("このスロットは空いています", systemImage: "checkmark.circle.fill")
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
