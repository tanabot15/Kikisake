//
//  GeneralInfoStepView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/15.
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

/// [Step 1] 一般的な情報（酒種・基本情報）入力ビュー
public struct GeneralInfoStepView: View {
    @Bindable var viewModel: AddFlowViewModel
    @FocusState.Binding var focusedField: GeneralInfoField?
    var showAlert: (String) -> Void
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var isShowingCamera: Bool = false
    @State private var isShowingPhotoSourceOptions: Bool = false
    @State private var isShowingPhotosPicker: Bool = false

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
            Section("ラベル写真") {
                HStack(spacing: 16) {
                    if let imageData = viewModel.selectedImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.systemGray4), lineWidth: 1))
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                            .frame(width: 80, height: 80)
                            .overlay {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("ボトルのラベル写真を登録できます。")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Button {
                            isShowingPhotoSourceOptions = true
                        } label: {
                            Label(viewModel.selectedImageData == nil ? "写真を追加する" : "写真を変更する", systemImage: "photo.badge.plus")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                        
                        if viewModel.selectedImageData != nil {
                            Button("写真を削除", role: .destructive) {
                                viewModel.selectedImageData = nil
                                selectedPhotoItem = nil
                            }
                            .font(.caption)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
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
                    
                    Section("ブドウ品種") {
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
                
                TextField("登録本数 (本)", text: $viewModel.stockQuantityString)
                    .keyboardType(.numberPad)
            }
        }
        .confirmationDialog("写真の追加方法を選択", isPresented: $isShowingPhotoSourceOptions, titleVisibility: .visible) {
            Button("写真を撮る") {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    isShowingCamera = true
                } else {
                    showAlert("このデバイスではカメラを利用できません。")
                }
            }
            Button("ライブラリから選ぶ") {
                isShowingPhotosPicker = true
            }
            Button("キャンセル", role: .cancel) {}
        }
        .sheet(isPresented: $isShowingCamera) {
            ImagePickerView(sourceType: .camera) { image in
                if let data = image.jpegData(compressionQuality: 0.8) {
                    viewModel.selectedImageData = data
                }
            }
        }
        .photosPicker(
            isPresented: $isShowingPhotosPicker,
            selection: $selectedPhotoItem,
            matching: .images
        )
        .onChange(of: selectedPhotoItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    viewModel.selectedImageData = data
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

/// データベースから動的に保管場所を選ぶPickerビュー
public struct StoragePickerView: View {
    @Bindable var viewModel: AddFlowViewModel
    @Query(sort: \StorageLocation.createdAt, order: .forward) private var locations: [StorageLocation]

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Picker("保管場所", selection: $viewModel.storageLocation) {
            if locations.isEmpty {
                Text("未設定 (自動作成)").tag("未設定")
            } else {
                ForEach(locations, id: \.name) { loc in
                    Text(loc.name).tag(loc.name)
                }
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: StorageLocation.self, BeverageItem.self, TastingLog.self, configurations: config)
    
    // プレビュー用にデフォルトの保管場所をいくつか挿入
    container.mainContext.insert(StorageLocation(name: "ワインセラー", type: .cellar))
    container.mainContext.insert(StorageLocation(name: "冷蔵庫", type: .refrigerator))

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
        .modelContainer(container)
}
