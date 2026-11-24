//
//  SettingsView.swift
//  Kikisake
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

public struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable private var appState = AppState.shared
    @State private var viewModel = SettingsViewModel()

    @State private var showOnboarding: Bool = false
    @State private var showLoadedAlert: Bool = false
    @State private var showPaywall: Bool = false
    @State private var showCustomizationSheet: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var isImporting: Bool = false
    @State private var showShareCardThemeSheet: Bool = false

    private let privacyPolicyURL = URL(
        string: "https://sites.google.com/view/kikisake/%E3%83%97%E3%83%A9%E3%82%A4%E3%83%90%E3%82%B7%E3%83%BC-%E3%83%9D%E3%83%AA%E3%82%B7%E3%83%BC"
    )!

    public var body: some View {
        NavigationStack {
            Form {
                proBannerSection
                appSettingsSection
                dataManagementSection
                appInfoSection

                #if DEBUG
                Section(String(localized: "デバッグ機能")) {
                    Toggle(String(localized: "isProVersion 強制ON/OFF"), isOn: $appState.isProVersion)
                }
                #endif
            }
            .navigationTitle(String(localized: "設定"))
            .navigationBarTitleDisplayMode(.inline)
            .disabled(viewModel.isProcessing)
            .overlay {
                if viewModel.isProcessing {
                    processingOverlay
                }
            }
            .fileExporter(
                isPresented: $viewModel.isExporting,
                document: viewModel.exportDocument,
                contentType: .json,
                defaultFilename: viewModel.exportFileName
            ) { result in
                switch result {
                case .success(let url):
                    viewModel.presentAlert(
                        title: String(localized: "成功"),
                        message: String(format: String(localized: "バックアップを正常に保存しました:\n%@"), url.lastPathComponent)
                    )
                case .failure(let error):
                    viewModel.presentAlert(
                        title: String(localized: "エラー"),
                        message: String(format: String(localized: "ファイルの書き出しに失敗しました: %@"), error.localizedDescription)
                    )
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    viewModel.prepareImport(from: urls)
                case .failure(let error):
                    viewModel.presentAlert(
                        title: String(localized: "エラー"),
                        message: String(format: String(localized: "ファイルの読み込みに失敗しました: %@"), error.localizedDescription)
                    )
                }
            }
            .confirmationDialog(
                String(localized: "データの復元"),
                isPresented: $viewModel.showRestoreConfirmation,
                titleVisibility: .visible
            ) {
                Button(String(localized: "既存データを上書きして復元"), role: .destructive) {
                    Task { await viewModel.restoreBackup(strategy: .replaceAll, modelContext: modelContext) }
                }
                Button(String(localized: "既存データにマージ"), role: .none) {
                    Task { await viewModel.restoreBackup(strategy: .merge, modelContext: modelContext) }
                }
                Button(String(localized: "キャンセル"), role: .cancel) {
                    viewModel.selectedImportURL = nil
                }
            } message: {
                Text(String(localized: "「上書き復元」を選択すると、現在のアプリ内の全データが上書きされます。この操作は取り消せません。"))
            }
            .alert(String(localized: "すべてのデータを削除"), isPresented: $showDeleteConfirmation) {
                Button(String(localized: "削除する"), role: .destructive) {
                    viewModel.deleteAllData(using: modelContext)
                }
                Button(String(localized: "キャンセル"), role: .cancel) {}
            } message: {
                Text(String(localized: "登録したすべての銘柄、テイスティング記録、保管場所が完全に削除されます。この操作は取り消せません。"))
            }
            .sheet(isPresented: $showOnboarding) {
                BoardingView(isPresented: $showOnboarding)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showCustomizationSheet) {
                TastingCustomizationView()
            }
            .sheet(isPresented: $showShareCardThemeSheet) {
                ShareCardThemePickerSheet()
            }
            .alert(String(localized: "サンプルデータの読み込み"), isPresented: $showLoadedAlert) {
                Button(String(localized: "OK"), role: .cancel) {}
            } message: {
                Text(String(localized: "サンプルデータが追加されました。"))
            }
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
                Button(String(localized: "OK"), role: .cancel) {}
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }

    // MARK: - Sections

    private var proBannerSection: some View {
        Section {
            Button {
                showPaywall = true
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(appState.isProVersion ? "Kikisake Pro Active" : "Upgrade to Kikisake Pro")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        Text(
                            appState.isProVersion
                                ? String(localized: "すべての機能が無制限に開放されています")
                                : String(localized: "無制限保管場所 • プロ向けタグ • 広告非表示")
                        )
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.9))
                    }

                    Spacer()

                    if !appState.isProVersion {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
            .listRowBackground(
                LinearGradient(
                    colors: [Color.orange, Color(red: 0.95, green: 0.35, blue: 0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }

    private var appSettingsSection: some View {
        Section(String(localized: "アプリ設定")) {
            Picker(String(localized: "外観モード"), selection: $appState.appearanceMode) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.localizedName).tag(mode)
                }
            }
            .pickerStyle(.menu)

            Button {
                viewModel.openDeviceSettings()
            } label: {
                HStack {
                    Text(String(localized: "言語 / Language"))
                    Spacer()
                    Text(viewModel.currentLanguageDisplayName)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .foregroundStyle(.primary)
            
            Button {
                if appState.isProVersion {
                    showShareCardThemeSheet = true
                } else {
                    showPaywall = true
                }
            } label: {
                HStack {
                    Text(String(localized: "シェアカードテーマ"))
                    Spacer()
                    if appState.isProVersion {
                        Text(appState.effectiveShareCardTheme.displayName)
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    } else {
                        proBadge
                    }
                }
            }
            .foregroundStyle(.primary)

            Button {
                if appState.isProVersion {
                    showCustomizationSheet = true
                } else {
                    showPaywall = true
                }
            } label: {
                HStack {
                    Text(String(localized: "テイスティング選択肢のカスタマイズ"))
                    Spacer()
                    if !appState.isProVersion {
                        proBadge
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .foregroundStyle(.primary)
        }
    }

    private var dataManagementSection: some View {
        Section(String(localized: "データ管理・バックアップ")) {
            Button(String(localized: "使い方ガイドを見る")) {
                showOnboarding = true
            }

            Button(String(localized: "サンプルデータを読み込む")) {
                PreviewSampleLoader.insertSamples(into: modelContext)
                showLoadedAlert = true
            }

            Button(String(localized: "バックアップを作成する (JSON)")) {
                Task { await viewModel.exportBackup(modelContext: modelContext) }
            }

            Button(String(localized: "データを復元する")) {
                isImporting = true
            }

            Button(String(localized: "すべてのデータを削除する"), role: .destructive) {
                showDeleteConfirmation = true
            }
        }
    }

    private var appInfoSection: some View {
        Section(String(localized: "アプリ情報")) {
            LabeledContent(String(localized: "バージョン"), value: viewModel.appVersion)

            Link(destination: privacyPolicyURL) {
                HStack {
                    Text(String(localized: "プライバシーポリシー"))
                    Spacer()
                    Image(systemName: "safari")
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.primary)
        }
    }

    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                    .controlSize(.large)
                    .tint(.white)
                Text(String(localized: "処理中..."))
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(24)
            .background(Color(.darkGray))
            .cornerRadius(16)
        }
    }

    private var proBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "lock.fill")
                .font(.system(size: 9, weight: .bold))
            Text("PRO")
                .font(.system(size: 10, weight: .black))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 7)
        .padding(.vertical, 3.5)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.orange, Color(red: 0.95, green: 0.35, blue: 0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }
}

// Pro版向けシェアカードテーマ選択シート
private struct ShareCardThemePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var appState = AppState.shared

    var body: some View {
        NavigationStack {
            List {
                ForEach(ShareCardTheme.allCases) { theme in
                    Button {
                        appState.shareCardTheme = theme
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(theme.displayName)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                Text(theme.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if appState.shareCardTheme == theme {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle(String(localized: "シェアカードテーマ"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "完了")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [BeverageItem.self, TastingLog.self, StorageLocation.self], inMemory: true)
}
