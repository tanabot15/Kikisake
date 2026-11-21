//
//  TastingCardShareView.swift
//  Kikisake
//

import SwiftUI
import SwiftData

public struct TastingCardShareView: View {

    // MARK: - Properties

    let log: TastingLog
    private let precomputedBottleImage: UIImage?

    @State private var processedBottleImage: UIImage? = nil

    public init(
        log: TastingLog,
        precomputedBottleImage: UIImage? = nil
    ) {
        self.log = log
        self.precomputedBottleImage = precomputedBottleImage
        self._processedBottleImage = State(initialValue: precomputedBottleImage)
    }

    // MARK: - Constants

    private let cardWidth: CGFloat = 380
    private let cornerRadius: CGFloat = 22

    // MARK: - Colors

    private var appearanceColor: Color {
        colorFromHex(log.appearanceColorHex)
    }

    /// 外観色を「背景色」ではなく、
    /// ボトルを照らす光として利用する。
    private var accentGlow: Color {
        appearanceColor.opacity(0.30)
    }

    private var paperColor: Color {
        Color(red: 0.975, green: 0.965, blue: 0.935)
    }

    private var inkColor: Color {
        Color(red: 0.105, green: 0.095, blue: 0.085)
    }

    private var mutedInkColor: Color {
        inkColor.opacity(0.52)
    }

    /// 紙面上で視認性を確保しつつ、外観色のニュアンスを添えるチャート用アクセント
    private var chartAccentColor: Color {
        appearanceColor.opacity(0.85)
    }

    /// 分析カード用の紙面サーフェス
    private var shareCardSurfaceColor: Color {
        inkColor.opacity(0.025)
    }

    private var categoryLabel: String {
        switch log.item?.category {
        case .wine:
            return "WINE"
        case .sake:
            return "SAKE"
        case .beer:
            return "BEER"
        default:
            return "TASTING NOTE"
        }
    }

    // MARK: - Body

    public var body: some View {

        VStack(spacing: 0) {

            // Header
            header

            // Hero
            heroSection

            // Title
            titleSection

            // Metadata
            metadataSection

            // Tasting Profile
            tastingProfileSection

            // MARK: Analytical Cards
            analysisSection

            // MARK: Pairing / Memo
            noteSection

            // MARK: Footer
            footer
        }
        .frame(width: cardWidth)
        .background(
            ZStack {

                // Ivory paper
                paperColor

                // Very subtle appearance-color light
                RadialGradient(
                    colors: [
                        appearanceColor.opacity(0.12),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 10,
                    endRadius: 260
                )

                // Very subtle warm editorial texture
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.20),
                        Color.clear,
                        Color.black.opacity(0.015)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: cornerRadius,
                style: .continuous
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: cornerRadius,
                style: .continuous
            )
            .stroke(
                inkColor.opacity(0.10),
                lineWidth: 0.8
            )
        )
        .shadow(
            color: appearanceColor.opacity(0.16),
            radius: 18,
            x: 0,
            y: 10
        )
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            HStack(spacing: 7) {
                Rectangle()
                    .fill(inkColor)
                    .frame(width: 16, height: 1)

                Text("KIKISAKE")
                    .font(
                        .system(
                            size: 10,
                            weight: .bold
                        )
                    )
                    .tracking(2.2)
                    .foregroundStyle(inkColor)
            }

            Spacer()

            Text(categoryLabel)
                .font(.system(size: 8, weight: .semibold))
                .tracking(1.8)
                .foregroundStyle(mutedInkColor)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }

    // MARK: - Hero

    private var heroSection: some View {

        ZStack {
            // Editorial glow
            RadialGradient(
                colors: [
                    accentGlow,
                    appearanceColor.opacity(0.08),
                    Color.clear
                ],
                center: .center,
                startRadius: 10,
                endRadius: 145
            )
            .frame(height: 260)

            // Decorative hairline
            VStack {
                Spacer()

                Rectangle()
                    .fill(inkColor.opacity(0.07))
                    .frame(height: 0.5)
                    .padding(.horizontal, 28)
            }

            bottleView
        }
        .frame(height: 270)
        .padding(.horizontal, 18)
        .padding(.top, 4)
    }

    // MARK: - Bottle
    @ViewBuilder
    private var bottleView: some View {

        if let item = log.item,
           let imageData = item.imageDatas?.first,
           let uiImage = UIImage(data: imageData) {

            if item.isBackgroundRemoved {
                let activeBottleImage = processedBottleImage ?? precomputedBottleImage

                if let activeBottleImage {
                    Image(uiImage: activeBottleImage)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            maxWidth: 190,
                            maxHeight: 245
                        )
                        .shadow(
                            color: Color.black.opacity(0.22),
                            radius: 12,
                            x: 0,
                            y: 8
                        )
                } else {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            maxWidth: 190,
                            maxHeight: 245
                        )
                        .shadow(
                            color: Color.black.opacity(0.22),
                            radius: 12,
                            x: 0,
                            y: 8
                        )
                        .task(id: imageData) {
                            let processed = await BottleMattingHelper.removeBackground(
                                from: uiImage
                            )
                            await MainActor.run {
                                processedBottleImage = processed
                            }
                        }
                }
            } else {
                // Background-removalされていない画像の場合は、無理に切り抜かず「写真」として扱う。
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: 190,
                        height: 245
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 12,
                            style: .continuous
                        )
                    )
            }
        } else {
            VStack(spacing: 10) {
                Image(systemName: "wineglass")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(
                        inkColor.opacity(0.22)
                    )

                Text("NO IMAGE")
                    .font(
                        .system(
                            size: 8,
                            weight: .medium
                        )
                    )
                    .tracking(1.5)
                    .foregroundStyle(
                        mutedInkColor
                    )
            }
        }
    }

    // MARK: - Title
    private var titleSection: some View {
        VStack(spacing: 7) {
            if let producer = log.item?.producer,
               !producer.isEmpty {

                Text(producer.uppercased())
                    .font(
                        .system(
                            size: 8,
                            weight: .semibold
                        )
                    )
                    .tracking(2.0)
                    .foregroundStyle(mutedInkColor)
            }
            if let name = log.item?.name {
                Text(name)
                    .font(
                        .system(
                            size: 25,
                            weight: .regular,
                            design: .serif
                        )
                    )
                    .foregroundStyle(inkColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.72)
            }

            HStack(spacing: 10) {
                Rectangle()
                    .fill(inkColor.opacity(0.18))
                    .frame(width: 32, height: 0.6)

                Text("TASTING NOTE")
                    .font(
                        .system(
                            size: 7,
                            weight: .medium
                        )
                    )
                    .tracking(1.7)
                    .foregroundStyle(mutedInkColor)

                Rectangle()
                    .fill(inkColor.opacity(0.18))
                    .frame(width: 32, height: 0.6)
            }
        }
        .padding(.horizontal, 26)
        .padding(.top, 6)
    }

    // MARK: - Metadata
    private var metadataSection: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {

                metadataItem(
                    title: String(localized: "生産地"),
                    value: log.item?.region ?? ""
                )

                metadataDivider

                metadataItem(
                    title: String(localized: "VT/年月"),
                    value: log.item?.vintage ?? ""
                )

                metadataDivider

                metadataItem(
                    title: String(localized: "度数"),
                    value: formattedABV
                )
            }

            if let specificMetadata = specificMetadataText,
               !specificMetadata.isEmpty {

                Text(specificMetadata)
                    .font(
                        .system(
                            size: 7.5,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(mutedInkColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
    }

    private var metadataDivider: some View {
        Rectangle()
            .fill(inkColor.opacity(0.10))
            .frame(width: 0.5, height: 25)
    }

    private func metadataItem(
        title: String,
        value: String
    ) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(
                    .system(
                        size: 6.5,
                        weight: .bold
                    )
                )
                .tracking(1.0)
                .foregroundStyle(mutedInkColor)

            Text(value.isEmpty ? "—" : value)
                .font(
                    .system(
                        size: 8.5,
                        weight: .medium
                    )
                )
                .foregroundStyle(inkColor)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Specific Metadata
    private var specificMetadataText: String? {
        guard let item = log.item,
              let json = item.specificMetadataJSON,
              let data = json.data(using: .utf8)
        else {
            return nil
        }

        switch item.category {
        case .wine:
            guard let meta =
                    try? JSONDecoder().decode(
                        WineSpecificMetadata.self,
                        from: data
                    )
            else {
                return nil
            }

            var parts: [String] = []

            let varietiesText =
                !meta.blendComponents.isEmpty
                ? meta.blendComponents
                    .map {
                        "\($0.variety)\($0.percentage.map { " \($0)%" } ?? "")"
                    }
                    .joined(separator: " · ")
                : meta.grapeVarieties

            if !varietiesText.isEmpty {
                parts.append(varietiesText)
            }

            if let appellation = meta.appellation,
               !appellation.isEmpty {
                parts.append(appellation)
            }

            return parts.isEmpty
                ? nil
                : parts.joined(separator: "  ·  ")

        case .sake:
            guard let meta =
                    try? JSONDecoder().decode(
                        SakeSpecificMetadata.self,
                        from: data
                    )
            else {
                return nil
            }

            var parts: [String] = []

            if !meta.specificName.isEmpty {
                parts.append(meta.specificName)
            }

            if !meta.riceVariety.isEmpty {
                parts.append(meta.riceVariety)
            }

            if !meta.polishingRate.isEmpty {
                parts.append(meta.polishingRate)
            }

            return parts.isEmpty
                ? nil
                : parts.joined(separator: "  ·  ")

        case .beer:
            guard let meta =
                    try? JSONDecoder().decode(
                        BeerSpecificMetadata.self,
                        from: data
                    )
            else {
                return nil
            }

            var parts: [String] = []

            if !meta.beerStyle.isEmpty {
                parts.append(meta.beerStyle)
            }

            if !meta.ibu.isEmpty {
                parts.append("IBU \(meta.ibu)")
            }

            return parts.isEmpty
                ? nil
                : parts.joined(separator: "  ·  ")
        }
    }

    // MARK: - Tasting Profile

    private var tastingProfileSection: some View {
        VStack(spacing: 12) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("OVERALL")
                        .font(
                            .system(
                                size: 7,
                                weight: .bold
                            )
                        )
                        .tracking(1.5)
                        .foregroundStyle(mutedInkColor)

                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(String(format: "%.1f", log.rating))
                            .font(
                                .system(
                                    size: 36,
                                    weight: .light,
                                    design: .serif
                                )
                            )
                            .foregroundStyle(inkColor)
                        Text("/ 5")
                            .font(
                                .system(
                                    size: 9,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(mutedInkColor)
                    }
                }
                Spacer()
                ratingStars
            }
            tastingRows
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }

    private var ratingStars: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { index in
                Image(
                    systemName:
                        starSymbol(
                            for: index
                        )
                )
                .font(
                    .system(
                        size: 8,
                        weight: .medium
                    )
                )
                .foregroundStyle(inkColor)
            }
        }
    }

    private func starSymbol(for index: Int) -> String {
        let threshold = Double(index + 1)

        if log.rating >= threshold {
            return "star.fill"
        }

        if log.rating >= threshold - 0.5 {
            return "star.leadinghalf.filled"
        }

        return "star"
    }

    private var tastingRows: some View {
        VStack(spacing: 8) {
            tastingRow(
                title: "APPEARANCE",
                content: log.appearanceNotes,
                leading: appearanceColor
            )

            if !log.aromaTags.isEmpty {

                tastingRow(
                    title: "AROMA",
                    content: log.aromaTags.prefix(4).joined(separator: " · "),
                    leading: nil
                )
            }

            if !log.balanceTags.isEmpty {

                tastingRow(
                    title: "BALANCE",
                    content: log.balanceTags.prefix(3).joined(separator: " · "),
                    leading: nil
                )
            }

            featureRow
        }
    }

    private func tastingRow(
        title: String,
        content: String,
        leading: Color?
    ) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(
                    .system(
                        size: 6.5,
                        weight: .bold
                    )
                )
                .tracking(1.1)
                .foregroundStyle(mutedInkColor)
                .frame(width: 62, alignment: .leading)

            if let leading {
                Circle()
                    .fill(leading)
                    .frame(width: 6, height: 6)
                    .overlay(
                        Circle()
                            .stroke(
                                inkColor.opacity(0.18),
                                lineWidth: 0.5
                            )
                    )
            }

            Text(content.isEmpty ? "—" : content)
                .font(
                    .system(
                        size: 8.5,
                        weight: .medium
                    )
                )
                .foregroundStyle(inkColor)
                .lineLimit(2)

            Spacer(minLength: 0)
        }
    }

    private var featureRow: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("SIGNATURE")
                .font(
                    .system(
                        size: 6.5,
                        weight: .bold
                    )
                )
                .tracking(1.1)
                .foregroundStyle(mutedInkColor)
                .frame(width: 62, alignment: .leading)

            FlowLayout(spacing: 5) {

                if log.isCostEffective {
                    editorialTag("VALUE")
                }

                if log.isWillingToRepeat {
                    editorialTag("REPEAT")
                }

                if log.hasAgingPotential {
                    editorialTag("AGE-WORTHY")
                }

                if !log.isCostEffective &&
                    !log.isWillingToRepeat &&
                    !log.hasAgingPotential {
                    Text("—")
                        .font(
                            .system(
                                size: 8,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(mutedInkColor)
                }
            }
            Spacer(minLength: 0)
        }
    }

    private func editorialTag(_ text: String) -> some View {
        Text(text)
            .font(
                .system(
                    size: 6,
                    weight: .bold
                )
            )
            .tracking(0.7)
            .foregroundStyle(inkColor)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .overlay(
                Capsule()
                    .stroke(
                        inkColor.opacity(0.16),
                        lineWidth: 0.6
                    )
            )
    }

    // MARK: - Analysis

    private var analysisSection: some View {
        let radarStyle: TasteRadarCardView.PresentationStyle = .shareCard(
            accentColor: chartAccentColor,
            surfaceColor: shareCardSurfaceColor,
            lineColor: inkColor,
            textColor: inkColor,
            mutedTextColor: mutedInkColor
        )

        let matrixStyle: MatrixAnalysisCardView.PresentationStyle = .shareCard(
            accentColor: chartAccentColor,
            surfaceColor: shareCardSurfaceColor,
            lineColor: inkColor,
            textColor: inkColor,
            mutedTextColor: mutedInkColor
        )

        return VStack(spacing: 8) {
            Rectangle()
                .fill(inkColor.opacity(0.10))
                .frame(height: 0.5)

            HStack(spacing: 10) {

                TasteRadarCardView(
                    log: log,
                    isCompactMode: true,
                    presentationStyle: radarStyle
                )
                .frame(maxWidth: .infinity)

                MatrixAnalysisCardView(
                    log: log,
                    isCompactMode: true,
                    presentationStyle: matrixStyle
                )
                .frame(maxWidth: .infinity)
            }
            .scaleEffect(0.96)
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
    }

    // MARK: - Note

    private var noteSection: some View {
        VStack(spacing: 12) {
            if let pairing = log.pairing,
               !pairing
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .isEmpty {

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Image(systemName: "fork.knife")
                        .font(
                            .system(
                                size: 8,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(mutedInkColor)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("PAIRING")
                            .font(
                                .system(
                                    size: 6.5,
                                    weight: .bold
                                )
                            )
                            .tracking(1.1)
                            .foregroundStyle(mutedInkColor)

                        Text(pairing)
                            .font(
                                .system(
                                    size: 8.5,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(inkColor)
                    }

                    Spacer()
                }
            }

            if !log.memo
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .isEmpty {

                VStack(alignment: .leading, spacing: 7) {
                    Text("TASTING NOTE")
                        .font(
                            .system(
                                size: 6.5,
                                weight: .bold
                            )
                        )
                        .tracking(1.2)
                        .foregroundStyle(mutedInkColor)

                    Text("“\(log.memo)”")
                        .font(
                            .system(
                                size: 11,
                                weight: .regular,
                                design: .serif
                            )
                        )
                        .italic()
                        .foregroundStyle(inkColor)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(inkColor.opacity(0.12))
                .frame(height: 0.5)

            HStack(alignment: .center) {

                Text("PROFESSIONAL TASTING LOG")
                    .font(
                        .system(
                            size: 6,
                            weight: .bold
                        )
                    )
                    .tracking(1.1)
                    .foregroundStyle(mutedInkColor)

                Spacer()

                Text(log.date.toFormattedString())
                    .font(
                        .system(
                            size: 6.5,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(mutedInkColor)
            }

            Text("KIKISAKE")
                .font(
                    .system(
                        size: 6,
                        weight: .bold
                    )
                )
                .tracking(2.4)
                .foregroundStyle(inkColor.opacity(0.28))
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
        .padding(.bottom, 18)
    }

    // MARK: - Helpers
    private var formattedABV: String {
        guard let abv = log.item?.alcoholByVolume else {
            return ""
        }

        return String(
            format: "%.1f%%",
            abv
        )
    }

    private func colorFromHex(_ hex: String) -> Color {
        let scanner = Scanner(
            string: hex.replacingOccurrences(
                of: "#",
                with: ""
            )
        )

        var rgbValue: UInt64 = 0

        if scanner.scanHexInt64(&rgbValue) {

            let red =
                Double(
                    (rgbValue & 0xFF0000) >> 16
                ) / 255.0

            let green =
                Double(
                    (rgbValue & 0x00FF00) >> 8
                ) / 255.0

            let blue =
                Double(
                    rgbValue & 0x0000FF
                ) / 255.0

            return Color(
                red: red,
                green: green,
                blue: blue
            )
        }

        return .gray
    }
}

// MARK: - Preview Sample Images
private func generateVerticalSampleImage() -> Data? {
    let size = CGSize(
        width: 600,
        height: 1200
    )

    let renderer =
        UIGraphicsImageRenderer(
            size: size
        )

    let image =
        renderer.image { context in
            UIColor(
                red: 0.15,
                green: 0.05,
                blue: 0.08,
                alpha: 1.0
            )
            .setFill()

            let bodyRect =
                CGRect(
                    x: 180,
                    y: 300,
                    width: 240,
                    height: 820
                )

            UIBezierPath(
                roundedRect: bodyRect,
                cornerRadius: 40
            )
            .fill()

            let neckRect =
                CGRect(
                    x: 235,
                    y: 100,
                    width: 130,
                    height: 210
                )

            UIBezierPath(
                rect: neckRect
            )
            .fill()

            UIColor(
                red: 0.85,
                green: 0.70,
                blue: 0.35,
                alpha: 1.0
            )
            .setFill()

            let capRect =
                CGRect(
                    x: 235,
                    y: 70,
                    width: 130,
                    height: 70
                )

            UIBezierPath(
                roundedRect: capRect,
                cornerRadius: 8
            )
            .fill()

            UIColor(
                red: 0.95,
                green: 0.93,
                blue: 0.88,
                alpha: 1.0
            )
            .setFill()

            let labelRect =
                CGRect(
                    x: 200,
                    y: 480,
                    width: 200,
                    height: 320
                )

            UIBezierPath(
                roundedRect: labelRect,
                cornerRadius: 12
            )
            .fill()
        }

    return image.jpegData(
        compressionQuality: 0.9
    )
}

private func generateBackSampleImage() -> Data? {
    let renderer =
        UIGraphicsImageRenderer(
            size: CGSize(
                width: 400,
                height: 600
            )
        )

    let image =
        renderer.image { _ in

            UIColor.darkGray.setFill()

            UIRectFill(
                CGRect(
                    x: 0,
                    y: 0,
                    width: 400,
                    height: 600
                )
            )
        }

    return image.jpegData(
        compressionQuality: 0.8
    )
}

// MARK: - Preview

#Preview("Background Removed") {

    let schema = Schema([
        BeverageItem.self,
        TastingLog.self
    ])

    let config =
        ModelConfiguration(
            isStoredInMemoryOnly: true
        )

    let container =
        try! ModelContainer(
            for: schema,
            configurations: [config]
        )

    let sampleItem =
        BeverageItem(
            name: "Barolo DOCG 2018",
            producer: "Prunotto",
            category: .wine,
            region: "Piemonte, Italia",
            vintage: "2018",
            alcoholByVolume: 14.0,
            imageDatas: [
                generateVerticalSampleImage() ?? Data()
            ],
            isBackgroundRemoved: true
        )

    let sampleLog =
        TastingLog(
            rating: 4.8,
            pairing: "和牛のローストビーフ",
            memo: "深い果実味と端正なタンニン。余韻まで美しく、時間をかけて楽しみたい一本。",
            isEvaluated: true,
            item: sampleItem
        )

    container.mainContext.insert(
        sampleItem
    )

    container.mainContext.insert(
        sampleLog
    )

    return ZStack {

        Color(
            red: 0.13,
            green: 0.12,
            blue: 0.11
        )
        .ignoresSafeArea()

        ScrollView {

            TastingCardShareView(
                log: sampleLog
            )
            .padding(.vertical, 30)
        }
    }
    .modelContainer(container)
}

// MARK: - Preview
#Preview("Standard") {

    let schema = Schema([
        BeverageItem.self,
        TastingLog.self
    ])

    let config =
        ModelConfiguration(
            isStoredInMemoryOnly: true
        )

    let container =
        try! ModelContainer(
            for: schema,
            configurations: [config]
        )

    let sampleItem =
        BeverageItem(
            name: "Barolo DOCG 2018",
            producer: "Prunotto",
            category: .wine,
            region: "Piemonte, Italia",
            vintage: "2018",
            alcoholByVolume: 14.0,
            imageDatas: [
                generateVerticalSampleImage() ?? Data()
            ],
            isBackgroundRemoved: false
        )

    let sampleLog =
        TastingLog(
            rating: 4.8,
            pairing: "和牛のローストビーフ",
            memo: "深い果実味と端正なタンニン。余韻まで美しく、時間をかけて楽しみたい一本。",
            isEvaluated: true,
            item: sampleItem
        )

    container.mainContext.insert(
        sampleItem
    )

    container.mainContext.insert(
        sampleLog
    )

    return ZStack {

        Color(
            red: 0.13,
            green: 0.12,
            blue: 0.11
        )
        .ignoresSafeArea()

        ScrollView {

            TastingCardShareView(
                log: sampleLog
            )
            .padding(.vertical, 30)
        }
    }
    .modelContainer(container)
}
