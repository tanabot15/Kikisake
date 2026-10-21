//
//  KikisakeApp.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI
import SwiftData
import GoogleMobileAds
import AppTrackingTransparency

/// アプリケーションのエントリーポイント
@main
struct KikisakeApp: App {
    private let modelContainerManager = ModelContainerManager.shared
    @Bindable private var appState = AppState.shared

    init() {
        // Google Mobile Ads SDK の初期化
        MobileAds.shared.start(completionHandler: nil)

        // デバッグビルド（シミュレータ等）の起動時にサンプルデータを自動挿入
        PreviewSampleLoader.insertSamplesIfNeeded(into: modelContainerManager.container.mainContext)
    }

    public var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(modelContainerManager.container)
                .preferredColorScheme(appState.appearanceMode.colorScheme)
                // 初回起動時のみボードビュー（オンボーディング）をシート表示
                .sheet(isPresented: Binding(
                    get: { !appState.hasCompletedOnboarding },
                    set: { appState.hasCompletedOnboarding = !$0 }
                )) {
                    BoardingView(isPresented: Binding(
                        get: { !appState.hasCompletedOnboarding },
                        set: { appState.hasCompletedOnboarding = !$0 }
                    ))
                    .interactiveDismissDisabled(true) // 途中でスワイプして閉じられないように固定
                }
                .task {
                    requestTrackingPermission()
                }
        }
    }

    /// ATT（トラッキング許可）のポップアップを要求するメソッド
    private func requestTrackingPermission() {
        // 少し遅延を入れて、画面表示やオンボーディングが落ち着いた後にポップアップを出すとスムーズです
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("ユーザーがトラッキングを許可しました。")
                case .denied:
                    print("ユーザーがトラッキングを拒否しました。")
                case .restricted:
                    print("トラッキングが制限されています。")
                case .notDetermined:
                    print("まだトラッキングの選択がされていません。")
                @unknown default:
                    break
                }
            }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [BeverageItem.self, TastingLog.self], inMemory: true)
}
