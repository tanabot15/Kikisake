//  SettingsView.swift
//  Kikisake

import SwiftUI
import SwiftData

/// [Tab 5] 設定画面
public struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable private var appState = AppState.shared
    @State private var viewModel = SettingsViewModel()
    
    // オンボーディング再表示用およびアラート用の状態
    @State private var showOnboarding: Bool = false
    @State private var showLoadedAlert: Bool = false

    public var body: some View {
        NavigationStack {
            Form {
                // MARK: - 1. アプリ設定
                Section("アプリ設定") {
                    Picker("外観モード", selection: $appState.appearanceMode) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
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

                // MARK: - 2. データ・管理
                Section("データ管理") {
                    Button {
                        showOnboarding = true
                    } label: {
                        Text("使い方ガイドを見る")
                    }

                    Button {
                        PreviewSampleLoader.insertSamples(into: modelContext)
                        showLoadedAlert = true
                    } label: {
                        Text("サンプルデータを読み込み")
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
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showOnboarding) {
                BoardingView(isPresented: $showOnboarding)
            }
            .alert("サンプルデータの読み込み", isPresented: $showLoadedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("サンプルデータと必要な保管場所が追加されました。")
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [BeverageItem.self, TastingLog.self, StorageLocation.self], inMemory: true)
}
