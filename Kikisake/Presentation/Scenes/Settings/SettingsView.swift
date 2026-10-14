//
//  SettingsView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI

/// [Tab 5] 設定画面
public struct SettingsView: View {
    @Bindable private var appState = AppState.shared
    @State private var viewModel = SettingsViewModel()

    public var body: some View {
        NavigationStack {
            Form {
                Section("プロプラン (将来の拡張用)") {
                    Toggle("Pro バージョン機能 (制限解除)", isOn: $appState.isProVersion)
                    Text(appState.isProVersion ? "Proプラン適用中（無制限ログ・広告非表示）" : "フリープラン（ログ最大30件まで）")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("アプリケーション情報") {
                    LabeledContent("バージョン", value: viewModel.appVersion)
                }

                Section("サポート・フィードバック") {
                    Link("アプリの評価・要望を送る", destination: URL(string: "https://apple.com")!)
                    Link("開発者サポート (note / X)", destination: URL(string: "https://note.com")!)
                }
            }
            .navigationTitle("設定")
        }
    }
}

#Preview {
    SettingsView()
}
