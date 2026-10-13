//
//  KikisakeApp.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI
import SwiftData

/// アプリケーションのエントリーポイント
@main
struct KikisakeApp: App {
    private let modelContainerManager = ModelContainerManager.shared

    public var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainerManager.container)
        }
    }
}

/// プレビュー用の暫定ルートビュー（Phase 4でMainTabViewに置き換わります）
private struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "wineglass")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.accentColor)
                
                Text("Kikisake")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("本格派テイスティング＆セラーマネジメント")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("ホーム")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [BeverageItem.self, TastingLog.self], inMemory: true)
}
