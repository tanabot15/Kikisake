//
//  AddBlindResultView.swift
//  Kikisake
//

import SwiftUI

/// ブラインドテイスティングの答え合わせ結果＆振り返り画面（Step 6 / 7）
public struct AddBlindResultView: View {
    @Bindable var viewModel: AddFlowViewModel

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    private var evaluation: (score: Int, items: [BlindComparisonItem]) {
        viewModel.evaluateBlindResult()
    }

    private var rankTitle: String {
        switch evaluation.score {
        case 90...100: return String(localized: "MASTER SOMMELIER / 完璧な利き酒！")
        case 70..<90:  return String(localized: "EXPERT / 鋭い分析力！")
        case 40..<70:  return String(localized: "GOOD SENSE / 惜しいニアミス！")
        default:       return String(localized: "NICE TRY / 新たな発見！")
        }
    }

    private var scoreColor: Color {
        switch evaluation.score {
        case 80...100: return .green
        case 50..<80:  return .orange
        default:       return .indigo
        }
    }

    public var body: some View {
        Form {
            scoreHeroSection
            comparisonSection
            actualSpecSummarySection
            reflectionSection
        }
    }

    // MARK: - Score Hero

    private var scoreHeroSection: some View {
        Section {
            VStack(spacing: 12) {
                Text("BLIND TASTING RESULT")
                    .font(.caption2)
                    .fontWeight(.black)
                    .tracking(1.6)
                    .foregroundStyle(.secondary)

                ZStack {
                    Circle()
                        .stroke(scoreColor.opacity(0.2), lineWidth: 10)
                        .frame(width: 112, height: 112)

                    Circle()
                        .trim(from: 0, to: CGFloat(evaluation.score) / 100.0)
                        .stroke(scoreColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 112, height: 112)

                    VStack(spacing: 0) {
                        Text("\(evaluation.score)")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(scoreColor)
                        Text("% MATCH")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                }

                Text(rankTitle)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                if !viewModel.name.isEmpty {
                    Text(viewModel.name)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Comparison Table

    private var comparisonSection: some View {
        Section(String(localized: "予想 vs 実際のスペック")) {
            ForEach(evaluation.items) { item in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(item.label)
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Spacer()
                        matchBadge(for: item)
                    }

                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(localized: "あなたの予想"))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(item.guessedText)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .padding(.top, 14)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(localized: "実際のデータ"))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(item.actualText)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(item.isFullMatch ? .green : .primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func matchBadge(for item: BlindComparisonItem) -> some View {
        let (title, color): (String, Color) = {
            if item.isFullMatch {
                return (String(localized: "的中 +\(item.earnedPoints)pt"), .green)
            } else if item.isPartialMatch {
                return (String(localized: "部分一致 +\(item.earnedPoints)pt"), .orange)
            } else {
                return (String(localized: "不一致 0pt"), .secondary)
            }
        }()

        return Text(title)
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    // MARK: - Reference Specs

    private var actualSpecSummarySection: some View {
        Section(String(localized: "参考スペック（実際の数値）")) {
            HStack {
                Text(String(localized: "アルコール度数"))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(viewModel.abvString.isEmpty ? "—" : "\(viewModel.abvString)%")
                    .fontWeight(.medium)
            }
            HStack {
                Text(String(localized: "ヴィンテージ / 製造年月"))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(viewModel.vintage.isEmpty ? "—" : viewModel.vintage)
                    .fontWeight(.medium)
            }
        }
    }

    // MARK: - Reflection Memo

    private var reflectionSection: some View {
        Section(String(localized: "振り返りメモ（気づき・学び）")) {
            TextEditor(text: $viewModel.blindReflectionMemo)
                .frame(height: 110)
        }
    }
}

#Preview("High") {
    let vm = AddFlowViewModel()
    vm.selectedCategory = .wine
    vm.name = "シャトー・マルゴー"
    vm.region = "フランス, ボルドー"
    vm.vintage = "2018"
    vm.abvString = "13.5"
    vm.blendComponents = [
        BlendComponent(variety: "カベルネ・ソーヴィニヨン", percentage: 85),
        BlendComponent(variety: "メルロ", percentage: 15)
    ]
    vm.guessedWineBlend = [
        BlendComponent(variety: "カベルネ・ソーヴィニヨン", percentage: 80),
        BlendComponent(variety: "メルロ", percentage: 20)
    ]
    vm.guessedWineRegion = "フランス, ボルドー"
    vm.blindReflectionMemo = "カシスとスミレの華やかさに加え、ベルベットのようなタンニンからボルドー左岸と推理。"

    return NavigationStack {
        AddBlindResultView(viewModel: vm)
            .navigationTitle("答え合わせ")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Sake") {
    let vm = AddFlowViewModel()
    vm.selectedCategory = .sake
    vm.name = "十四代 本丸"
    vm.region = "日本, 山形県"
    vm.vintage = "2024.10"
    vm.abvString = "15.0"
    vm.sakeSpecificName = "本醸造"
    vm.riceVariety = "五百万石"
    vm.guessedSakeSpecificName = "純米吟醸"
    vm.guessedSakeRiceVariety = "五百万石"
    vm.guessedSakeRegion = "日本, 山形県"

    return NavigationStack {
        AddBlindResultView(viewModel: vm)
            .navigationTitle("答え合わせ")
            .navigationBarTitleDisplayMode(.inline)
    }
}
