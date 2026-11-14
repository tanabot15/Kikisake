//  CollectionMatrixModel.swift
//  Kikisake

import Foundation

/// 図鑑のペアリング項目（縦軸の産地 × 横軸の品種・米・スタイル）
public struct CollectionItemDefinition: Identifiable, Hashable {
    public let id = UUID()
    public let region: String          // 産地 (例: "フランス", "新潟県")
    public let targetElement: String   // 品種・米・スタイル (例: "ピノ・ノワール", "山田錦")
    public let category: BeverageCategory
    
    public init(region: String, targetElement: String, category: BeverageCategory) {
        self.region = region
        self.targetElement = targetElement
        self.category = category
    }
}

/// コンプリート図鑑のマスターマッピング管理
public enum CollectionMatrixDataSource {
    
    /// 指定した酒種の有効な掛け合わせリスト（図鑑の全コンプリート目標）
    public static func definitions(for category: BeverageCategory) -> [CollectionItemDefinition] {
        switch category {
        case .wine:
            return [
                // ==========================================
                // 1. フランス (約25種)
                // ==========================================
                .init(region: "フランス", targetElement: "カベルネ・ソーヴィニヨン", category: .wine),
                .init(region: "フランス", targetElement: "メルロ", category: .wine),
                .init(region: "フランス", targetElement: "ピノ・ノワール", category: .wine),
                .init(region: "フランス", targetElement: "シャルドネ", category: .wine),
                .init(region: "フランス", targetElement: "ソーヴィニヨン・ブラン", category: .wine),
                .init(region: "フランス", targetElement: "シラー / シラーズ", category: .wine),
                .init(region: "フランス", targetElement: "リースリング", category: .wine),
                .init(region: "フランス", targetElement: "カベルネ・フラン", category: .wine),
                .init(region: "フランス", targetElement: "プティ・ヴェルド", category: .wine),
                .init(region: "フランス", targetElement: "マルベック", category: .wine),
                .init(region: "フランス", targetElement: "ガルナッチャ / グレナッシュ", category: .wine),
                .init(region: "フランス", targetElement: "ムールヴェードル", category: .wine),
                .init(region: "フランス", targetElement: "ガメイ", category: .wine),
                .init(region: "フランス", targetElement: "カリニャン", category: .wine),
                .init(region: "フランス", targetElement: "タナ", category: .wine),
                .init(region: "フランス", targetElement: "シュナン・ブラン", category: .wine),
                .init(region: "フランス", targetElement: "セミヨン", category: .wine),
                .init(region: "フランス", targetElement: "ヴィオニエ", category: .wine),
                .init(region: "フランス", targetElement: "ピノ・グリ / ピノ-グリージョ", category: .wine),
                .init(region: "フランス", targetElement: "ゲヴュルツトラミネール", category: .wine),
                .init(region: "フランス", targetElement: "ミュスカデ", category: .wine),
                .init(region: "フランス", targetElement: "マルサンヌ", category: .wine),
                .init(region: "フランス", targetElement: "ルーサンヌ", category: .wine),
                .init(region: "フランス", targetElement: "シャスラ", category: .wine),
                .init(region: "フランス", targetElement: "ピノ・ブラン", category: .wine),

                // ==========================================
                // 2. イタリア (約20種)
                // ==========================================
                .init(region: "イタリア", targetElement: "サンジョヴェーゼ", category: .wine),
                .init(region: "イタリア", targetElement: "ネッビオーロ", category: .wine),
                .init(region: "イタリア", targetElement: "バルベラ", category: .wine),
                .init(region: "イタリア", targetElement: "ドルチェット", category: .wine),
                .init(region: "イタリア", targetElement: "アリアニコ", category: .wine),
                .init(region: "イタリア", targetElement: "ネグロアマーロ", category: .wine),
                .init(region: "イタリア", targetElement: "プリミティーヴォ / ジンファンデル", category: .wine),
                .init(region: "イタリア", targetElement: "コルヴィーナ", category: .wine),
                .init(region: "イタリア", targetElement: "ネレッロマスカレーゼ", category: .wine),
                .init(region: "イタリア", targetElement: "フラッパート", category: .wine),
                .init(region: "イタリア", targetElement: "サグランド", category: .wine),
                .init(region: "イタリア", targetElement: "ピノ・グリ / ピノ-グリージョ", category: .wine),
                .init(region: "イタリア", targetElement: "シャルドネ", category: .wine),
                .init(region: "イタリア", targetElement: "ヴェルメンティーノ", category: .wine),
                .init(region: "イタリア", targetElement: "ガヴィ / コルテーゼ", category: .wine),
                .init(region: "イタリア", targetElement: "グレラ (プロセッコ)", category: .wine),
                .init(region: "イタリア", targetElement: "ガルガネガ", category: .wine),
                .init(region: "イタリア", targetElement: "ペコリーノ", category: .wine),
                .init(region: "イタリア", targetElement: "パッセリーナ", category: .wine),
                .init(region: "イタリア", targetElement: "フィアーノ", category: .wine),

                // ==========================================
                // 3. スペイン & ポルトガル (約12種)
                // ==========================================
                .init(region: "スペイン", targetElement: "テンプラニーリョ", category: .wine),
                .init(region: "スペイン", targetElement: "ガルナッチャ / グレナッシュ", category: .wine),
                .init(region: "スペイン", targetElement: "メンシア", category: .wine),
                .init(region: "スペイン", targetElement: "アルバリーニョ", category: .wine),
                .init(region: "スペイン", targetElement: "ヴェルデホ", category: .wine),
                .init(region: "スペイン", targetElement: "シャルドネ", category: .wine),
                .init(region: "ポルトガル", targetElement: "トゥーリガイ nacional", category: .wine),
                .init(region: "ポルトガル", targetElement: "ティラ", category: .wine),
                .init(region: "ポルトガル", targetElement: "アルリーニョ", category: .wine),
                .init(region: "ポルトガル", targetElement: "トウリガ・フランカ", category: .wine),
                .init(region: "ポルトガル", targetElement: "ロウレイロ", category: .wine),
                .init(region: "ポルトガル", targetElement: "フェルナン・ピレス", category: .wine),

                // ==========================================
                // 4. ドイツ & オーストリア & スイス & ハンガリー (約12種)
                // ==========================================
                .init(region: "ドイツ", targetElement: "リースリング", category: .wine),
                .init(region: "ドイツ", targetElement: "シュペートブルクンダー (ピノ・ノワール)", category: .wine),
                .init(region: "ドイツ", targetElement: "ヴァイスブルクンダー (ピノ・ブラン)", category: .wine),
                .init(region: "ドイツ", targetElement: "グラウブルクンダー (ピノ・グリ)", category: .wine),
                .init(region: "ドイツ", targetElement: "シルヴァーナー", category: .wine),
                .init(region: "オーストリア", targetElement: "グリューナー・フェルトリーナー", category: .wine),
                .init(region: "オーストリア", targetElement: "ブラウフランキッシュ", category: .wine),
                .init(region: "オーストリア", targetElement: "ツヴァイゲルトレーベ", category: .wine),
                .init(region: "スイス", targetElement: "シャスラ", category: .wine),
                .init(region: "スイス", targetElement: "ピノ・ノワール", category: .wine),
                .init(region: "ハンガリー", targetElement: "フルミント", category: .wine),
                .init(region: "ハンガリー", targetElement: "ハルシュレヴェリュ", category: .wine),

                // ==========================================
                // 5. アメリカ & カナダ & 南米 (約12種)
                // ==========================================
                .init(region: "アメリカ", targetElement: "カベルネ・ソーヴィニヨン", category: .wine),
                .init(region: "アメリカ", targetElement: "シャルドネ", category: .wine),
                .init(region: "アメリカ", targetElement: "ピノ・ノワール", category: .wine),
                .init(region: "アメリカ", targetElement: "プリミティーヴォ / ジンファンデル", category: .wine),
                .init(region: "アメリカ", targetElement: "メルロ", category: .wine),
                .init(region: "アメリカ", targetElement: "シラー / シラーズ", category: .wine),
                .init(region: "アルゼンチン", targetElement: "マルベック", category: .wine),
                .init(region: "アルゼンチン", targetElement: "トロンテス", category: .wine),
                .init(region: "チリ", targetElement: "カルメネール", category: .wine),
                .init(region: "チリ", targetElement: "ソーヴィニヨン・ブラン", category: .wine),
                .init(region: "カナダ", targetElement: "リースリング", category: .wine),
                .init(region: "カナダ", targetElement: "ヴィダル", category: .wine),

                // ==========================================
                // 6. オーストラリア & ニュージーランド & 南アフリカ (約10種)
                // ==========================================
                .init(region: "オーストラリア", targetElement: "シラー / シラーズ", category: .wine),
                .init(region: "オーストラリア", targetElement: "シャルドネ", category: .wine),
                .init(region: "オーストラリア", targetElement: "カベルネ・ソーヴィニヨン", category: .wine),
                .init(region: "ニュージーランド", targetElement: "ソーヴィニヨン・ブラン", category: .wine),
                .init(region: "ニュージーランド", targetElement: "ピノ・ノワール", category: .wine),
                .init(region: "南アフリカ", targetElement: "シュナン・ブラン", category: .wine),
                .init(region: "南アフリカ", targetElement: "ピノタージュ", category: .wine),
                .init(region: "南アフリカ", targetElement: "シラー / シラーズ", category: .wine),

                // ==========================================
                // 7. 日本 & ニア・マニアック産地 (約10種)
                // ==========================================
                .init(region: "日本", targetElement: "甲州", category: .wine),
                .init(region: "日本", targetElement: "マスカット・ベーリーA", category: .wine),
                .init(region: "日本", targetElement: "山葡萄", category: .wine),
                .init(region: "日本", targetElement: "ナイアガラ", category: .wine),
                .init(region: "ギリシャ", targetElement: "アッシルト", category: .wine),
                .init(region: "ジョージア", targetElement: "カツィツェリ", category: .wine),
                .init(region: "ジョージア", targetElement: "サペラヴィ", category: .wine),
                .init(region: "レバノン", targetElement: "サンソー", category: .wine),
                .init(region: "イギリス", targetElement: "シャルドネ", category: .wine),
                .init(region: "イギリス", targetElement: "ピノ・ノワール", category: .wine)
            ]
            
        case .sake:
            return [
                // ==========================================
                // 1. 新潟・東北の銘酒蔵 (約25種)
                // ==========================================
                .init(region: "新潟県", targetElement: "山田錦", category: .sake),
                .init(region: "新潟県", targetElement: "五百万石", category: .sake),
                .init(region: "新潟県", targetElement: "越淡麗", category: .sake),
                .init(region: "新潟県", targetElement: "こいみどり", category: .sake),
                .init(region: "新潟県", targetElement: "一般米（食用米）", category: .sake),
                .init(region: "山形県", targetElement: "出羽燦々", category: .sake),
                .init(region: "山形県", targetElement: "美山錦", category: .sake),
                .init(region: "山形県", targetElement: "雄町", category: .sake),
                .init(region: "山形県", targetElement: "雪女神", category: .sake),
                .init(region: "山形県", targetElement: "羽州誉", category: .sake),
                .init(region: "秋田県", targetElement: "秋田酒こまち", category: .sake),
                .init(region: "秋田県", targetElement: "美山錦", category: .sake),
                .init(region: "秋田県", targetElement: "一輪", category: .sake),
                .init(region: "宮城県", targetElement: "蔵の華", category: .sake),
                .init(region: "宮城県", targetElement: "山田錦", category: .sake),
                .init(region: "福島県", targetElement: "夢の香", category: .sake),
                .init(region: "福島県", targetElement: "山田錦", category: .sake),
                .init(region: "福島県", targetElement: "五百万石", category: .sake),
                .init(region: "岩手県", targetElement: "ぎんおとめ", category: .sake),
                .init(region: "岩手県", targetElement: "結の香", category: .sake),
                .init(region: "青森県", targetElement: "華吹雪", category: .sake),
                .init(region: "青森県", targetElement: "華想い", category: .sake),
                .init(region: "北海道", targetElement: "きたしずく", category: .sake),
                .init(region: "北海道", targetElement: "彗星", category: .sake),
                .init(region: "北海道", targetElement: "吟風", category: .sake),

                // ==========================================
                // 2. 関東・甲信越の酒処 (約20種)
                // ==========================================
                .init(region: "長野県", targetElement: "美山錦", category: .sake),
                .init(region: "長野県", targetElement: "金紋錦", category: .sake),
                .init(region: "長野県", targetElement: "ひとごこち", category: .sake),
                .init(region: "長野県", targetElement: "山恵錦", category: .sake),
                .init(region: "長野県", targetElement: "山田錦", category: .sake),
                .init(region: "山梨県", targetElement: "山田錦", category: .sake),
                .init(region: "山梨県", targetElement: "一般米（食用米）", category: .sake),
                .init(region: "静岡県", targetElement: "誉富士", category: .sake),
                .init(region: "静岡県", targetElement: "山田錦", category: .sake),
                .init(region: "富山県", targetElement: "五百万石", category: .sake),
                .init(region: "富山県", targetElement: "雄山錦", category: .sake),
                .init(region: "石川県", targetElement: "石川門", category: .sake),
                .init(region: "石川県", targetElement: "五百万石", category: .sake),
                .init(region: "福井県", targetElement: "五百万石", category: .sake),
                .init(region: "福井県", targetElement: "さけににしき", category: .sake),
                .init(region: "群馬県", targetElement: "舞風", category: .sake),
                .init(region: "栃木県", targetElement: "とちぎ酒14", category: .sake),
                .init(region: "茨城県", targetElement: "常盤錦", category: .sake),
                .init(region: "埼玉県", targetElement: "さけ武蔵", category: .sake),
                .init(region: "東京都", targetElement: "一般米（食用米）", category: .sake),

                // ==========================================
                // 3. 関西（近畿・中国・四国）の酒米文化 (約25種)
                // ==========================================
                .init(region: "兵庫県", targetElement: "山田錦", category: .sake),
                .init(region: "兵庫県", targetElement: "雄町", category: .sake),
                .init(region: "兵庫県", targetElement: "兵庫北錦", category: .sake),
                .init(region: "京都府", targetElement: "山田錦", category: .sake),
                .init(region: "京都府", targetElement: "祝", category: .sake),
                .init(region: "京都府", targetElement: "五百万石", category: .sake),
                .init(region: "滋賀県", targetElement: "玉栄", category: .sake),
                .init(region: "滋賀県", targetElement: "秋の詩", category: .sake),
                .init(region: "奈良県", targetElement: "露葉風", category: .sake),
                .init(region: "奈良県", targetElement: "山田錦", category: .sake),
                .init(region: "三重県", targetElement: "神の穂", category: .sake),
                .init(region: "三重県", targetElement: "山田錦", category: .sake),
                .init(region: "岡山県", targetElement: "雄町", category: .sake),
                .init(region: "岡山県", targetElement: "赤磐雄町", category: .sake),
                .init(region: "広島県", targetElement: "八反錦", category: .sake),
                .init(region: "広島県", targetElement: "千本錦", category: .sake),
                .init(region: "山口県", targetElement: "山田錦", category: .sake),
                .init(region: "山口県", targetElement: "西都の雫", category: .sake),
                .init(region: "島根県", targetElement: "神の舞", category: .sake),
                .init(region: "島根県", targetElement: "佐香錦", category: .sake),
                .init(region: "鳥取県", targetElement: "強力", category: .sake),
                .init(region: "鳥取県", targetElement: "山田錦", category: .sake),
                .init(region: "高知県", targetElement: "吟の夢", category: .sake),
                .init(region: "高知県", targetElement: "松山三井", category: .sake),
                .init(region: "愛媛県", targetElement: "しずく媛", category: .sake),

                // ==========================================
                // 4. 九州・その他のレア地域 (約10種)
                // ==========================================
                .init(region: "福岡県", targetElement: "夢一献", category: .sake),
                .init(region: "福岡県", targetElement: "山田錦", category: .sake),
                .init(region: "佐賀県", targetElement: "山田錦", category: .sake),
                .init(region: "佐賀県", targetElement: "佐賀の華", category: .sake),
                .init(region: "熊本県", targetElement: "華錦", category: .sake),
                .init(region: "大分県", targetElement: "ひのひかり", category: .sake),
                .init(region: "宮崎県", targetElement: "一般米（食用米）", category: .sake),
                .init(region: "鹿児島県", targetElement: "一般米（食用米）", category: .sake),
                .init(region: "徳島県", targetElement: "阿波山田錦", category: .sake),
                .init(region: "香川県", targetElement: "オオセト", category: .sake)
            ]
            
        case .beer:
            return [
                // ==========================================
                // 1. ドイツ・伝統ラガー & エール (12種)
                // ==========================================
                .init(region: "ドイツ", targetElement: "ピルスナー", category: .beer),
                .init(region: "ドイツ", targetElement: "ボヘミアン・ピルスナー", category: .beer),
                .init(region: "ドイツ", targetElement: "デュンケル", category: .beer),
                .init(region: "ドイツ", targetElement: "シュバルツ", category: .beer),
                .init(region: "ドイツ", targetElement: "ボック", category: .beer),
                .init(region: "ドイツ", targetElement: "ドッペルボック", category: .beer),
                .init(region: "ドイツ", targetElement: "メルツェン / オクトーバーフェスト", category: .beer),
                .init(region: "ドイツ", targetElement: "ラオハス（燻製ビール）", category: .beer),
                .init(region: "ドイツ", targetElement: "ケルシュ", category: .beer),
                .init(region: "ドイツ", targetElement: "ヴァイツェン（ヘーフェヴァイツェン）", category: .beer),
                .init(region: "ドイツ", targetElement: "アルトビール", category: .beer),
                .init(region: "チェコ", targetElement: "ピルスナー", category: .beer),

                // ==========================================
                // 2. ベルギー・トラピスト & 修道院系 (10種)
                // ==========================================
                .init(region: "ベルギー", targetElement: "ベルジャンホワイト（ヴィットビール）", category: .beer),
                .init(region: "ベルギー", targetElement: "セゾン", category: .beer),
                .init(region: "ベルギー", targetElement: "ベルジャン・ブロンド", category: .beer),
                .init(region: "ベルギー", targetElement: "ベルジャン・デュペル", category: .beer),
                .init(region: "ベルギー", targetElement: "ベルジャン・トリプル", category: .beer),
                .init(region: "ベルギー", targetElement: "ベルジャン・クアドルペル", category: .beer),
                .init(region: "ベルギー", targetElement: "ランビック", category: .beer),
                .init(region: "ベルギー", targetElement: "サワーエール", category: .beer),
                .init(region: "ベルギー", targetElement: "フラダース・レッドエール", category: .beer),
                .init(region: "ベルギー", targetElement: "フルーツビール", category: .beer),

                // ==========================================
                // 3. イギリス・伝統エール & スタウト (8種)
                // ==========================================
                .init(region: "イギリス", targetElement: "イングリッシュ・ペールエール", category: .beer),
                .init(region: "イギリス", targetElement: "ビター / ESB", category: .beer),
                .init(region: "イギリス", targetElement: "イングリッシュ・IPA", category: .beer),
                .init(region: "イギリス", targetElement: "ポーター", category: .beer),
                .init(region: "イギリス", targetElement: "スタウト", category: .beer),
                .init(region: "イギリス", targetElement: "インペリアルスタウト", category: .beer),
                .init(region: "アイルランド", targetElement: "アイリッシュ・スタウト", category: .beer),
                .init(region: "イギリス", targetElement: "バーレイワイン", category: .beer),

                // ==========================================
                // 4. アメリカ・クラフトビール (12種)
                // ==========================================
                .init(region: "アメリカ", targetElement: "IPA", category: .beer),
                .init(region: "アメリカ", targetElement: "ヘイジーIPA（ニューイングランドIPA）", category: .beer),
                .init(region: "アメリカ", targetElement: "ダブルIPA（インペリアルIPA）", category: .beer),
                .init(region: "アメリカ", targetElement: "トリプルIPA", category: .beer),
                .init(region: "アメリカ", targetElement: "セッションIPA", category: .beer),
                .init(region: "アメリカ", targetElement: "ブラックIPA", category: .beer),
                .init(region: "アメリカ", targetElement: "アメリカン・ペールエール", category: .beer),
                .init(region: "アメリカ", targetElement: "アメリカン・ラガー", category: .beer),
                .init(region: "アメリカ", targetElement: "サワーエール", category: .beer),
                .init(region: "アメリカ", targetElement: "ゴーゼ", category: .beer),
                .init(region: "アメリカ", targetElement: "ミルクスタウト（オートミールスタウト）", category: .beer),
                .init(region: "アメリカ", targetElement: "フルーツビール", category: .beer),

                // ==========================================
                // 5. 日本・その他新興クラフトシーン (8種)
                // ==========================================
                .init(region: "日本", targetElement: "ピルスナー", category: .beer),
                .init(region: "日本", targetElement: "ペールエール", category: .beer),
                .init(region: "日本", targetElement: "IPA", category: .beer),
                .init(region: "日本", targetElement: "ヘイジーIPA（ニューイングランドIPA）", category: .beer),
                .init(region: "日本", targetElement: "ヴァイツェン（ヘーフェヴァイツェン）", category: .beer),
                .init(region: "日本", targetElement: "フルーツビール", category: .beer),
                .init(region: "デンマーク", targetElement: "インペリアルスタウト", category: .beer),
                .init(region: "エストニア", targetElement: "ポーター", category: .beer)
            ]
        }
    }
}
