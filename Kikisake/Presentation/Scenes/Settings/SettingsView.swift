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
                Section("アプリ設定") {
                    Picker("外観モード", selection: $appState.appearanceMode) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("アプリ情報") {
                    LabeledContent("Version", value: viewModel.appVersion)
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView()
}
