//
//  RegionPresetOptions.swift
//  Kikisake
//

import Foundation

/// 階層型産地データの構造体
public struct RegionHierarchy: Identifiable, Hashable {
    public let id: UUID
    public let parent: String
    public let children: [String]

    public init(id: UUID = UUID(), parent: String, children: [String] = []) {
        self.id = id
        self.parent = parent
        self.children = children
    }
}

/// 共通の生産地プリセットプロバイダ
public enum RegionPresetOptions {
    private static func hierarchy(
        _ parent: LocalizedStringResource,
        children: [LocalizedStringResource] = []
    ) -> RegionHierarchy {
        RegionHierarchy(
            parent: String(localized: parent),
            children: children.map { String(localized: $0) }
        )
    }

    /// 酒種に応じた階層型生産地リストを取得
    public static func regions(for category: BeverageCategory) -> [RegionHierarchy] {
        switch category {
        case .wine: wineRegions
        case .sake: sakeRegions
        case .beer: beerRegions
        }
    }

    // MARK: - 1. ワイン産地

    private static let wineRegions: [RegionHierarchy] = [
        hierarchy("フランス", children: [
            "シャンパーニュ", "ブルゴーニュ", "ボージョレ", "ボルドー", "ロワール", "アルザス",
            "コート・デュ・ローヌ", "プロヴァンス", "ラングドック", "ルーション",
            "南西地方 (シュッド・ウエスト)", "ジュラ", "サヴォワ", "コルス (コルシカ)"
        ]),
        hierarchy("イタリア", children: [
            "ヴァッレ・ダオスタ", "ピエモンテ", "リグーリア", "ロンバルディア",
            "トレンティーノ・アルト・アディジェ", "ヴェネト", "フリウリ・ヴェネツィア・ジューリア",
            "エミリア・ロマーニャ", "トスカーナ", "ウンブリア", "マルケ", "ラツィオ",
            "アブルッツォ", "モリーゼ", "カンパーニア", "プーリア", "バジリカータ",
            "カラブリア", "シチリア", "サルデーニャ"
        ]),
        hierarchy("ドイツ", children: [
            "アール", "ミッテルライン", "モーゼル", "ラインガウ", "ナーエ", "ラインヘッセン",
            "ファルツ", "ヘッシシェ・ベルクシュトラーセ", "フランケン", "バーデン",
            "ヴュルテンベルク", "ザーレ・ウンストルート", "ザクセン"
        ]),
        hierarchy("スペイン", children: [
            "リオハ", "リベラ・デル・ドゥエロ", "ルエダ", "トロ", "ビエルソ", "リアス・バイシャス",
            "プリオラート", "ペネデス (カバ)", "ラ・マンチャ", "フミーリャ", "ヘレス (シェリー)"
        ]),
        hierarchy("ポルトガル", children: [
            "ミーニョ (ヴィーニョ・ヴェルデ)", "ドウロ (ポート)", "ダン", "バイラーダ",
            "リスボア", "セトゥーバル", "アレンテージョ", "マデイラ"
        ]),
        hierarchy("オーストリア", children: [
            "ニーダーエスターライヒ (ヴァッハウ / カンプタール)", "ブルゲンラント",
            "シュタイヤーマルク", "ウィーン"
        ]),
        hierarchy("スイス", children: [
            "ヴァレー", "ヴォー (ラヴォー)", "ジュネーヴ", "ティチーノ", "グラウビュンデン"
        ]),
        hierarchy("ハンガリー", children: ["トカイ", "エゲル", "ヴィッラーニ"]),
        hierarchy("アメリカ", children: [
            "カリフォルニア (ナパ・ヴァレー)", "カリフォルニア (ソノマ)",
            "カリフォルニア (セントラル・コースト / パソ・ロブレス)",
            "カリフォルニア (サンタ・バーバラ)", "オレゴン (ウィラメット・ヴァレー)",
            "ワシントン (コロンビア・ヴァレー)", "ニューヨーク (フィンガー・レイクス)"
        ]),
        hierarchy("カナダ", children: [
            "オンタリオ (ナイアガラ・ペニンシュラ)",
            "ブリティッシュ・コロンビア (オカナガン・ヴァレー)"
        ]),
        hierarchy("チリ", children: [
            "カサブランカ・ヴァレー", "サン・アントニオ・ヴァレー", "アコンカグア・ヴァレー",
            "マイポ・ヴァレー", "カチャポアル・ヴァレー", "コルチャグア・ヴァレー",
            "クリコ・ヴァレー", "マウレ・ヴァレー", "イタタ・ヴァレー"
        ]),
        hierarchy("アルゼンチン", children: [
            "サルタ (カファジャテ)", "サン・フアン", "メンドーサ",
            "パタゴニア (リオ・ネグロ / ネウケン)"
        ]),
        hierarchy("ウルグアイ", children: ["カネロネス", "マルドナド"]),
        hierarchy("オーストラリア", children: [
            "バロッサ・ヴァレー", "イーデン・ヴァレー", "クレア・ヴァレー",
            "マクラーレン・ヴェール", "クナワラ", "ヤラ・ヴァレー",
            "モーニントン・ペニンシュラ", "ハンター・ヴァレー", "マーガレット・リヴァー",
            "タスマニア"
        ]),
        hierarchy("ニュージーランド", children: [
            "ギズボーン", "ホークス・ベイ", "マーティンボロ (ワイララパ)", "マールボロ",
            "ネルソン", "ノース・カンタベリー (ワイパラ)", "セントラル・オタゴ"
        ]),
        hierarchy("南アフリカ", children: [
            "ステレンボッシュ", "パール", "フランシュック", "スワートランド",
            "コンスタンシア", "ウォーカー・ベイ", "エルギン"
        ]),
        hierarchy("日本", children: [
            "北海道", "岩手県", "山形県", "新潟県", "山梨県", "長野県", "兵庫県", "宮崎県"
        ]),
        hierarchy("ギリシャ", children: ["サントリーニ", "ネメア", "ナウサ", "マンティニア"]),
        hierarchy("ジョージア", children: ["カヘティ", "カルトリ", "イメレティ"]),
        hierarchy("レバノン", children: ["ベッカー高原"]),
        hierarchy("イギリス", children: ["サセックス", "ケント", "ハンプシャー"])
    ]

    // MARK: - 2. 日本酒産地

    private static let sakeRegions: [RegionHierarchy] = [
        hierarchy("北海道", children: ["道央 (札幌・小樽)", "道北 (旭川・上川)", "道東 (釧路・根室)"]),
        hierarchy("青森県", children: ["津軽 (弘前・黒石)", "南部 (八戸・十和田)"]),
        hierarchy("岩手県", children: ["盛岡・紫波 (南部杜氏)", "県南 (花巻・一関)"]),
        hierarchy("宮城県", children: ["県北 (大崎・栗原)", "仙台・塩竈"]),
        hierarchy("秋田県", children: ["中央 (秋田)", "県南 (横手・湯沢)", "県北 (能代)"]),
        hierarchy("山形県", children: ["村山 (山形)", "庄内 (酒田・鶴岡)", "置賜 (米沢)", "最上 (新庄)"]),
        hierarchy("福島県", children: ["会津", "中通り", "浜通り"]),
        hierarchy("茨城県", children: ["県北 (常陸太田・日立)", "県西 (結城・筑西)"]),
        hierarchy("栃木県", children: ["県北 (大田原・那須)", "県南 (小山・栃木)"]),
        hierarchy("群馬県", children: ["北毛 (沼田・川場)", "西毛 (高崎・藤岡)"]),
        hierarchy("埼玉県", children: ["県北 (熊谷・行田)", "秩父"]),
        hierarchy("千葉県", children: ["北総 (佐原・成田)", "上総・房総"]),
        hierarchy("東京都", children: ["多摩 (福生・あきる野・青梅)", "23区"]),
        hierarchy("神奈川県", children: ["県西 (足柄・小田原)", "県央 (海老名・厚木)"]),
        hierarchy("新潟県", children: ["中越 (長岡・魚沼)", "下越 (新潟・村上)", "上越 (上越)", "佐渡"]),
        hierarchy("富山県", children: ["呉東 (富山・黒部)", "呉西 (高岡・砺波)"]),
        hierarchy("石川県", children: ["加賀・白山", "能登"]),
        hierarchy("福井県", children: ["嶺北 (永平寺・大野)", "嶺南 (小浜・敦賀)"]),
        hierarchy("山梨県", children: ["峡北 (北杜・韮崎)", "国中 (甲府・大月)"]),
        hierarchy("長野県", children: ["北信", "中信", "南信", "東信 (佐久・上田)"]),
        hierarchy("岐阜県", children: ["飛騨 (高山・古川)", "美濃 (大垣・多治見)"]),
        hierarchy("静岡県", children: ["中部 (静岡・藤枝・島田)", "東部 (沼津・富士)", "西部 (浜松・掛川)"]),
        hierarchy("愛知県", children: ["知多 (半田・常滑)", "三河 (岡崎・設楽)"]),
        hierarchy("三重県", children: ["伊賀", "北勢 (四日市・鈴鹿)"]),
        hierarchy("滋賀県", children: ["湖南 (甲賀・草津)", "湖北・湖東 (長浜・彦根)"]),
        hierarchy("京都府", children: ["伏見", "丹後・丹波"]),
        hierarchy("大阪府", children: ["北摂 (池田・高槻)", "河内 (交野・富田林)"]),
        hierarchy("兵庫県", children: ["灘五郷", "播州 (西脇・加東・姫路)", "丹波・但馬"]),
        hierarchy("奈良県", children: ["奈良・天理", "宇陀・吉野"]),
        hierarchy("和歌山県", children: ["紀北 (海南・かつらぎ)", "紀南 (田辺・新宮)"]),
        hierarchy("鳥取県", children: ["中部 (倉吉)", "東部・西部 (鳥取・米子)"]),
        hierarchy("島根県", children: ["出雲 (出雲・松江)", "石見 (大田・浜田)"]),
        hierarchy("岡山県", children: ["備前 (赤磐・瀬戸内)", "備中 (倉敷・高梁)", "美作 (津山)"]),
        hierarchy("広島県", children: ["西条 (東広島)", "呉・竹原", "備後 (福山・三次)"]),
        hierarchy("山口県", children: ["岩国・周南", "萩・長門"]),
        hierarchy("徳島県", children: ["吉野川流域 (阿波・美馬)"]),
        hierarchy("香川県", children: ["中讃・西讃 (琴平・観音寺)"]),
        hierarchy("愛媛県", children: ["東予 (西条・今治)", "南予 (宇和島・内子)"]),
        hierarchy("高知県", children: ["土佐"]),
        hierarchy("福岡県", children: ["城島 (久留米)", "筑前・筑後"]),
        hierarchy("佐賀県", children: ["鹿島・嬉野", "唐津・小城"]),
        hierarchy("長崎県", children: ["平戸・壱岐", "島原・佐世保"]),
        hierarchy("熊本県", children: ["熊本・菊池", "球磨"]),
        hierarchy("大分県", children: ["日田・玖珠", "国東・宇佐"]),
        hierarchy("宮崎県", children: ["高千穂・延岡"]),
        hierarchy("鹿児島県", children: ["奄美・薩摩"]),
        hierarchy("沖縄県", children: ["本島 (うるま)"])
    ]

    // MARK: - 3. ビール産地

    private static let beerRegions: [RegionHierarchy] = [
        hierarchy("ドイツ", children: [
            "バイエルン (ミュンヘン)", "フランケン (バンベルク)",
            "ノルトライン (ケルン・デュッセルドルフ)", "ドルトムント", "ベルリン"
        ]),
        hierarchy("ベルギー", children: [
            "フランダース", "ワロン", "ブリュッセル", "パヨッテンラント (ランビック)"
        ]),
        hierarchy("イギリス", children: [
            "イングランド (ロンドン・マンチェスター)", "スコットランド (エジンバラ・アバディーン)",
            "バートン・オン・トレント"
        ]),
        hierarchy("アメリカ", children: [
            "西海岸 (ポートランド・サンディエゴ)", "ニューイングランド (バーモント・マサチューセッツ)",
            "中西部 (シカゴ・ミシガン)", "コロラド (デンバー)"
        ]),
        hierarchy("チェコ", children: ["プルゼニ (ピルゼン)", "プラハ", "モラヴィア"]),
        hierarchy("日本", children: [
            "北海道", "岩手県", "埼玉県", "東京都", "神奈川県", "長野県",
            "静岡県", "三重県", "京都府", "大阪府", "鳥取県", "沖縄県"
        ]),
        hierarchy("デンマーク", children: ["コペンハーゲン"]),
        hierarchy("オランダ", children: ["アムステルダム", "アイントホーフェン"]),
        hierarchy("カナダ", children: [
            "ブリティッシュコロンビア (バンクーバー)", "ケベック (モントリオール)",
            "オンタリオ (トロント)"
        ]),
        hierarchy("アイルランド", children: ["ダブリン", "コーク"]),
        hierarchy("オーストラリア", children: ["ヴィクトリア (メルボルン)", "ニューサウスウェールズ (シドニー)"]),
        hierarchy("ニュージーランド", children: ["ウェリントン", "ネルソン"]),
        hierarchy("ノルウェー", children: ["オスロ", "スタヴァンゲル"]),
        hierarchy("スウェーデン", children: ["ストックホルム", "ヨーテボリ"]),
        hierarchy("エストニア", children: ["タリン"]),
        hierarchy("イタリア", children: ["ピエモンテ", "ロンバルディア"]),
        hierarchy("スペイン", children: ["バルセロナ", "バスク"])
    ]
}
