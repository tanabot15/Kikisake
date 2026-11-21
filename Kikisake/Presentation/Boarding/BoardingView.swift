//
//  BoardingView.swift
//  Kikisake
//

import SwiftUI
import SwiftData

private struct BoardingSlide: Identifiable {
    let id: Int
    let icon: String
    let iconGradient: [Color]
    let title: String
    let subtitle: String
    let description: String
}

/// First-launch onboarding guide view for Kikisake.
public struct BoardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding public var isPresented: Bool

    @State private var currentSlideTab: Int = 0
    @State private var shouldLoadSampleData: Bool = false

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
        slides.count
    }

    public var body: some View {
        VStack(spacing: 0) {
            topBarView

            TabView(selection: $currentSlideTab) {
                ForEach(slides) { slide in
                    guideSlideView(slide)
                        .tag(slide.id)
                }

                sampleDataSlideView
                    .tag(lastSlideIndex)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            bottomNavigationView
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    // MARK: - Subviews

    private var topBarView: some View {
        HStack {
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

            Button(String(localized: "スキップ")) {
                finishOnboarding()
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .frame(height: 44)
    }

    private func guideSlideView(_ slide: BoardingSlide) -> some View {
        VStack(spacing: 24) {
            Spacer()

            gradientBadgeIcon(
                systemName: slide.icon,
                colors: slide.iconGradient,
                iconSize: 54,
                shadowColor: slide.iconGradient.first?.opacity(0.3) ?? .clear
            )

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
    }

    private var sampleDataSlideView: some View {
        VStack(spacing: 24) {
            Spacer()

            gradientBadgeIcon(
                systemName: "square.and.arrow.down.on.square.fill",
                colors: [.orange, .yellow],
                iconSize: 50,
                shadowColor: Color.orange.opacity(0.3)
            )

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
    }

    private func gradientBadgeIcon(
        systemName: String,
        colors: [Color],
        iconSize: CGFloat,
        shadowColor: Color
    ) -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: colors.map { $0.opacity(0.18) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)

            Image(systemName: systemName)
                .font(.system(size: iconSize))
                .foregroundStyle(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: shadowColor, radius: 8, x: 0, y: 4)
        }
        .padding(.bottom, 8)
    }

    private var bottomNavigationView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(0...lastSlideIndex, id: \.self) { index in
                    Capsule()
                        .fill(currentSlideTab == index ? Color.accentColor : Color(.systemGray4))
                        .frame(width: currentSlideTab == index ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: currentSlideTab)
                }
            }
            .padding(.bottom, 8)

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
                    Text(
                        currentSlideTab == lastSlideIndex
                            ? String(localized: "さっそくはじめる")
                            : String(localized: "次へ")
                    )
                    .font(.headline)
                    .fontWeight(.bold)

                    if currentSlideTab < lastSlideIndex {
                        Image(systemName: "arrow.right")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                }
                .foregroundStyle(.white)
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

    private func finishOnboarding() {
        if shouldLoadSampleData {
            PreviewSampleLoader.insertSamplesIfNeeded(into: modelContext)
        }
        isPresented = false
    }
}

#Preview {
    BoardingView(isPresented: .constant(true))
        .modelContainer(for: [BeverageItem.self, TastingLog.self, StorageLocation.self], inMemory: true)
}
