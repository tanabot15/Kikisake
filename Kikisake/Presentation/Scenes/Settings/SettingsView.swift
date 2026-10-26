//  SettingsView.swift
//  Kikisake

import SwiftUI
import SwiftData

/// [Tab 5] 設定画面
public struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable private var appState = AppState.shared
    @State private var viewModel = SettingsViewModel()
    
    @State private var showOnboarding: Bool = false
    @State private var showLoadedAlert: Bool = false
    @State private var showPaywall: Bool = false

    public var body: some View {
        NavigationStack {
            Form {
                // MARK: - 0. Kikisake Pro 案内カード（リッチなグラデーション仕様）
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

                // MARK: - 4. デバッグ用（Preview・テスト用）
                #if DEBUG
                Section(header: Text("デバッグ機能")) {
                    Toggle("isProVersion 強制ON/OFF", isOn: $appState.isProVersion)
                }
                #endif
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
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
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [BeverageItem.self, TastingLog.self, StorageLocation.self], inMemory: true)
}
