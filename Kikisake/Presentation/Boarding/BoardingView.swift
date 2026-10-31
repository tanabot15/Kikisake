//  BoardingView.swift
//  Kikisake

import SwiftUI
import SwiftData

/// スライド用データモデル
private struct BoardingSlide: Identifiable {
    let id: Int
    let icon: String
    let iconGradient: [Color]
    let title: String
    let subtitle: String
    let description: String
}

/// アプリを初めて起動したユーザー向けのご案内（オンボーディング）画面
public struct BoardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding public var isPresented: Bool
    @State private var currentSlideTab: Int = 0
    
    // 💡 サンプルデータ追加用のトグル状態（デフォルトはOFF）
    @State private var shouldLoadSampleData: Bool = false

    /// スライド定義（全5枚構成）
    private let slides: [BoardingSlide] = [
        BoardingSlide(
            id: 0,
            icon: "wineglass.fill",
            iconGradient: [Color.accentColor, Color.purple],
            title: String(localized: "Kikisakeへようこそ"),
            subtitle: String(localized: "愛好家のためのプロフェッショナル向け記録アプリ"),
            description: String(localized: "ワイン・日本酒・ビールなどのテイスティングと在庫セラーをこれ一つで美しく管理")
        ),
        BoardingSlide(
            id: 1,
            icon: "waveform.path.ecg.text.clipboard",
            iconGradient: [Color.red, Color.orange],
            title: String(localized: "本格的なテイスティング記録"),
            subtitle: String(localized: "Log - 印象的な味わいをそのまま残す"),
            description: String(localized: "外観の色調、複雑な香り、味わいからタンニン・ボディ・余韻まで、直感的なUIで詳細にアプローチ")
        ),
        BoardingSlide(
            id: 2,
            icon: "chart.pie.fill",
            iconGradient: [Color.blue, Color.cyan],
            title: String(localized: "味わいの傾向を可視化"),
            subtitle: String(localized: "Analytics - 自らの「味覚の好み」を深く知る"),
            description: String(localized: "レーダーチャートや2軸マトリクスにより、蓄積されたログからあなた自身の好みやよく飲むジャンルを鮮やかにグラフ化")
        ),
        BoardingSlide(
            id: 3,
            icon: "cabinet.fill",
            iconGradient: [Color.green, Color.teal],
            title: String(localized: "スマート在庫管理"),
            subtitle: String(localized: "Inventory - 自宅のセラーや冷蔵庫をマップ化"),
            description: String(localized: "ワインセラーや冷蔵庫の位置をグラフィカルに再現し、保管場所ごとの在庫を一目で把握し、スムーズに開栓記録へ")
        )
    ]

    private var lastSlideIndex: Int {
        slides.count // 4番目のインデックスがサンプルデータ選択ページ
    }

    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - トップバー（左: 戻るボタン, 右: スキップボタン）
            HStack {
                // 💡 左上：1番目のスライドより後であれば「戻る」ボタンを表示
                if currentSlideTab > 0 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            currentSlideTab -= 1
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(String(localized: "戻る"))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.secondary)
                    }
                } else {
                    Spacer().frame(width: 60)
                }

                Spacer()

                // 右上：スキップボタン
                Button {
                    finishOnboarding()
                } label: {
                    Text(String(localized: "スキップ"))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .frame(height: 44)

            // MARK: - メイン・スライド（TabView）
            TabView(selection: $currentSlideTab) {
                // 0〜3番目の通常ガイドスライド
                ForEach(slides) { slide in
                    VStack(spacing: 24) {
                        Spacer()

                        // リッチなグラデーション背景アイコン
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: slide.iconGradient.map { $0.opacity(0.18) },
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: slide.icon)
                                .font(.system(size: 54))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: slide.iconGradient,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: slide.iconGradient.first?.opacity(0.3) ?? .clear, radius: 8, x: 0, y: 4)
                        }
                        .padding(.bottom, 8)

                        // 見出し ＆ サブタイトル
                        VStack(spacing: 8) {
                            Text(slide.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.primary)

                            Text(slide.subtitle)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        // 説明文カード
                        Text(slide.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 16)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(16)
                            .padding(.horizontal, 16)

                        Spacer()
                    }
                    .tag(slide.id)
                }

                // 💡 最終スライド：サンプルデータ読み込み確認ページ
                VStack(spacing: 24) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.18), Color.yellow.opacity(0.18)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "square.and.arrow.down.on.square.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.bottom, 8)

                    VStack(spacing: 8) {
                        Text(String(localized: "準備が整いました"))
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)

                        Text(String(localized: "サンプルデータの自動追加"))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accentColor)
                            .multilineTextAlignment(.center)
                    }

                    // サンプルデータ読み込みトグルカード
                    VStack(spacing: 16) {
                        Text(String(localized: "ワイン、日本酒、ビールのサンプルデータをあらかじめ追加して、アプリの機能をすぐにお試しいただけます。"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)

                        Divider()

                        Toggle(isOn: $shouldLoadSampleData) {
                            HStack(spacing: 12) {
                                Image(systemName: "shippingbox.fill")
                                    .font(.headline)
                                    .foregroundStyle(Color.accentColor)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(localized: "サンプルデータを追加する"))
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    Text(String(localized: "ワイン2本・日本酒2本・ビール1本"))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .tint(.accentColor)
                    }
                    .padding(20)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal, 16)

                    Spacer()
                }
                .tag(lastSlideIndex)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // MARK: - ボトムナビゲーション ＆ アクションエリア
            VStack(spacing: 16) {
                // カスタム・ページインジケータ (全5ドット)
                HStack(spacing: 8) {
                    ForEach(0...lastSlideIndex, id: \.self) { index in
                        Capsule()
                            .fill(currentSlideTab == index ? Color.accentColor : Color(.systemGray4))
                            .frame(width: currentSlideTab == index ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentSlideTab)
                    }
                }
                .padding(.bottom, 8)

                // 進む / はじめる ボタン
                Button {
                    if currentSlideTab < lastSlideIndex {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            currentSlideTab += 1
                        }
                    } else {
                        finishOnboarding()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(currentSlideTab == lastSlideIndex ? String(localized: "さっそくはじめる") : String(localized: "次へ"))
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        if currentSlideTab < lastSlideIndex {
                            Image(systemName: "arrow.right")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color.accentColor, Color.accentColor.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    /// オンボーディング終了ハンドラ
    private func finishOnboarding() {
        if shouldLoadSampleData {
            PreviewSampleLoader.insertSamples(into: modelContext)
        }
        isPresented = false
    }
}

#Preview {
    BoardingView(isPresented: .constant(true))
        .modelContainer(for: [BeverageItem.self, TastingLog.self, StorageLocation.self], inMemory: true)
}
