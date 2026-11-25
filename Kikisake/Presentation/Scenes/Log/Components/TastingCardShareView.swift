//
//  TastingCardShareView.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// Editorial share card view summarizing a single tasting log with selectable themes.
public struct TastingCardShareView: View {
    let log: TastingLog
    let theme: ShareCardTheme
    private let precomputedBottleImage: UIImage?

    @State private var processedBottleImage: UIImage? = nil

    public init(
        log: TastingLog,
        theme: ShareCardTheme? = nil,
        precomputedBottleImage: UIImage? = nil
    ) {
        self.log = log
        self.theme = theme ?? AppState.shared.effectiveShareCardTheme
        self.precomputedBottleImage = precomputedBottleImage
        self._processedBottleImage = State(initialValue: precomputedBottleImage)
    }

    private let cardWidth: CGFloat = 380
    private let cornerRadius: CGFloat = 22
    private let labelColumnWidth: CGFloat = 78

    private var appearanceColor: Color {
        colorFromHex(log.appearanceColorHex)
    }

    private var accentGlow: Color {
        switch theme {
        case .standard:
            appearanceColor.opacity(0.16)
        case .noir:
            Color(red: 0.88, green: 0.70, blue: 0.34).opacity(0.22)
        case .vivid:
            Color(red: 0.96, green: 0.24, blue: 0.48).opacity(0.28)
        }
    }

    private var paperColor: Color {
        switch theme {
        case .standard:
            Color(red: 0.992, green: 0.990, blue: 0.986)
        case .noir:
            Color(red: 0.068, green: 0.068, blue: 0.078)
        case .vivid:
            Color(red: 0.996, green: 0.972, blue: 0.984)
        }
    }

    private var inkColor: Color {
        switch theme {
        case .standard:
            Color(red: 0.11, green: 0.11, blue: 0.12)
        case .noir:
            Color(red: 0.97, green: 0.95, blue: 0.90)
        case .vivid:
            Color(red: 0.13, green: 0.09, blue: 0.26)
        }
    }

    private var mutedInkColor: Color {
        switch theme {
        case .standard:
            inkColor.opacity(0.54)
        case .noir:
            inkColor.opacity(0.62)
        case .vivid:
            Color(red: 0.34, green: 0.18, blue: 0.54).opacity(0.78)
        }
    }

    private var highlightAccentColor: Color {
        switch theme {
        case .standard:
            inkColor
        case .noir:
            Color(red: 0.88, green: 0.70, blue: 0.34)
        case .vivid:
            Color(red: 0.95, green: 0.22, blue: 0.46) // ビビッドローズ
        }
    }

    private var secondaryVividColor: Color {
        Color(red: 0.04, green: 0.64, blue: 0.74) // ビビッドシアン
    }

    private var tertiaryVividColor: Color {
        Color(red: 0.98, green: 0.50, blue: 0.12) // サンセットオレンジ
    }

    private var vividPurpleColor: Color {
        Color(red: 0.54, green: 0.24, blue: 0.90) // バイオレット
    }

    private var vividRainbowGradient: LinearGradient {
        LinearGradient(
            colors: [
                highlightAccentColor,
                tertiaryVividColor,
                vividPurpleColor,
                secondaryVividColor
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var chartAccentColor: Color {
        switch theme {
        case .standard:
            inkColor
        case .noir:
            Color(red: 0.88, green: 0.70, blue: 0.34)
        case .vivid:
            secondaryVividColor
        }
    }

    private var shareCardSurfaceColor: Color {
        switch theme {
        case .standard:
            inkColor.opacity(0.02)
        case .noir:
            Color.white.opacity(0.045)
        case .vivid:
            Color.white.opacity(0.84)
        }
    }

    private var borderColor: Color {
        switch theme {
        case .standard:
            inkColor.opacity(0.10)
        case .noir:
            highlightAccentColor.opacity(0.32)
        case .vivid:
            vividPurpleColor.opacity(0.28)
        }
    }

    private var categoryLabel: String {
        switch log.item?.category {
        case .wine: "WINE"
        case .sake: "SAKE"
        case .beer: "BEER"
        default: "TASTING NOTE"
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            header
            heroSection
            titleSection
            metadataSection
            tastingProfileSection
            analysisSection
            noteSection
            footer
        }
        .frame(width: cardWidth)
        .background(paperBackground)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    theme == .vivid
                        ? AnyShapeStyle(vividRainbowGradient.opacity(0.75))
                        : AnyShapeStyle(borderColor),
                    lineWidth: theme == .vivid ? 1.2 : (theme == .noir ? 1.0 : 0.8)
                )
        )
        .shadow(
            color: Color.black.opacity(theme == .noir ? 0.40 : 0.12),
            radius: 14,
            x: 0,
            y: 8
        )
    }

    private var paperBackground: some View {
        ZStack {
            paperColor

            switch theme {
            case .standard:
                LinearGradient(
                    colors: [
                        Color.white,
                        Color(red: 0.985, green: 0.984, blue: 0.980)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

            case .noir:
                RadialGradient(
                    colors: [
                        highlightAccentColor.opacity(0.16),
                        appearanceColor.opacity(0.08),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 10,
                    endRadius: 260
                )

                LinearGradient(
                    colors: [
                        Color.white.opacity(0.03),
                        Color.clear,
                        Color.black.opacity(0.32)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

            case .vivid:
                RadialGradient(
                    colors: [
                        highlightAccentColor.opacity(0.24),
                        tertiaryVividColor.opacity(0.14),
                        Color.clear
                    ],
                    center: .topLeading,
                    startRadius: 8,
                    endRadius: 230
                )

                RadialGradient(
                    colors: [
                        secondaryVividColor.opacity(0.24),
                        vividPurpleColor.opacity(0.14),
                        Color.clear
                    ],
                    center: .bottomTrailing,
                    startRadius: 10,
                    endRadius: 250
                )

                LinearGradient(
                    colors: [
                        tertiaryVividColor.opacity(0.08),
                        Color.clear,
                        secondaryVividColor.opacity(0.08)
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            HStack(spacing: 6) {
                if theme == .vivid {
                    Circle()
                        .fill(vividRainbowGradient)
                        .frame(width: 8, height: 8)
                } else {
                    Rectangle()
                        .fill(highlightAccentColor)
                        .frame(width: 14, height: 1)
                }

                Text("KIKISAKE")
                    .font(.system(size: 9.5, weight: .bold))
                    .tracking(2.0)
                    .foregroundStyle(inkColor)
            }

            Spacer()

            Text(categoryLabel)
                .font(.system(size: 8, weight: .bold))
                .tracking(1.6)
                .foregroundStyle(
                    theme == .vivid
                        ? Color.white
                        : (theme == .noir ? highlightAccentColor : mutedInkColor)
                )
                .padding(.horizontal, theme == .vivid ? 8 : 0)
                .padding(.vertical, theme == .vivid ? 2.5 : 0)
                .background(
                    theme == .vivid
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [highlightAccentColor, tertiaryVividColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        : AnyShapeStyle(Color.clear)
                )
                .clipShape(Capsule())
        }
        .padding(.horizontal, 22)
        .padding(.top, 14)
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack {
            RadialGradient(
                colors: [
                    accentGlow,
                    theme == .vivid ? secondaryVividColor.opacity(0.12) : appearanceColor.opacity(theme == .noir ? 0.08 : 0.05),
                    Color.clear
                ],
                center: .center,
                startRadius: 8,
                endRadius: 115
            )
            .frame(height: 185)

            VStack {
                Spacer()
                Rectangle()
                    .fill(borderColor)
                    .frame(height: 0.6)
                    .padding(.horizontal, 24)
            }

            bottleView
        }
        .frame(height: 192)
        .padding(.horizontal, 18)
        .padding(.top, 2)
    }

    @ViewBuilder
    private var bottleView: some View {
        if let item = log.item,
           let imageData = item.imageDatas?.first,
           let uiImage = UIImage(data: imageData) {
            if item.isBackgroundRemoved {
                let activeBottleImage = processedBottleImage ?? precomputedBottleImage
                Image(uiImage: activeBottleImage ?? uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 165, maxHeight: 176)
                    .shadow(color: Color.black.opacity(theme == .noir ? 0.45 : 0.20), radius: 10, x: 0, y: 6)
                    .task(id: imageData) {
                        if activeBottleImage == nil {
                            let processed = await BottleMattingHelper.removeBackground(from: uiImage)
                            processedBottleImage = processed
                        }
                    }
            } else {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 165, height: 176)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        } else {
            VStack(spacing: 6) {
                Image(systemName: "wineglass")
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(theme == .vivid ? highlightAccentColor.opacity(0.55) : inkColor.opacity(0.28))

                Text("NO IMAGE")
                    .font(.system(size: 8, weight: .medium))
                    .tracking(1.4)
                    .foregroundStyle(mutedInkColor)
            }
        }
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(spacing: 4) {
            if let producer = log.item?.producer, !producer.isEmpty {
                Text(producer.uppercased())
                    .font(.system(size: 8, weight: .bold))
                    .tracking(1.8)
                    .foregroundStyle(
                        theme == .vivid
                            ? vividPurpleColor
                            : (theme == .noir ? highlightAccentColor.opacity(0.9) : mutedInkColor)
                    )
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let name = log.item?.name {
                Text(name)
                    .font(.system(size: 21, weight: theme == .vivid ? .semibold : .regular, design: .serif))
                    .foregroundStyle(inkColor)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 8) {
                Rectangle()
                    .fill(theme == .vivid ? highlightAccentColor.opacity(0.55) : borderColor)
                    .frame(width: 28, height: 0.6)

                Text("TASTING NOTE")
                    .font(.system(size: 7, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(theme == .vivid ? secondaryVividColor : mutedInkColor)

                Rectangle()
                    .fill(theme == .vivid ? secondaryVividColor.opacity(0.55) : borderColor)
                    .frame(width: 28, height: 0.6)
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
    }

    // MARK: - Metadata

    private var metadataSection: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                metadataItem(title: String(localized: "生産地"), value: log.item?.region ?? "", tint: highlightAccentColor)
                metadataDivider
                metadataItem(title: String(localized: "VT/年月"), value: log.item?.vintage ?? "", tint: secondaryVividColor)
                metadataDivider
                metadataItem(title: String(localized: "度数"), value: formattedABV, tint: tertiaryVividColor)
            }

            if let specificMetadata = specificMetadataText, !specificMetadata.isEmpty {
                Text(specificMetadata)
                    .font(.system(size: 7.5, weight: .medium))
                    .foregroundStyle(mutedInkColor)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 6)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
    }

    private var metadataDivider: some View {
        Rectangle()
            .fill(borderColor)
            .frame(width: 0.5, height: 22)
    }

    private func metadataItem(title: String, value: String, tint: Color) -> some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.system(size: 7, weight: .bold))
                .tracking(0.9)
                .foregroundStyle(theme == .vivid ? tint : mutedInkColor)

            Text(value.isEmpty ? "—" : value)
                .font(.system(size: 8.5, weight: .medium))
                .foregroundStyle(inkColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    private var specificMetadataText: String? {
        guard let item = log.item,
              let json = item.specificMetadataJSON,
              let data = json.data(using: .utf8) else {
            return nil
        }

        let decoder = JSONDecoder()
        switch item.category {
        case .wine:
            guard let meta = try? decoder.decode(WineSpecificMetadata.self, from: data) else { return nil }
            let varietiesText = !meta.blendComponents.isEmpty
                ? meta.blendComponents.map { "\($0.variety)\($0.percentage.map { " \($0)%" } ?? "")" }.joined(separator: " · ")
                : meta.grapeVarieties
            return joinNonEmpty([varietiesText, meta.appellation])

        case .sake:
            guard let meta = try? decoder.decode(SakeSpecificMetadata.self, from: data) else { return nil }
            return joinNonEmpty([meta.specificName, meta.riceVariety, meta.polishingRate])

        case .beer:
            guard let meta = try? decoder.decode(BeerSpecificMetadata.self, from: data) else { return nil }
            let ibuText = meta.ibu.isEmpty ? nil : "IBU \(meta.ibu)"
            return joinNonEmpty([meta.beerStyle, ibuText])
        }
    }

    private func joinNonEmpty(_ values: [String?]) -> String? {
        let nonEmpty = values.compactMap { value -> String? in
            guard let value, !value.isEmpty else { return nil }
            return value
        }
        return nonEmpty.isEmpty ? nil : nonEmpty.joined(separator: "  ·  ")
    }

    // MARK: - Tasting Profile

    private var tastingProfileSection: some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                profileRowLabel("OVERALL")

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", log.rating))
                        .font(.system(size: 12.5, weight: .bold, design: .serif))
                        .foregroundStyle(theme == .vivid ? highlightAccentColor : inkColor)

                    Text("/ 5")
                        .font(.system(size: 8.5, weight: .medium))
                        .foregroundStyle(mutedInkColor)
                }

                ratingStars

                Spacer()
            }

            tastingRows
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
    }

    private func profileRowLabel(_ title: String) -> some View {
        let labelColor: Color = {
            switch theme {
            case .standard, .noir: return mutedInkColor
            case .vivid:
                switch title {
                case "OVERALL": return highlightAccentColor
                case "APPEARANCE": return secondaryVividColor
                case "AROMA": return tertiaryVividColor
                case "BALANCE": return vividPurpleColor
                case "SIGNATURE": return highlightAccentColor
                default: return mutedInkColor
                }
            }
        }()

        return Text(title)
            .font(.system(size: 8, weight: .bold))
            .tracking(0.6)
            .foregroundStyle(labelColor)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .frame(width: labelColumnWidth, alignment: .leading)
    }

    private var ratingStars: some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: starSymbol(for: index))
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(theme == .vivid ? tertiaryVividColor : highlightAccentColor)
            }
        }
    }

    private func starSymbol(for index: Int) -> String {
        let threshold = Double(index + 1)
        if log.rating >= threshold { return "star.fill" }
        if log.rating >= threshold - 0.5 { return "star.leadinghalf.filled" }
        return "star"
    }

    private var tastingRows: some View {
        VStack(spacing: 6) {
            tastingRow(title: "APPEARANCE", content: log.appearanceNotes, leading: appearanceColor)

            if !log.aromaTags.isEmpty {
                tastingTagsRow(title: "AROMA", tags: log.aromaTags)
            }

            if !log.balanceTags.isEmpty {
                tastingTagsRow(title: "BALANCE", tags: log.balanceTags)
            }

            featureRow
        }
    }

    private func tastingRow(title: String, content: String, leading: Color?) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            profileRowLabel(title)

            if let leading {
                Circle()
                    .fill(leading)
                    .frame(width: 6.5, height: 6.5)
                    .overlay(Circle().stroke(inkColor.opacity(0.25), lineWidth: 0.5))
            }

            Text(content.isEmpty ? "—" : content)
                .font(.system(size: 8.5, weight: .medium))
                .foregroundStyle(inkColor)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
    }

    private func tastingTagsRow(title: String, tags: [String]) -> some View {
        HStack(alignment: .top, spacing: 8) {
            profileRowLabel(title)
                .padding(.top, 2)

            FlowLayout(spacing: 4) {
                ForEach(Array(tags.enumerated()), id: \.offset) { idx, tag in
                    editorialTag(tag, index: idx)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var featureRow: some View {
        let activeTags: [String] = [
            log.isCostEffective ? String(localized: "コスパ高い") : nil,
            log.isWillingToRepeat ? String(localized: "リピート確定") : nil,
            log.hasAgingPotential ? String(localized: "熟成ポテンシャルあり") : nil
        ].compactMap { $0 }

        return HStack(alignment: .top, spacing: 8) {
            profileRowLabel("SIGNATURE")
                .padding(.top, 2)

            if activeTags.isEmpty {
                Text("—")
                    .font(.system(size: 8.5, weight: .medium))
                    .foregroundStyle(mutedInkColor)
            } else {
                FlowLayout(spacing: 4) {
                    ForEach(Array(activeTags.enumerated()), id: \.offset) { idx, tag in
                        editorialTag(tag, index: idx)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func vividBadgeColor(for index: Int) -> Color {
        let palette = [highlightAccentColor, secondaryVividColor, tertiaryVividColor, vividPurpleColor]
        return palette[index % palette.count]
    }

    private func editorialTag(_ text: String, index: Int = 0) -> some View {
        let badgeColor = vividBadgeColor(for: index)

        return Text(text)
            .font(.system(size: 7.5, weight: .bold))
            .foregroundStyle(
                theme == .vivid
                    ? Color.white
                    : (theme == .standard ? inkColor : highlightAccentColor)
            )
            .fixedSize(horizontal: true, vertical: true)
            .padding(.horizontal, 6.5)
            .padding(.vertical, 2.5)
            .background(
                theme == .vivid
                    ? badgeColor
                    : Color.clear
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        theme == .vivid ? badgeColor.opacity(0.85) : borderColor,
                        lineWidth: 0.7
                    )
            )
    }

    // MARK: - Analysis

    private var analysisSection: some View {
        let radarStyle: TasteRadarCardView.PresentationStyle = .shareCard(
            accentColor: chartAccentColor,
            surfaceColor: shareCardSurfaceColor,
            lineColor: borderColor,
            textColor: inkColor,
            mutedTextColor: mutedInkColor
        )

        let matrixStyle: MatrixAnalysisCardView.PresentationStyle = .shareCard(
            accentColor: theme == .vivid ? highlightAccentColor : chartAccentColor,
            surfaceColor: shareCardSurfaceColor,
            lineColor: borderColor,
            textColor: inkColor,
            mutedTextColor: mutedInkColor
        )

        return VStack(spacing: 8) {
            Rectangle()
                .fill(borderColor)
                .frame(height: 0.6)

            HStack(alignment: .top, spacing: 8) {
                TasteRadarCardView(log: log, isCompactMode: true, presentationStyle: radarStyle)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                MatrixAnalysisCardView(log: log, isCompactMode: true, presentationStyle: matrixStyle)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
    }

    // MARK: - Note

    private var noteSection: some View {
        VStack(spacing: 8) {
            if let pairing = log.pairing, !pairing.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("PAIRING")
                        .font(.system(size: 8, weight: .bold))
                        .tracking(0.6)
                        .foregroundStyle(theme == .vivid ? secondaryVividColor : mutedInkColor)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(width: labelColumnWidth, alignment: .leading)

                    Text(pairing)
                        .font(.system(size: 8.5, weight: .medium))
                        .foregroundStyle(inkColor)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }
            }

            if !log.memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TASTING NOTE")
                        .font(.system(size: 8, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(theme == .vivid ? tertiaryVividColor : mutedInkColor)

                    Text("“\(log.memo)”")
                        .font(.system(size: 8.5, weight: .medium))
                        .foregroundStyle(inkColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 6) {
            Rectangle()
                .fill(borderColor)
                .frame(height: 0.6)

            HStack(alignment: .center) {
                Text("PROFESSIONAL TASTING LOG")
                    .font(.system(size: 7, weight: .bold))
                    .tracking(1.0)
                    .foregroundStyle(mutedInkColor)

                Spacer()

                Text(log.date.toFormattedString())
                    .font(.system(size: 7.5, weight: .medium))
                    .foregroundStyle(mutedInkColor)
            }

            Text("KIKISAKE")
                .font(.system(size: 6.5, weight: .bold))
                .tracking(2.2)
                .foregroundStyle(
                    theme == .vivid
                        ? highlightAccentColor.opacity(0.75)
                        : inkColor.opacity(0.32)
                )
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
        .padding(.bottom, 14)
    }

    // MARK: - Helpers

    private var formattedABV: String {
        guard let abv = log.item?.alcoholByVolume else { return "" }
        return String(format: "%.1f%%", abv)
    }

    private func colorFromHex(_ hex: String) -> Color {
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        var rgbValue: UInt64 = 0
        if scanner.scanHexInt64(&rgbValue) {
            let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = Double(rgbValue & 0x0000FF) / 255.0
            return Color(red: red, green: green, blue: blue)
        }
        return .gray
    }
}

#Preview("Standard (White)") {
    let sample = PreviewSampleData.makeSampleBundle()
    return ZStack {
        Color(red: 0.13, green: 0.12, blue: 0.11).ignoresSafeArea()
        ScrollView {
            TastingCardShareView(log: sample.wineLog, theme: .standard)
                .padding(.vertical, 24)
        }
    }
    .modelContainer(PreviewSampleData.container)
}

#Preview("Noir (Black & Gold)") {
    let sample = PreviewSampleData.makeSampleBundle()
    return ZStack {
        Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea()
        ScrollView {
            TastingCardShareView(log: sample.wineLog, theme: .noir)
                .padding(.vertical, 24)
        }
    }
    .modelContainer(PreviewSampleData.container)
}

#Preview("Vivid (Colorful)") {
    let sample = PreviewSampleData.makeSampleBundle()
    return ZStack {
        Color(red: 0.15, green: 0.12, blue: 0.22).ignoresSafeArea()
        ScrollView {
            TastingCardShareView(log: sample.wineLog, theme: .vivid)
                .padding(.vertical, 24)
        }
    }
    .modelContainer(PreviewSampleData.container)
}
