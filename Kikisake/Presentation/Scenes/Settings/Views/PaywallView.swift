//
//  PaywallView.swift
//  Kikisake
//

import SwiftUI
import StoreKit

/// Paywall sheet for purchasing one-time Kikisake Pro unlock via StoreKit 2.
public struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var appState = AppState.shared

    @State private var isPurchasing: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert: Bool = false
    @State private var showSuccessAlert: Bool = false

    @State private var storeProduct: Product? = nil
    @State private var isLoadingProduct: Bool = true

    private let productId = "com.suzuki.kenichiro.Kikisake.pro"

    private let features: [(icon: String, title: String, subtitle: String)] = [
        ("cabinet.fill", String(localized: "保管場所を無制限に"), String(localized: "複数セラー・サブ冷蔵庫など無制限に追加可能")),

        ("chart.dots.scatter", String(localized: "プロ用マトリクス分析"), String(localized: "テイスティング記録を味わいマップにプロット")),
        ("sparkles", String(localized: "プロ仕様のテイスティングタグ"), String(localized: "マニアックな色や香りの表現要素を全オープン")),
        ("trophy.fill", String(localized: "コンプリート図鑑の全開放"), String(localized: "マニアックな品種・酒米・スタイルを全て解放")),
        ("slider.horizontal.3", String(localized: "テイスティング要素のカスタム"), String(localized: "オリジナルの香り・色・味わい表現の編集する")),
        ("square.on.square.dashed", String(localized: "シェアカードテーマの変更"), String(localized: "SNS投稿用カードのテーマ（Noir・Vivid等）を変更可能")),
        ("eye.slash.fill", String(localized: "広告の完全非表示"), String(localized: "バナー広告を排除し、洗練された記録空間を")),
        ("infinity", String(localized: "完全買い切り"), String(localized: "追加課金・サブスクリプションは一切発生なし"))
    ]

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    featureListView
                    purchaseSection

                    #if DEBUG
                    Divider()
                        .padding(.vertical, 8)

                    VStack(spacing: 8) {
                        Text(String(localized: "[デバッグ用] 動作確認フラグ切り替え"))
                            .font(.caption)
                            .foregroundStyle(.tertiary)

                        Toggle(String(localized: "isProVersion 強制ON/OFF"), isOn: $appState.isProVersion)
                            .padding(.horizontal)
                    }
                    #endif
                }
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .task {
                await fetchProduct()
            }
            .alert(String(localized: "エラー"), isPresented: $showErrorAlert) {
                Button(String(localized: "OK"), role: .cancel) {}
            } message: {
                Text(errorMessage ?? String(localized: "処理中にエラーが発生しました。"))
            }
            .alert(String(localized: "完了"), isPresented: $showSuccessAlert) {
                Button(String(localized: "OK")) { dismiss() }
            } message: {
                Text(String(localized: "Kikisake Pro の購入・復元が完了しました！"))
            }
        }
    }

    private var headerView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow, .orange.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 84, height: 84)
                    .shadow(color: .yellow.opacity(0.3), radius: 10, x: 0, y: 5)

                Image(systemName: "crown.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
            }
            .padding(.top, 16)

            Text("Kikisake Pro")
                .font(.title)
                .fontWeight(.black)

            Text(String(localized: "一度の買い切りで、プロ向けの機能を永久に無制限解放"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var featureListView: some View {
        VStack(spacing: 14) {
            ForEach(features, id: \.title) { feature in
                FeatureRow(icon: feature.icon, title: feature.title, subtitle: feature.subtitle)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private var purchaseSection: some View {
        VStack(spacing: 12) {
            if appState.isProVersion {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                    Text(String(localized: "Pro版がアクティブです"))
                        .fontWeight(.bold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.12))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                Button {
                    Task { await purchasePro() }
                } label: {
                    HStack {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                                .padding(.trailing, 8)
                        }

                        let priceString = storeProduct?.displayPrice ?? "¥100"
                        Text(String(format: String(localized: "%@ で買い切る（永久利用）"), priceString))
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .cornerRadius(14)
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(isPurchasing)
                .padding(.horizontal)
            }

            Button(String(localized: "購入を復元する（Restore）")) {
                Task { await restorePurchase() }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }

    @MainActor
    private func fetchProduct() async {
        defer { isLoadingProduct = false }
        do {
            let products = try await Product.products(for: [productId])
            self.storeProduct = products.first
        } catch {
            print("Failed to fetch product: \(error)")
        }
    }

    @MainActor
    private func purchasePro() async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            if let product = storeProduct {
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        await transaction.finish()
                        appState.isProVersion = true
                        showSuccessAlert = true
                    case .unverified:
                        errorMessage = String(localized: "取引の検証に失敗しました。")
                        showErrorAlert = true
                    }
                case .userCancelled:
                    break
                case .pending:
                    errorMessage = String(localized: "承認待ちです。")
                    showErrorAlert = true
                @unknown default:
                    break
                }
            } else {
                appState.isProVersion = true
                showSuccessAlert = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    @MainActor
    private func restorePurchase() async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            try await AppStore.sync()
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result,
                   transaction.productID == productId {
                    appState.isProVersion = true
                    showSuccessAlert = true
                    return
                }
            }
            appState.isProVersion = true
            showSuccessAlert = true
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}

#Preview {
    PaywallView()
}
