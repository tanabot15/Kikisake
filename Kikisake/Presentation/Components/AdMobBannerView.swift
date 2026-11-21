//
//  AdMobBannerView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/21.
//

import SwiftUI
import GoogleMobileAds

public struct AdMobBannerView: UIViewRepresentable {
    private static let testBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    private let adUnitID: String

    public init() {
        if let path = Bundle.main.path(forResource: "AdMobConfig", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let id = dict["AdUnitID"] as? String,
           !id.isEmpty {
            self.adUnitID = id
        } else {
            self.adUnitID = Self.testBannerAdUnitID
        }
    }

    public func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootViewController
        }

        bannerView.load(Request())
        return bannerView
    }

    public func updateUIView(_ uiView: BannerView, context: Context) {}
}

/// シミュレータでは非表示にし、実機（リリース等）でのみバナー広告を表示するラッパービュー
public struct ConditionalAdMobBannerView: View {
    public init() {}

    public var body: some View {
        #if targetEnvironment(simulator)
        EmptyView()
        #else
        AdMobBannerView()
            .frame(height: 50)
            .background(Color(.systemBackground))
        #endif
    }
}

#Preview {
    ConditionalAdMobBannerView()
}
