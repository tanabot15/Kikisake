//
//  AdMobBannerView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/21.
//

import SwiftUI
import GoogleMobileAds

public struct AdMobBannerView: UIViewRepresentable {
    // テスト用の広告ユニットID（本番リリース時はご自身のAdMobユニットIDに差し替えてください）
    private let adUnitID: String = "ca-app-pub-3940256099942544/2934735716"

    public init() {}

    public func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        
        // RootViewControllerの取得
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootViewController
        }
        
        bannerView.load(Request())
        return bannerView
    }

    public func updateUIView(_ uiView: BannerView, context: Context) {
        // 更新時の処理が必要な場合はここに記述
    }
}

#Preview {
    AdMobBannerView()
}
