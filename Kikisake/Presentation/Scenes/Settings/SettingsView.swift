//  SettingsView.swift
//  Kikisake

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

    // MARK: - データ削除確認用 State
    @State private var showDeleteConfirmation: Bool = false

    // MARK: - バックアップ/リストア用 State
    @State private var isExporting: Bool = false
    @State private var exportDocument: BackupFileDocument? = nil
    @State private var exportFileName: String = ""

    @State private var isImporting: Bool = false
    @State private var showRestoreConfirmation: Bool = false
    @State private var selectedImportURL: URL? = nil

    @State private var isProcessing: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false

    public var body: some View {
        NavigationStack {
            Form {
                // MARK: - 0. Kikisake Pro 案内カード
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

                                Text(appState.isProVersion ? "すべての機能が無制限に開放されています" : "無制限保管場所 • プロ向けタグ • 広告非表示")
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

                // MARK: - 1. アプリ設定
                Section("アプリ設定") {
                    Picker("外観モード", selection: $appState.appearanceMode) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.localizedName).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Button {
                        viewModel.openDeviceSettings()
                    } label: {
                        HStack {
                            Text("言語 / Language")
                            Spacer()
                            Text(viewModel.currentLanguageDisplayName)
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)
                }

                // MARK: - 2. データ・バックアップ管理
                Section("データ管理・バックアップ") {
                    Button {
                        showOnboarding = true
                    } label: {
                        Text("使い方ガイドを見る")
                    }

                    Button {
                        PreviewSampleLoader.insertSamples(into: modelContext)
                        showLoadedAlert = true
                    } label: {
                        Text("サンプルデータを読み込む")
                    }

                    // バックアップ（エクスポート）ボタン
                    Button {
                        handleExport()
                    } label: {
                        Text("バックアップを作成する (JSON)")
                    }

                    // リストア（インポート）ボタン
                    Button {
                        isImporting = true
                    } label: {
                        Text("データを復元する")
                    }

                    // すべてのデータを削除するボタン
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Text("すべてのデータを削除する")
                    }
                }

                // MARK: - 3. アプリ情報
                Section("アプリ情報") {
                    LabeledContent("バージョン", value: viewModel.appVersion)
                    
                    Link(destination: URL(string: "https://sites.google.com/view/kikisake/%E3%83%97%E3%83%A9%E3%82%A4%E3%83%90%E3%82%B7%E3%83%BC-%E3%83%9D%E3%83%AA%E3%82%B7%E3%83%BC")!) {
                        HStack {
                            Text("プライバシーポリシー")
                            Spacer()
                            Image(systemName: "safari")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                }

                // MARK: - 4. デバッグ用（Preview・テスト用）
                #if DEBUG
                Section(header: Text("デバッグ機能")) {
                    Toggle("isProVersion 強制ON/OFF", isOn: $appState.isProVersion)
                }
                #endif
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .disabled(isProcessing)
            .overlay {
                if isProcessing {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        VStack(spacing: 12) {
                            ProgressView()
                                .controlSize(.large)
                                .tint(.white)
                            Text("処理中...")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        .padding(24)
                        .background(Color(.darkGray))
                        .cornerRadius(16)
                    }
                }
            }
            .fileExporter(
                isPresented: $isExporting,
                document: exportDocument,
                contentType: .json,
                defaultFilename: exportFileName
            ) { result in
                switch result {
                case .success(let url):
                    presentAlert(title: "成功", message: "バックアップを正常に保存しました:\n\(url.lastPathComponent)")
                case .failure(let error):
                    presentAlert(title: "エラー", message: "ファイルの書き出しに失敗しました: \(error.localizedDescription)")
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    selectedImportURL = url
                    showRestoreConfirmation = true
                case .failure(let error):
                    presentAlert(title: "エラー", message: "ファイルの読み込みに失敗しました: \(error.localizedDescription)")
                }
            }
            .confirmationDialog(
                "データの復元",
                isPresented: $showRestoreConfirmation,
                titleVisibility: .visible
            ) {
                Button("既存データを上書きして復元", role: .destructive) {
                    executeRestore(strategy: .replaceAll)
                }
                Button("既存データにマージ", role: .none) {
                    executeRestore(strategy: .merge)
                }
                Button("キャンセル", role: .cancel) {
                    selectedImportURL = nil
                }
            } message: {
                Text("「上書き復元」を選択すると、現在のアプリ内の全データが上書きされます。この操作は取り消せません。")
            }
            // 💡 すべてのデータ削除を確認するアラート（ポップアップ）
            .alert("すべてのデータを削除", isPresented: $showDeleteConfirmation) {
                Button("削除する", role: .destructive) {
                    viewModel.deleteAllData(using: modelContext)
                    presentAlert(title: "完了", message: "すべてのデータが削除されました。")
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("登録したすべての銘柄、テイスティング記録、保管場所が完全に削除されます。この操作は取り消せません。")
            }
            .sheet(isPresented: $showOnboarding) {
                BoardingView(isPresented: $showOnboarding)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .alert("サンプルデータの読み込み", isPresented: $showLoadedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("サンプルデータが追加されました。")
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Action Handlers

    private func handleExport() {
        isProcessing = true
        Task {
            do {
                let data = try BackupManager.shared.exportData(modelContext: modelContext)
                exportDocument = BackupFileDocument(payloadData: data)
                exportFileName = BackupManager.shared.generateBackupFileName()
                isProcessing = false
                isExporting = true
            } catch {
                isProcessing = false
                presentAlert(title: "エクスポート失敗", message: error.localizedDescription)
            }
        }
    }

    private func executeRestore(strategy: RestoreStrategy) {
        guard let url = selectedImportURL else { return }
        isProcessing = true

        Task {
            do {
                // セキュリティスコープアクセスの取得（Filesアプリ等の安全なパーミッション処理）
                guard url.startAccessingSecurityScopedResource() else {
                    throw BackupError.importFailed("ファイルアクセスの権限が取得できませんでした。")
                }
                defer { url.stopAccessingSecurityScopedResource() }

                let data = try Data(contentsOf: url)
                try BackupManager.shared.importData(from: data, strategy: strategy, modelContext: modelContext)

                isProcessing = false
                selectedImportURL = nil
                presentAlert(title: "復元完了", message: "バックアップからの復元が正常に完了しました。")
            } catch {
                isProcessing = false
                selectedImportURL = nil
                presentAlert(title: "リストア失敗", message: error.localizedDescription)
            }
        }
    }

    private func presentAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [BeverageItem.self, TastingLog.self, StorageLocation.self], inMemory: true)
}
