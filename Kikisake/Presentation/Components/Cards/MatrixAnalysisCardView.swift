//
//  MatrixAnalysisCardView.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// 2軸4象限マトリクス分析カードコンポーネント
public struct MatrixAnalysisCardView: View {
    let log: TastingLog
    let isCompactMode: Bool

    @State private var showPaywall: Bool = false

    /// 表示コンテキスト
    public enum PresentationStyle {
        case standard
        case shareCard(
            accentColor: Color,
            surfaceColor: Color,
            lineColor: Color,
            textColor: Color,
            mutedTextColor: Color
        )
    }

    let presentationStyle: PresentationStyle

    public init(
        log: TastingLog,
        isCompactMode: Bool = false,
        presentationStyle: PresentationStyle = .standard
    ) {
        self.log = log
        self.isCompactMode = isCompactMode
        self.presentationStyle = presentationStyle
    }

    public var body: some View {
        let isPro = AppState.shared.isProVersion
        let category = log.item?.category ?? .wine
        let axes = MatrixHelper.axes(for: category)
        let xValue = MatrixHelper.xCoordinate(for: log, category: category)
        let yValue = MatrixHelper.yCoordinate(for: log, category: category)

        Group {
            switch presentationStyle {
            case .standard:
                standardContent(axes: axes, xValue: xValue, yValue: yValue)

            case let .shareCard(accentColor, surfaceColor, lineColor, textColor, mutedTextColor):
                shareCardContent(
                    axes: axes,
                    xValue: xValue,
                    yValue: yValue,
                    accentColor: accentColor,
                    surfaceColor: surfaceColor,
                    lineColor: lineColor,
                    textColor: textColor,
                    mutedTextColor: mutedTextColor
                )
            }
        }
        .modifier(
            MatrixProModifier(
                isPro: isPro,
                isCompactMode: isCompactMode,
                showPaywall: $showPaywall
            )
        )
    }

    // MARK: - Standard

    @ViewBuilder
    private func standardContent(
        axes: MatrixAxesSpec,
        xValue: Double,
        yValue: Double
    ) -> some View {
        if isCompactMode {
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    Text("マトリクス")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.primary)

                    Spacer()

                    Text("\(axes.xTitle) / \(axes.yTitle)")
                        .font(.system(size: 7, weight: .medium))
                        .foregroundStyle(.secondary.opacity(0.8))
                        .lineLimit(1)
                }

                standardMatrix(axes: axes, xValue: xValue, yValue: yValue)
            }
        } else {
            VStack(spacing: 12) {
                HStack {
                    Text("マトリクス分析")
                        .font(.headline)

                    Spacer()
                }

                standardMatrix(axes: axes, xValue: xValue, yValue: yValue)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }

    @ViewBuilder
    private func standardMatrix(
        axes: MatrixAxesSpec,
        xValue: Double,
        yValue: Double
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: isCompactMode ? 6 : 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: isCompactMode ? 6 : 12)
                        .stroke(Color(.systemGray4), lineWidth: isCompactMode ? 0.8 : 1)
                )

            GeometryReader { geo in
                let width = geo.size.width
                let height = geo.size.height

                crossLinesPath(width: width, height: height)
                    .stroke(
                        Color(.systemGray4),
                        style: StrokeStyle(
                            lineWidth: isCompactMode ? 0.8 : 1,
                            dash: isCompactMode ? [2] : [4]
                        )
                    )

                quadrantLabelsView(axes: axes, horizontalInset: isCompactMode ? 4 : 8)
                    .font(.system(size: isCompactMode ? 6 : 8.5, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, isCompactMode ? 12 : 18)

                Circle()
                    .fill(Color.accentColor)
                    .frame(width: isCompactMode ? 9 : 14, height: isCompactMode ? 9 : 14)
                    .overlay(
                        Circle()
                            .stroke(Color(.systemBackground), lineWidth: isCompactMode ? 1.5 : 2)
                    )
                    .shadow(color: Color.accentColor.opacity(0.35), radius: isCompactMode ? 2 : 4)
                    .position(x: xValue * width, y: (1.0 - yValue) * height)
            }

            // 上端（Y高）：中央上部に配置して左右の角ラベルと重ならないようにする
            VStack {
                Text(axes.yHigh)
                    .font(.system(size: isCompactMode ? 5.5 : 7, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.top, 2.5)

            // 下端（X低・X高）：中央下部に配置して左右の角ラベルと重ならないようにする
            VStack {
                Spacer()
                HStack(spacing: 4) {
                    Text(axes.xLow)
                        .lineLimit(1)
                    Text("·")
                    Text(axes.xHigh)
                        .lineLimit(1)
                }
                .font(.system(size: isCompactMode ? 5.5 : 7, weight: .medium))
                .foregroundStyle(.secondary)
            }
            .padding(.bottom, 2.5)
        }
        .frame(height: isCompactMode ? 96 : 220)
    }

    // MARK: - Editorial Share Card

    @ViewBuilder
    private func shareCardContent(
        axes: MatrixAxesSpec,
        xValue: Double,
        yValue: Double,
        accentColor: Color,
        surfaceColor: Color,
        lineColor: Color,
        textColor: Color,
        mutedTextColor: Color
    ) -> some View {
        let blackInk = Color(red: 0.105, green: 0.095, blue: 0.085)

        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("POSITION")
                        .font(.system(size: isCompactMode ? 6.5 : 8, weight: .black))
                        .tracking(1.4)
                        .foregroundStyle(blackInk)

                    Text("テイスト・マトリクス")
                        .font(.system(size: isCompactMode ? 8 : 11, weight: .bold, design: .serif))
                        .foregroundStyle(blackInk)
                }

                Spacer()

                Text("02")
                    .font(.system(size: isCompactMode ? 7 : 9, weight: .medium, design: .serif))
                    .foregroundStyle(mutedTextColor)
            }

            Rectangle()
                .fill(blackInk.opacity(0.22))
                .frame(height: 0.5)

            editorialMatrix(
                axes: axes,
                xValue: xValue,
                yValue: yValue,
                surfaceColor: surfaceColor,
                lineColor: blackInk,
                mutedTextColor: mutedTextColor
            )
            .frame(maxHeight: .infinity)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, isCompactMode ? 7 : 12)
        .padding(.vertical, isCompactMode ? 6 : 10)
        .background(
            RoundedRectangle(cornerRadius: isCompactMode ? 8 : 12, style: .continuous)
                .fill(surfaceColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: isCompactMode ? 8 : 12, style: .continuous)
                .stroke(lineColor.opacity(0.22), lineWidth: 0.7)
        )
    }

    @ViewBuilder
    private func editorialMatrix(
        axes: MatrixAxesSpec,
        xValue: Double,
        yValue: Double,
        surfaceColor: Color,
        lineColor: Color,
        mutedTextColor: Color
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: isCompactMode ? 5 : 8, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [surfaceColor.opacity(0.8), surfaceColor.opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: isCompactMode ? 5 : 8, style: .continuous)
                        .stroke(lineColor.opacity(0.35), lineWidth: 0.6)
                )

            GeometryReader { geo in
                let width = geo.size.width
                let height = geo.size.height

                crossLinesPath(width: width, height: height)
                    .stroke(
                        lineColor.opacity(0.35),
                        style: StrokeStyle(lineWidth: 0.55, dash: [3, 3])
                    )

                // 四隅ラベル：上下の軸端ラベルと重ならないよう上下に余白を設ける
                quadrantLabelsView(axes: axes, horizontalInset: isCompactMode ? 4 : 7)
                    .font(.system(size: isCompactMode ? 5.5 : 7.5, weight: .medium, design: .serif))
                    .foregroundStyle(lineColor.opacity(0.82))
                    .padding(.vertical, isCompactMode ? 11 : 16)

                // プロット点（黒基調）
                Circle()
                    .fill(lineColor.opacity(0.12))
                    .frame(width: isCompactMode ? 18 : 28, height: isCompactMode ? 18 : 28)
                    .position(x: xValue * width, y: (1.0 - yValue) * height)

                Circle()
                    .fill(lineColor)
                    .frame(width: isCompactMode ? 6.5 : 9, height: isCompactMode ? 6.5 : 9)
                    .overlay(
                        Circle()
                            .stroke(surfaceColor, lineWidth: 1.0)
                    )
                    .position(x: xValue * width, y: (1.0 - yValue) * height)
            }

            // 上端：Y高ラベル（中央上）
            VStack {
                Text(axes.yHigh)
                    .font(.system(size: isCompactMode ? 5 : 6.5, weight: .semibold))
                    .foregroundStyle(mutedTextColor)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.top, 2)

            // 下端：X低・X高ラベル（中央下）
            VStack {
                Spacer()
                HStack(spacing: 3) {
                    Text(axes.xLow)
                        .lineLimit(1)
                    Text("·")
                    Text(axes.xHigh)
                        .lineLimit(1)
                }
                .font(.system(size: isCompactMode ? 5 : 6.5, weight: .semibold))
                .foregroundStyle(mutedTextColor)
            }
            .padding(.bottom, 2)
        }
        .frame(height: isCompactMode ? 96 : 220)
    }

    // MARK: - Shared Subviews

    private func crossLinesPath(width: CGFloat, height: CGFloat) -> Path {
        let centerX = width / 2
        let centerY = height / 2

        return Path { path in
            path.move(to: CGPoint(x: 0, y: centerY))
            path.addLine(to: CGPoint(x: width, y: centerY))
            path.move(to: CGPoint(x: centerX, y: 0))
            path.addLine(to: CGPoint(x: centerX, y: height))
        }
    }

    private func quadrantLabelsView(axes: MatrixAxesSpec, horizontalInset: CGFloat) -> some View {
        VStack {
            HStack(spacing: 4) {
                Text(axes.topLeft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Spacer(minLength: 4)
                Text(axes.topRight)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: 4)

            HStack(spacing: 4) {
                Text(axes.bottomLeft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Spacer(minLength: 4)
                Text(axes.bottomRight)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .padding(.horizontal, horizontalInset)
    }
}

// MARK: - Pro Modifier

private struct MatrixProModifier: ViewModifier {
    let isPro: Bool
    let isCompactMode: Bool
    @Binding var showPaywall: Bool

    func body(content: Content) -> some View {
        if isPro {
            content
        } else {
            ZStack {
                content
                    .opacity(0.3)
                    .blur(radius: isCompactMode ? 0.5 : 0.8)
                    .allowsHitTesting(false)

                Button {
                    showPaywall = true
                } label: {
                    VStack(spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: isCompactMode ? 10 : 12))

                            Text("PRO限定機能")
                                .font(.system(size: isCompactMode ? 10 : 12, weight: .bold))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)

                        Text("タップしてPro版で詳細分析を解放")
                            .font(.system(size: isCompactMode ? 8 : 10, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                    .padding(isCompactMode ? 8 : 12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

#Preview("Standard • Pro") {
    let schema = Schema([BeverageItem.self, TastingLog.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let sampleItem = BeverageItem(
        name: "Barolo DOCG 2018",
        producer: "Prunotto",
        category: .wine,
        region: "ピエモンテ, イタリア",
        vintage: "2018"
    )

    let sampleLog = TastingLog(
        date: Date(),
        rating: 4.8,
        appearanceNotes: "ガーネット",
        appearanceColorHex: "#802633",
        sweetness: 2.0,
        saltiness: 0.0,
        acidity: 4.2,
        bitterness: 2.0,
        umami: 2.5,
        tannin: 4.5,
        body: 4.5,
        finishLength: 4.8,
        memo: "素晴らしいバランス",
        item: sampleItem
    )

    container.mainContext.insert(sampleItem)
    container.mainContext.insert(sampleLog)
    AppState.shared.isProVersion = true

    return MatrixAnalysisCardView(log: sampleLog, isCompactMode: false, presentationStyle: .standard)
        .padding()
        .background(Color(.systemGroupedBackground))
        .modelContainer(container)
}

#Preview("Share Card • Pro") {
    let schema = Schema([BeverageItem.self, TastingLog.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let sampleItem = BeverageItem(
        name: "Barolo DOCG 2018",
        producer: "Prunotto",
        category: .wine,
        region: "ピエモンテ, イタリア",
        vintage: "2018"
    )

    let sampleLog = TastingLog(
        date: Date(),
        rating: 4.8,
        appearanceNotes: "ガーネット",
        appearanceColorHex: "#802633",
        sweetness: 2.0,
        saltiness: 0.0,
        acidity: 4.2,
        bitterness: 2.0,
        umami: 2.5,
        tannin: 4.5,
        body: 4.5,
        finishLength: 4.8,
        memo: "素晴らしいバランス",
        item: sampleItem
    )

    container.mainContext.insert(sampleItem)
    container.mainContext.insert(sampleLog)
    AppState.shared.isProVersion = true

    return MatrixAnalysisCardView(
        log: sampleLog,
        isCompactMode: false,
        presentationStyle: .shareCard(
            accentColor: Color(red: 0.105, green: 0.095, blue: 0.085),
            surfaceColor: Color(red: 0.975, green: 0.965, blue: 0.935),
            lineColor: Color(red: 0.105, green: 0.095, blue: 0.085),
            textColor: Color(red: 0.105, green: 0.095, blue: 0.085),
            mutedTextColor: Color(red: 0.105, green: 0.095, blue: 0.085).opacity(0.56)
        )
    )
    .padding()
    .background(Color.black)
    .modelContainer(container)
}

#Preview("Share Card • Pro • Compact") {
    let schema = Schema([BeverageItem.self, TastingLog.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let sampleItem = BeverageItem(
        name: "Barolo DOCG 2018",
        producer: "Prunotto",
        category: .wine,
        region: "ピエモンテ, イタリア",
        vintage: "2018"
    )

    let sampleLog = TastingLog(
        date: Date(),
        rating: 4.8,
        appearanceNotes: "ガーネット",
        appearanceColorHex: "#802633",
        sweetness: 2.0,
        saltiness: 0.0,
        acidity: 4.2,
        bitterness: 2.0,
        umami: 2.5,
        tannin: 4.5,
        body: 4.5,
        finishLength: 4.8,
        memo: "素晴らしいバランス",
        item: sampleItem
    )

    container.mainContext.insert(sampleItem)
    container.mainContext.insert(sampleLog)
    AppState.shared.isProVersion = true

    return MatrixAnalysisCardView(
        log: sampleLog,
        isCompactMode: true,
        presentationStyle: .shareCard(
            accentColor: Color(red: 0.105, green: 0.095, blue: 0.085),
            surfaceColor: Color(red: 0.975, green: 0.965, blue: 0.935),
            lineColor: Color(red: 0.105, green: 0.095, blue: 0.085),
            textColor: Color(red: 0.105, green: 0.095, blue: 0.085),
            mutedTextColor: Color(red: 0.105, green: 0.095, blue: 0.085).opacity(0.56)
        )
    )
    .frame(width: 170)
    .padding()
    .background(Color.black)
    .modelContainer(container)
}
