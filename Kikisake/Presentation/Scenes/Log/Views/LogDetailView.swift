//
//  LogDetailView.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// Detail view for an individual tasting log.
public struct LogDetailView: View {
    let log: TastingLog

    @State private var isShowingImageModal: Bool = false
    @State private var isShowingEditSheet: Bool = false
    @State private var isShowingBackImageModal: Bool = false
    @State private var processedBottleImage: UIImage? = nil
    @State private var resolvedShareBottleImage: UIImage? = nil

    public init(log: TastingLog) {
        self.log = log
    }

    private var appearanceColor: Color {
        colorFromHex(log.appearanceColorHex)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if !AppState.shared.isProVersion {
                    ConditionalAdMobBannerView()
                        .frame(height: 50)
                        .background(Color(.systemBackground))
                }

                heroHeaderView
                    .padding(.horizontal)

                reDrinkQuickActionBanner
                    .padding(.horizontal)

                VStack(spacing: 16) {
                    if let item = log.item {
                        basicInfoCard(for: item)
                        specificMetadataCard(for: item)
                    }

                    if log.isEvaluated {
                        evaluatedSections
                    } else {
                        unEvaluatedPlaceholderCard
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(String(localized: "ログ詳細"))
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $isShowingImageModal) {
            if let imageData = log.item?.imageDatas?.first, let uiImage = UIImage(data: imageData) {
                fullscreenImageOverlay(image: uiImage) {
                    isShowingImageModal = false
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingBackImageModal) {
            if let backImageData = log.item?.backImageDatas?.first, let backUiImage = UIImage(data: backImageData) {
                fullscreenImageOverlay(image: backUiImage) {
                    isShowingBackImageModal = false
                }
            }
        }
        .toolbar { detailToolbarContent }
        .sheet(isPresented: $isShowingEditSheet) {
            EditLogFlowView(log: log)
        }
        .task(id: log.item?.imageDatas?.first) {
            await prepareShareBottleImageIfNeeded()
        }
    }

    @ViewBuilder
    private var evaluatedSections: some View {
        ratingCard
        appearanceAndAromaCard

        TasteRadarCardView(log: log, isCompactMode: false)
        MatrixAnalysisCardView(log: log, isCompactMode: false)

        if log.isCostEffective || log.isWillingToRepeat || log.hasAgingPotential {
            flagsCard
        }

        if let pairing = log.pairing, !pairing.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            pairingCard(pairing: pairing)
        }

        if !log.memo.isEmpty {
            memoCard
        }
    }

    @ToolbarContentBuilder
    private var detailToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                let vm = AppState.shared.addFlowViewModel
                vm.configureWithLog(log)
                isShowingEditSheet = true
            } label: {
                Image(systemName: "square.and.pencil")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            if log.isEvaluated, #available(iOS 16.0, *) {
                let shareImage = renderShareImage()
                let previewTitle = String(localized: "\(log.item?.name ?? "テイスティング") の記録")
                ShareLink(
                    item: shareImage,
                    preview: SharePreview(previewTitle, image: shareImage)
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }

    private func fullscreenImageOverlay(image: UIImage, onClose: @escaping () -> Void) -> some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding()
            }
        }
    }

    private var reDrinkQuickActionBanner: some View {
        Button(action: prepareReDrinkFlow) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.accentColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "もう一度同じものを飲む"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text(String(localized: "基本情報をコピーして新しい記録を作成します"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func prepareReDrinkFlow() {
        let vm = AppState.shared.addFlowViewModel
        vm.reset()
        if let item = log.item {
            vm.selectedCategory = item.category
            vm.name = item.name
            vm.producer = item.producer
            vm.region = item.region
            vm.vintage = item.vintage ?? ""
            if let abv = item.alcoholByVolume {
                vm.abvString = "\(abv)"
            }
            if let price = item.price {
                vm.priceString = "\(price)"
            }
            vm.storageLocation = item.storageLocation
            vm.selectedGridRow = item.gridRow
            vm.selectedGridColumn = item.gridColumn

            if let json = item.specificMetadataJSON, let data = json.data(using: .utf8) {
                applySpecificMetadataToFlow(vm: vm, category: item.category, data: data)
            }
        }
        AppState.shared.selectedTab = 2
    }

    private func applySpecificMetadataToFlow(vm: AddFlowViewModel, category: BeverageCategory, data: Data) {
        let decoder = JSONDecoder()
        switch category {
        case .wine:
            if let meta = try? decoder.decode(WineSpecificMetadata.self, from: data) {
                vm.wineType = meta.wineType
                vm.grapeVarieties = meta.grapeVarieties
                if !meta.blendComponents.isEmpty {
                    vm.blendComponents = meta.blendComponents
                }
                vm.appellation = meta.appellation ?? ""
            }
        case .sake:
            if let meta = try? decoder.decode(SakeSpecificMetadata.self, from: data) {
                vm.sakeSpecificName = meta.specificName
                vm.riceVariety = meta.riceVariety
                vm.polishingRate = meta.polishingRate
                vm.sakeMeterValue = meta.sakeMeterValue
            }
        case .beer:
            if let meta = try? decoder.decode(BeerSpecificMetadata.self, from: data) {
                vm.beerStyle = meta.beerStyle
                vm.ibu = meta.ibu
            }
        }
    }

    private var unEvaluatedPlaceholderCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 64, height: 64)
                Image(systemName: "note.text.badge.plus")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.accentColor)
            }
            .padding(.top, 8)

            VStack(spacing: 6) {
                Text("テイスティング記録がありません")
                    .font(.headline)
                    .fontWeight(.bold)

                Text("このボトルの香り、味わい、スコアはまだ記録されていません。\n記録をつけると、レーダーチャートや味わい分析、シェアカードが生成されます。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                let vm = AppState.shared.addFlowViewModel
                vm.reset()
                if let item = log.item {
                    vm.configureWithItem(item)
                }
                vm.editingLog = log
                vm.editingItem = log.item
                vm.currentStep = 2
                isShowingEditSheet = true
            } label: {
                Label("テイスティングを記録する", systemImage: "square.and.pencil")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private var flagsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("特徴・評価フラグ")
                .font(.headline)

            FlowLayout(spacing: 8) {
                if log.isCostEffective {
                    flagBadge(title: "コスパ高い", systemImage: "yensign.circle.fill", tint: .green)
                }
                if log.isWillingToRepeat {
                    flagBadge(title: "リピート意向", systemImage: "arrow.clockwise.circle.fill", tint: .orange)
                }
                if log.hasAgingPotential {
                    flagBadge(title: "熟成ポテンシャル", systemImage: "hourglass.circle.fill", tint: .purple)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private func flagBadge(title: LocalizedStringKey, systemImage: String, tint: Color) -> some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(tint.opacity(0.12))
            .foregroundStyle(tint)
            .cornerRadius(10)
    }

    private func pairingCard(pairing: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ペアリング")
                .font(.headline)

            Text(pairing)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private var heroHeaderView: some View {
        ZStack(alignment: .bottom) {
            heroBackgroundAndImage

            if let backImageData = log.item?.backImageDatas?.first, let backUiImage = UIImage(data: backImageData) {
                backLabelThumbnail(image: backUiImage)
            }

            if let item = log.item {
                heroTitleOverlay(item: item)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    @ViewBuilder
    private var heroBackgroundAndImage: some View {
        if let item = log.item, let imageData = item.imageDatas?.first, let uiImage = UIImage(data: imageData) {
            Button {
                isShowingImageModal = true
            } label: {
                GeometryReader { geometry in
                    ZStack(alignment: .center) {
                        heroBackdrop(isBackgroundRemoved: item.isBackgroundRemoved, uiImage: uiImage, width: geometry.size.width)
                        heroBottleImage(item: item, uiImage: uiImage, maxWidth: geometry.size.width - 32)
                        heroReadabilityGradient(isBackgroundRemoved: item.isBackgroundRemoved)
                    }
                }
                .frame(height: 260)
            }
            .buttonStyle(.plain)
        } else {
            ZStack {
                LinearGradient(
                    colors: [appearanceColor.opacity(0.4), appearanceColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: "wineglass.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
        }
    }

    @ViewBuilder
    private func heroBackdrop(isBackgroundRemoved: Bool, uiImage: UIImage, width: CGFloat) -> some View {
        if isBackgroundRemoved {
            RadialGradient(
                colors: [
                    appearanceColor.opacity(0.3),
                    Color(.systemBackground).opacity(0.8),
                    Color(.secondarySystemBackground)
                ],
                center: .center,
                startRadius: 20,
                endRadius: 180
            )
        } else {
            LinearGradient(
                colors: [
                    Color(hex: "#1A1A1E") ?? .black,
                    Color(hex: "#2C2C30") ?? .gray
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: 260)
                .blur(radius: 20)
                .opacity(0.3)
        }
    }

    @ViewBuilder
    private func heroBottleImage(item: BeverageItem, uiImage: UIImage, maxWidth: CGFloat) -> some View {
        if item.isBackgroundRemoved {
            let displayImage = processedBottleImage ?? uiImage
            Image(uiImage: displayImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: maxWidth, maxHeight: 220)
                .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
                .padding(.vertical, 8)
                .task(id: item.imageDatas?.first) {
                    if processedBottleImage == nil {
                        processedBottleImage = await BottleMattingHelper.removeBackground(from: uiImage)
                    }
                }
        } else {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: maxWidth, maxHeight: 220)
                .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 6)
                .padding(.vertical, 8)
        }
    }

    private func heroReadabilityGradient(isBackgroundRemoved: Bool) -> some View {
        LinearGradient(
            colors: [.clear, isBackgroundRemoved ? Color(.systemBackground).opacity(0.9) : .black.opacity(0.85)],
            startPoint: .center,
            endPoint: .bottom
        )
    }

    private func backLabelThumbnail(image: UIImage) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    isShowingBackImageModal = true
                } label: {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.white.opacity(0.8), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .padding(12)
            }
            Spacer()
                .frame(height: 48)
        }
    }

    private func heroTitleOverlay(item: BeverageItem) -> some View {
        let isRemoved = item.isBackgroundRemoved
        return VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(isRemoved ? .primary : Color.white)
                .shadow(color: isRemoved ? .clear : .black.opacity(0.5), radius: 2, x: 0, y: 1)
                .lineLimit(2)

            if !item.producer.isEmpty {
                Text(item.producer)
                    .font(.subheadline)
                    .foregroundStyle(isRemoved ? .secondary : Color.white.opacity(0.85))
                    .shadow(color: isRemoved ? .clear : .black.opacity(0.5), radius: 2, x: 0, y: 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }

    @MainActor
    private func prepareShareBottleImageIfNeeded() async {
        guard let item = log.item,
              item.isBackgroundRemoved,
              let imageData = item.imageDatas?.first,
              let uiImage = UIImage(data: imageData) else {
            resolvedShareBottleImage = nil
            return
        }

        if let processedBottleImage {
            resolvedShareBottleImage = processedBottleImage
            return
        }

        let removed = await BottleMattingHelper.removeBackground(from: uiImage)
        processedBottleImage = removed
        resolvedShareBottleImage = removed
    }

    @MainActor
    private func renderShareImage() -> Image {
        let bottleForShare = resolvedShareBottleImage ?? processedBottleImage
        let cardView = TastingCardShareView(
            log: log,
            precomputedBottleImage: bottleForShare
        )
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3.0

        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "wineglass")
    }

    private func basicInfoCard(for item: BeverageItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("基本情報")
                .font(.headline)

            VStack(spacing: 8) {
                if !item.region.isEmpty {
                    rowContent(label: String(localized: "生産地"), value: item.region)
                }
                if let vintage = item.vintage, !vintage.isEmpty {
                    rowContent(label: String(localized: "ヴィンテージ / 年月"), value: vintage)
                }
                if let abv = item.alcoholByVolume {
                    rowContent(label: String(localized: "アルコール度数"), value: String(format: "%.1f %%", abv))
                }
                if let price = item.price {
                    let priceString = String(format: String(localized: "%d 円"), price)
                    rowContent(label: String(localized: "価格"), value: priceString)
                }
                rowContent(label: String(localized: "登録日"), value: log.date.toFormattedString())
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    @ViewBuilder
    private func specificMetadataCard(for item: BeverageItem) -> some View {
        if let json = item.specificMetadataJSON, let data = json.data(using: .utf8) {
            switch item.category {
            case .wine:
                if let meta = try? JSONDecoder().decode(WineSpecificMetadata.self, from: data) {
                    wineMetadataCard(meta)
                }
            case .sake:
                if let meta = try? JSONDecoder().decode(SakeSpecificMetadata.self, from: data) {
                    sakeMetadataCard(meta)
                }
            case .beer:
                if let meta = try? JSONDecoder().decode(BeerSpecificMetadata.self, from: data) {
                    beerMetadataCard(meta)
                }
            }
        }
    }

    private func wineMetadataCard(_ meta: WineSpecificMetadata) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ワイン詳細")
                .font(.headline)

            VStack(spacing: 8) {
                rowContent(label: String(localized: "タイプ"), value: meta.wineType)
                if let appellation = meta.appellation, !appellation.isEmpty {
                    rowContent(label: String(localized: "原産地呼称"), value: appellation)
                }
                if !meta.blendComponents.isEmpty {
                    HStack {
                        Text("ブドウ品種")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(meta.blendComponents) { comp in
                                HStack {
                                    Text(comp.variety)
                                        .font(.subheadline)
                                        .fontWeight(.medium)

                                    if let pct = comp.percentage {
                                        Text("(\(pct) %)")
                                            .font(.subheadline)
                                            .foregroundStyle(.primary)
                                    }
                                }
                            }
                        }
                    }
                } else if !meta.grapeVarieties.isEmpty {
                    rowContent(label: String(localized: "主要品種"), value: meta.grapeVarieties)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private func sakeMetadataCard(_ meta: SakeSpecificMetadata) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("日本酒詳細")
                .font(.headline)

            VStack(spacing: 8) {
                rowContent(label: String(localized: "特定名称"), value: meta.specificName)
                if !meta.riceVariety.isEmpty {
                    rowContent(label: String(localized: "使用米"), value: meta.riceVariety)
                }
                if !meta.polishingRate.isEmpty {
                    rowContent(label: String(localized: "精米歩合"), value: meta.polishingRate)
                }
                if !meta.sakeMeterValue.isEmpty {
                    rowContent(label: String(localized: "日本酒度"), value: meta.sakeMeterValue)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private func beerMetadataCard(_ meta: BeerSpecificMetadata) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ビール詳細")
                .font(.headline)

            VStack(spacing: 8) {
                rowContent(label: String(localized: "ビアスタイル"), value: meta.beerStyle)
                if !meta.ibu.isEmpty {
                    rowContent(label: String(localized: "IBU (苦味単位)"), value: meta.ibu)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private var ratingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("評価・スコア")
                .font(.headline)

            HStack {
                Text("飲んだ日")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(log.date.toFormattedString())
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Divider()

            HStack {
                Text("総合スコア")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                HStack(spacing: 3) {
                    ForEach(0..<5, id: \.self) { i in
                        Image(systemName: Double(i) < log.rating ? "star.fill" : "star")
                            .foregroundStyle(.yellow)
                    }
                    Text(String(format: "%.1f", log.rating))
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.leading, 4)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private var appearanceAndAromaCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("外観・香り")
                .font(.headline)

            if !log.appearanceNotes.isEmpty {
                HStack {
                    Text("外観")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 8) {
                        Circle()
                            .fill(appearanceColor)
                            .frame(width: 16, height: 16)
                            .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1))
                        Text(log.appearanceNotes)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }

            if !log.aromaTags.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("香りタグ")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    FlowLayout(spacing: 6) {
                        ForEach(log.aromaTags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.accentColor.opacity(0.12))
                                .foregroundStyle(Color.accentColor)
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private var memoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("総合コメント")
                .font(.headline)

            Text(log.memo)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private func rowContent(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
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

private func generateVerticalSampleImage() -> Data? {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 600))
    let image = renderer.image { _ in
        UIColor.darkGray.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 400, height: 600))
    }
    return image.jpegData(compressionQuality: 0.8)
}

private func generateHorizontalSampleImage() -> Data? {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 800, height: 300))
    let image = renderer.image { _ in
        UIColor.systemIndigo.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 800, height: 300))
    }
    return image.jpegData(compressionQuality: 0.8)
}

#Preview("ワイン（評価済み）") {
    let sample = PreviewSampleData.makeSampleBundle()
    return NavigationStack {
        LogDetailView(log: sample.wineLog)
    }
    .modelContainer(PreviewSampleData.container)
}

#Preview("日本酒（評価済み）") {
    let sample = PreviewSampleData.makeSampleBundle()
    return NavigationStack {
        LogDetailView(log: sample.sakeLog)
    }
    .modelContainer(PreviewSampleData.container)
}
