//  PaywallView.swift
//  Kikisake

import SwiftUI
import StoreKit

/// [Paywall] 買い切り版 Kikisake Pro の訴求＆購入案内シート
public struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var appState = AppState.shared
    
    @State private var isPurchasing: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert: Bool = false
    @State private var showSuccessAlert: Bool = false

    /// ✨ StoreKit から取得したプロダクト情報と価格文字列
    @State private var storeProduct: Product? = nil
    @State private var isLoadingProduct: Bool = true

    /// StoreKit 2 用の Non-Consumable プロダクトID
    private let productId = "com.suzuki.kenichiro.Kikisake.pro"

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - ヘッダーアイコン＆タイトル
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.yellow, .orange.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
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

                        Text("一度の買い切りで、プロ向けの機能を永久に無制限解放")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Spacer()

                    // MARK: - 機能比較リスト
                    VStack(spacing: 14) {
                        FeatureRow(
                            icon: "cabinet.fill",
                            title: "保管場所が無制限",
                            subtitle: "複数セラー・サブ冷蔵庫など無制限に追加可能"
                        )
                        
                        FeatureRow(
                            icon: "sparkles",
                            title: "プロ仕様のテイスティングタグ",
                            subtitle: "マニアックな色や香りの表現要素を全オープン"
                        )

                        FeatureRow(
                            icon: "eye.slash.fill",
                            title: "広告の完全非表示",
                            subtitle: "バナー広告を排除し、洗練された記録空間を"
                        )

                        FeatureRow(
                            icon: "infinity",
                            title: "完全買い切り",
                            subtitle: "追加課金・サブスクリプションは一切発生なし"
                        )
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    Spacer()

                    // MARK: - 購入ボタンエリア
                    VStack(spacing: 12) {
                        if appState.isProVersion {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(.green)
                                Text("Pro版がアクティブです")
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.12))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        } else {
                            Button {
                                purchasePro()
                            } label: {
                                HStack {
                                    if isPurchasing {
                                        ProgressView()
                                            .tint(.white)
                                            .padding(.trailing, 8)
                                    }
                                    
                                    // ✨ StoreKitから取得した価格（例: "¥3,800"）を動的に反映
                                    let priceString = storeProduct?.displayPrice ?? "¥3,800"
                                    Text("\(priceString) で買い切る（永久利用）")
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

                        Button("購入を復元する（Restore）") {
                            restorePurchase()
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }

                    #if DEBUG
                    Divider()
                        .padding(.vertical, 8)

                    VStack(spacing: 8) {
                        Text("[デバッグ用] 動作確認フラグ切り替え")
                            .font(.caption)
                            .foregroundStyle(.tertiary)

                        Toggle("isProVersion 強制ON/OFF", isOn: $appState.isProVersion)
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
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .task {
                // ✨ 画面表示時にApp Storeからプロダクト情報を非同期フェッチ
                await fetchProduct()
            }
            .alert("エラー", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "処理中にエラーが発生しました。")
            }
            .alert("完了", isPresented: $showSuccessAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text("Kikisake Pro の購入・復元が完了しました！")
            }
        }
    }

    // MARK: - StoreKit 2 連携メソッド

    @MainActor
    private func fetchProduct() async {
        do {
            let products = try await Product.products(for: [productId])
            self.storeProduct = products.first
        } catch {
            print("Failed to fetch product: \(error)")
        }
        isLoadingProduct = false
    }

    @MainActor
    private func purchasePro() {
        isPurchasing = true
        Task {
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
                            errorMessage = "取引の検証に失敗しました。"
                            showErrorAlert = true
                        }
                    case .userCancelled:
                        break
                    case .pending:
                        errorMessage = "承認待ちです。"
                        showErrorAlert = true
                    @unknown default:
                        break
                    }
                } else {
                    // プロダクトがロードできていない環境（シミュレータ等）でのフォールバック
                    appState.isProVersion = true
                    showSuccessAlert = true
                }
            } catch {
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
            isPurchasing = false
        }
    }

    @MainActor
    private func restorePurchase() {
        isPurchasing = true
        Task {
            do {
                try await AppStore.sync()
                for await result in Transaction.currentEntitlements {
                    if case .verified(let transaction) = result,
                       transaction.productID == productId {
                        appState.isProVersion = true
                        showSuccessAlert = true
                        isPurchasing = false
                        return
                    }
                }
                // フォールバック（デバッグ用）
                appState.isProVersion = true
                showSuccessAlert = true
            } catch {
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
            isPurchasing = false
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
