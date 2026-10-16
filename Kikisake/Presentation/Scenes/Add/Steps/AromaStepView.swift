//
//  AromaStepView.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/15.
//

import SwiftUI

/// [Step 3] 酒種・タイプに応じた「果実」「花・植物」「その他」の3分類による香り選択ビュー
public struct AromaStepView: View {
    @Bindable var viewModel: AddFlowViewModel

    public init(viewModel: AddFlowViewModel) {
        self.viewModel = viewModel
    }

    /// 香りの分類データ構造
    private struct AromaCategory: Identifiable {
        let id = UUID()
        let title: String
        let tags: [String]
    }

    /// ワインのJSONメタデータから現在のワインタイプを安全に取得するヘルパー
    private var currentWineType: String {
        guard viewModel.selectedCategory == .wine,
              let json = viewModel.sourceItem?.specificMetadataJSON ?? buildCurrentWineJSON(),
              let data = json.data(using: .utf8),
              let meta = try? JSONDecoder().decode(WineSpecificMetadata.self, from: data) else {
            return viewModel.wineType
        }
        return meta.wineType
    }

    private func buildCurrentWineJSON() -> String? {
        let meta = WineSpecificMetadata(wineType: viewModel.wineType, grapeVarieties: viewModel.grapeVarieties)
        guard let data = try? JSONEncoder().encode(meta) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// 資料（赤ワイン・白ワイン・日本酒のテイスティング用紙）に基づく3分類の香り定義
    private var aromaCategories: [AromaCategory] {
        switch viewModel.selectedCategory {
        case .wine:
            let type = currentWineType
            if type == "白" || type == "スパークリング" {
                // 白ワインの要素[cite: 54]
                return [
                    AromaCategory(title: "果実", tags: [
                        "柑橘類", "青リンゴ", "リンゴ", "洋梨", "マスカット", "花梨",
                        "パッションフルーツ", "白桃", "アプリコット", "パイナップル", "ライチ", "バナナ", "マンゴー"
                    ]),
                    AromaCategory(title: "花・植物", tags: [
                        "スイカズラ", "アカシア", "白バラ", "キンモクセイ", "菩提樹",
                        "ミント", "アニス", "ヴェルヴェーヌ", "草", "タイム", "フレッシュアーモンド", "ヘーゼルナッツ"
                    ]),
                    AromaCategory(title: "その他", tags: [
                        "石灰", "火打石", "貝殻", "鉱物", "海の香り", "トースト", "ヴァニラ",
                        "煙・薫製", "シナモン", "白胡椒", "コリアンダー", "丁字", "香木",
                        "ジンジャーブレッド", "ペトロール", "パン・ド・ミ", "乳製品",
                        "フェノール", "麝香", "花の蜜", "硫黄", "ワックス", "蜜蝋", "蜂蜜"
                    ])
                ]
            } else if type == "ロゼ" {
                // ロゼワイン（赤・白の要素をミックス）
                return [
                    AromaCategory(title: "果実", tags: ["ストロベリー", "ラズベリー", "チェリー", "赤スグリ", "桃", "柑橘類"]),
                    AromaCategory(title: "花・植物", tags: ["ローズ", "ゼラニウム", "グリーンリーフ", "アカシア"]),
                    AromaCategory(title: "その他", tags: ["キャンディ", "白コショウ", "ミネラル", "ハチミツ"])
                ]
            } else if type == "オレンジ" {
                // オレンジワイン（白ワイン＋スキンコンタクトの要素）
                return [
                    AromaCategory(title: "果実", tags: ["オレンジピール", "アプリコット", "ドライフルーツ", "マーマレード", "洋梨"]),
                    AromaCategory(title: "花・植物", tags: ["カモミール", "ドライフラワー", "紅茶の葉", "ハーブ"]),
                    AromaCategory(title: "その他", tags: ["ナッツ", "スパイス", "ハチミツ", "酵母", "鉱物", "トースト"])
                ]
            } else {
                // 赤ワインの要素[cite: 53]
                return [
                    AromaCategory(title: "果実", tags: [
                        "イチゴ", "ラズベリー", "ブルーベリー", "カシス", "ブラックベリー",
                        "ブラックチェリー", "干しプラム", "乾燥イチジク"
                    ]),
                    AromaCategory(title: "花・植物", tags: [
                        "バラ", "スミレ", "牡丹", "ゼラニウム", "ピーマン", "トマト",
                        "黒オリーブ", "メントール", "シダ", "ローリエ", "杉", "針葉樹", "ユーカリ", "ドライハーブ"
                    ]),
                    AromaCategory(title: "その他", tags: [
                        "タバコ", "紅茶", "スーボア", "キノコ", "トリュフ", "黒胡椒", "丁子",
                        "シナモン", "ナツメグ", "甘草", "ヴァニラ", "ロースト", "コーヒー",
                        "チョコレート", "煙・薫製", "動物的なニュアンス", "鉄分", "生肉",
                        "グリエ", "乾いた肉", "なめし皮", "樹脂", "ヨード", "ランシオ"
                    ])
                ]
            }

        case .sake:
            // 日本酒の要素[cite: 55]
            return [
                AromaCategory(title: "果実", tags: [
                    "グレープフルーツ", "黄色いリンゴ", "洋ナシ", "白桃", "バナナ",
                    "メロン", "マスカット", "ライチ", "パイナップル"
                ]),
                AromaCategory(title: "花・植物", tags: [
                    "スイカズラ", "スミレ", "アカシア", "菩提樹",
                    "セルフィーユ", "青竹", "新緑", "紅茶", "月桂樹の葉", "ヒノキ", "香木"
                ]),
                AromaCategory(title: "その他", tags: [
                    "ゴボウ", "朝鮮人参", "マッシュルーム", "椎茸", "丁字", "シナモン",
                    "ビターチョコレート", "栗", "クルミ", "アーモンド", "炊いた米",
                    "つきたての餅", "上新粉", "白玉団子", "杏仁豆腐", "生クリーム",
                    "サワークリーム", "ヨーグルト", "発酵バター", "クリームチーズ",
                    "粘土", "腐葉土", "石灰", "カラメル", "コーヒー", "醤油",
                    "ヨード香", "蜂蜜", "スモーク香", "カビ", "タマネギ", "熟成チーズ"
                ])
            ]

        case .beer:
            // ビール向け要素
            return [
                AromaCategory(title: "果実", tags: ["シトラス", "グレープフルーツ", "トロピカルフルーツ", "青りんご", "オレンジピール"]),
                AromaCategory(title: "花・植物", tags: ["ホップ", "ハーバル", "松やに", "フローラル", "スパイス"]),
                AromaCategory(title: "その他", tags: ["麦芽", "ロースト香", "キャラメル", "チョコレート", "ビスケット", "スモーキー", "酵母"])
            ]
        }
    }

    public var body: some View {
        Form {
            ForEach(aromaCategories) { category in
                Section(header: Text(category.title)) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10)], spacing: 10) {
                        ForEach(category.tags, id: \.self) { tag in
                            let isSelected = viewModel.selectedAromaTags.contains(tag)
                            Button {
                                if isSelected {
                                    viewModel.selectedAromaTags.removeAll { $0 == tag }
                                } else {
                                    viewModel.selectedAromaTags.append(tag)
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                        .font(.subheadline)
                                        .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                                    
                                    Text(tag)
                                        .font(.subheadline)
                                        .fontWeight(isSelected ? .bold : .regular)
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(isSelected ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

// プレビューで各種切り替えテストが可能
#Preview {
    struct PreviewWrapper: View {
        @State private var vm = AddFlowViewModel()

        var body: some View {
            NavigationStack {
                VStack(spacing: 0) {
                    Picker("カテゴリ", selection: $vm.selectedCategory) {
                        ForEach(BeverageCategory.allCases, id: \.self) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top)

                    if vm.selectedCategory == .wine {
                        Picker("ワインタイプ", selection: $vm.wineType) {
                            Text("赤").tag("赤")
                            Text("白").tag("白")
                            Text("ロゼ").tag("ロゼ")
                            Text("オレンジ").tag("オレンジ")
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }

                    AromaStepView(viewModel: vm)
                }
                .navigationTitle("香り選択プレビュー")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    return PreviewWrapper()
}
