//  RegionPresetOptions.swift
//  Kikisake

import Foundation

/// 階層型産地データの構造体
public struct RegionHierarchy: Identifiable, Hashable {
    public let id = UUID()
    public let parent: String       // 親エリア (例: "フランス", "新潟県")
    public let children: [String]   // 子エリアリスト (例: ["ブルゴーニュ", "ボルドー", ...])

    public init(parent: String, children: [String] = []) {
        self.parent = parent
        self.children = children
    }
}

/// 共通の生産地プリセットプロバイダ
public enum RegionPresetOptions {

    /// 酒種に応じた階層型生産地リストを取得
    public static func regions(for category: BeverageCategory) -> [RegionHierarchy] {
        switch category {
        case .wine:
            return wineRegions
        case .sake:
            return sakeRegions
        case .beer:
            return beerRegions
        }
    }

    // MARK: - 1. ワイン産地 (主要国〜マニアックな生産国 > 地方)
    private static var wineRegions: [RegionHierarchy] {
        [
            RegionHierarchy(parent: String(localized: "フランス"), children: [
                String(localized: "ボルドー"),
                String(localized: "ブルゴーニュ"),
                String(localized: "シャンパーニュ"),
                String(localized: "ローヌ"),
                String(localized: "ロワール"),
                String(localized: "アルザス"),
                String(localized: "ラングドック・ルーション"),
                String(localized: "プロヴァンス"),
                String(localized: "ジュラ・サヴォワ"),
                String(localized: "南西地方 (シュッド・ウエスト)"),
                String(localized: "コルシカ")
            ]),
            RegionHierarchy(parent: String(localized: "イタリア"), children: [
                String(localized: "ピエモンテ"),
                String(localized: "トスカーナ"),
                String(localized: "ヴェネト"),
                String(localized: "シチリア"),
                String(localized: "フリウリ・ヴェネツィア・ジューリア"),
                String(localized: "ロンバルディア"),
                String(localized: "トレンティーノ・アルト・アディジェ"),
                String(localized: "プーリア"),
                String(localized: "カンパーニア"),
                String(localized: "アブルッツォ"),
                String(localized: "ウンブリア"),
                String(localized: "サルデーニャ")
            ]),
            RegionHierarchy(parent: String(localized: "アメリカ"), children: [
                String(localized: "カリフォルニア (ナパ・ヴァレー)"),
                String(localized: "カリフォルニア (ソノマ)"),
                String(localized: "カリフォルニア (パソ・ロブレス)"),
                String(localized: "カリフォルニア (サンタ・バーバラ)"),
                String(localized: "オレゴン (ウィラメット・ヴァレー)"),
                String(localized: "ワシントン (コロンビア・ヴァレー)"),
                String(localized: "ニューヨーク (フィンガー・レイクス)")
            ]),
            RegionHierarchy(parent: String(localized: "日本"), children: [
                String(localized: "山梨"),
                String(localized: "長野"),
                String(localized: "北海道"),
                String(localized: "山形"),
                String(localized: "岩手"),
                String(localized: "新潟"),
                String(localized: "兵庫"),
                String(localized: "宮崎")
            ]),
            RegionHierarchy(parent: String(localized: "スペイン"), children: [
                String(localized: "リオハ"),
                String(localized: "リベラ・デル・ドゥエロ"),
                String(localized: "プリオラート"),
                String(localized: "カタルーニャ"),
                String(localized: "リアス・バイシャス"),
                String(localized: "トロ"),
                String(localized: "ビエルソ"),
                String(localized: "ヘレス (シェリー)")
            ]),
            RegionHierarchy(parent: String(localized: "ドイツ"), children: [
                String(localized: "モーゼル"),
                String(localized: "ラインガウ"),
                String(localized: "ファルツ"),
                String(localized: "ラインヘッセン"),
                String(localized: "バーデン"),
                String(localized: "フランケン"),
                String(localized: "アール")
            ]),
            RegionHierarchy(parent: String(localized: "オーストラリア"), children: [
                String(localized: "バロッサ・ヴァレー"),
                String(localized: "マーガレット・リヴァー"),
                String(localized: "ヤラ・ヴァレー"),
                String(localized: "マクラーレン・ヴェール"),
                String(localized: "ハンター・ヴァレー"),
                String(localized: "クナワラ"),
                String(localized: "タスマニア")
            ]),
            RegionHierarchy(parent: String(localized: "ニュージーランド"), children: [
                String(localized: "マールボロ"),
                String(localized: "セントラル・オタゴ"),
                String(localized: "ホークス・ベイ"),
                String(localized: "マーティンボロ")
            ]),
            RegionHierarchy(parent: String(localized: "チリ"), children: [
                String(localized: "マイポ・ヴァレー"),
                String(localized: "カサブランカ・ヴァレー"),
                String(localized: "コルチャグア・ヴァレー"),
                String(localized: "アコンカグア・ヴァレー"),
                String(localized: "イタタ・ヴァレー")
            ]),
            RegionHierarchy(parent: String(localized: "アルゼンチン"), children: [
                String(localized: "メンドーサ"),
                String(localized: "サルタ"),
                String(localized: "パタゴニア")
            ]),
            // --- マイナー・新興・伝統生産国 ---
            RegionHierarchy(parent: String(localized: "ポルトガル"), children: [
                String(localized: "ドウロ"),
                String(localized: "ヴィーニョ・ヴェルデ"),
                String(localized: "アレンテージョ"),
                String(localized: "ダン"),
                String(localized: "マデイラ")
            ]),
            RegionHierarchy(parent: String(localized: "南アフリカ"), children: [
                String(localized: "ステレンボッシュ"),
                String(localized: "スワートランド"),
                String(localized: "ウォーカー・ベイ"),
                String(localized: "コンスタンシア")
            ]),
            RegionHierarchy(parent: String(localized: "オーストリア"), children: [
                String(localized: "ヴァッハウ"),
                String(localized: "カンプタール"),
                String(localized: "ブルゲンラント")
            ]),
            RegionHierarchy(parent: String(localized: "ギリシャ"), children: [
                String(localized: "サントリーニ"),
                String(localized: "ネメア"),
                String(localized: "ナウサ")
            ]),
            RegionHierarchy(parent: String(localized: "ジョージア"), children: [
                String(localized: "カヘティ"),
                String(localized: "カルトリ"),
                String(localized: "イメレティ")
            ]),
            RegionHierarchy(parent: String(localized: "スイス"), children: [
                String(localized: "ヴァレー"),
                String(localized: "ヴォー (ラヴォー)"),
                String(localized: "ティチーノ")
            ]),
            RegionHierarchy(parent: String(localized: "ハンガリー"), children: [
                String(localized: "トカイ"),
                String(localized: "エゲル")
            ]),
            RegionHierarchy(parent: String(localized: "イギリス"), children: [
                String(localized: "サセックス"),
                String(localized: "ケント")
            ]),
            RegionHierarchy(parent: String(localized: "カナダ"), children: [
                String(localized: "ナイアガラ・ペニンシュラ"),
                String(localized: "オカナガン・ヴァレー")
            ]),
            RegionHierarchy(parent: String(localized: "レバノン"), children: [
                String(localized: "ベッカー高原")
            ]),
            RegionHierarchy(parent: String(localized: "ウルグアイ"), children: [
                String(localized: "カネロネス")
            ])
        ]
    }

    // MARK: - 2. 日本酒産地 (全国47都道府県 > 主要酒処・地区)
    private static var sakeRegions: [RegionHierarchy] {
        [
            // 北海道・東北
            RegionHierarchy(parent: String(localized: "北海道"), children: [
                String(localized: "道央 (札幌・小樽)"),
                String(localized: "道北 (旭川・上川)"),
                String(localized: "道東 (釧路・根室)")
            ]),
            RegionHierarchy(parent: String(localized: "青森県"), children: [
                String(localized: "津軽 (弘前・黒石)"),
                String(localized: "南部 (八戸・十和田)")
            ]),
            RegionHierarchy(parent: String(localized: "岩手県"), children: [
                String(localized: "盛岡・紫波 (南部杜氏)"),
                String(localized: "県南 (花巻・一関)")
            ]),
            RegionHierarchy(parent: String(localized: "宮城県"), children: [
                String(localized: "県北 (大崎・栗原)"),
                String(localized: "仙台・塩竈")
            ]),
            RegionHierarchy(parent: String(localized: "秋田県"), children: [
                String(localized: "中央 (秋田)"),
                String(localized: "県南 (横手・湯沢)"),
                String(localized: "県北 (能代)")
            ]),
            RegionHierarchy(parent: String(localized: "山形県"), children: [
                String(localized: "村山 (山形)"),
                String(localized: "庄内 (酒田・鶴岡)"),
                String(localized: "置賜 (米沢)"),
                String(localized: "最上 (新庄)")
            ]),
            RegionHierarchy(parent: String(localized: "福島県"), children: [
                String(localized: "会津"),
                String(localized: "中通り"),
                String(localized: "浜通り")
            ]),
            // 関東
            RegionHierarchy(parent: String(localized: "茨城県"), children: [
                String(localized: "県北 (常陸太田・日立)"),
                String(localized: "県西 (結城・筑西)")
            ]),
            RegionHierarchy(parent: String(localized: "栃木県"), children: [
                String(localized: "県北 (大田原・那須)"),
                String(localized: "県南 (小山・栃木)")
            ]),
            RegionHierarchy(parent: String(localized: "群馬県"), children: [
                String(localized: "北毛 (沼田・川場)"),
                String(localized: "西毛 (高崎・藤岡)")
            ]),
            RegionHierarchy(parent: String(localized: "埼玉県"), children: [
                String(localized: "県北 (熊谷・行田)"),
                String(localized: "秩父")
            ]),
            RegionHierarchy(parent: String(localized: "千葉県"), children: [
                String(localized: "北総 (佐原・成田)"),
                String(localized: "上総・房総")
            ]),
            RegionHierarchy(parent: String(localized: "東京都"), children: [
                String(localized: "多摩 (福生・あきる野・青梅)"),
                String(localized: "23区")
            ]),
            RegionHierarchy(parent: String(localized: "神奈川県"), children: [
                String(localized: "県西 (足柄・小田原)"),
                String(localized: "県央 (海老名・厚木)")
            ]),
            // 甲信越・北陸
            RegionHierarchy(parent: String(localized: "新潟県"), children: [
                String(localized: "中越 (長岡・魚沼)"),
                String(localized: "下越 (新潟・村上)"),
                String(localized: "上越 (上越)"),
                String(localized: "佐渡")
            ]),
            RegionHierarchy(parent: String(localized: "富山県"), children: [
                String(localized: "呉東 (富山・黒部)"),
                String(localized: "呉西 (高岡・砺波)")
            ]),
            RegionHierarchy(parent: String(localized: "石川県"), children: [
                String(localized: "加賀・白山"),
                String(localized: "能登")
            ]),
            RegionHierarchy(parent: String(localized: "福井県"), children: [
                String(localized: "嶺北 (永平寺・大野)"),
                String(localized: "嶺南 (小浜・敦賀)")
            ]),
            RegionHierarchy(parent: String(localized: "山梨県"), children: [
                String(localized: "峡北 (北杜・韮崎)"),
                String(localized: "国中 (甲府・大月)")
            ]),
            RegionHierarchy(parent: String(localized: "長野県"), children: [
                String(localized: "北信"),
                String(localized: "中信"),
                String(localized: "南信"),
                String(localized: "東信 (佐久・上田)")
            ]),
            // 東海
            RegionHierarchy(parent: String(localized: "岐阜県"), children: [
                String(localized: "飛騨 (高山・古川)"),
                String(localized: "美濃 (大垣・多治見)")
            ]),
            RegionHierarchy(parent: String(localized: "静岡県"), children: [
                String(localized: "中部 (静岡・藤枝・島田)"),
                String(localized: "東部 (沼津・富士)"),
                String(localized: "西部 (浜松・掛川)")
            ]),
            RegionHierarchy(parent: String(localized: "愛知県"), children: [
                String(localized: "知多 (半田・常滑)"),
                String(localized: "三河 (岡崎・設楽)")
            ]),
            RegionHierarchy(parent: String(localized: "三重県"), children: [
                String(localized: "伊賀"),
                String(localized: "北勢 (四日市・鈴鹿)")
            ]),
            // 近畿
            RegionHierarchy(parent: String(localized: "滋賀県"), children: [
                String(localized: "湖南 (甲賀・草津)"),
                String(localized: "湖北・湖東 (長浜・彦根)")
            ]),
            RegionHierarchy(parent: String(localized: "京都府"), children: [
                String(localized: "伏見"),
                String(localized: "丹後・丹波")
            ]),
            RegionHierarchy(parent: String(localized: "大阪府"), children: [
                String(localized: "北摂 (池田・高槻)"),
                String(localized: "河内 (交野・富田林)")
            ]),
            RegionHierarchy(parent: String(localized: "兵庫県"), children: [
                String(localized: "灘五郷"),
                String(localized: "播州 (西脇・加東・姫路)"),
                String(localized: "丹波・但馬")
            ]),
            RegionHierarchy(parent: String(localized: "奈良県"), children: [
                String(localized: "奈良・天理"),
                String(localized: "宇陀・吉野")
            ]),
            RegionHierarchy(parent: String(localized: "和歌山県"), children: [
                String(localized: "紀北 (海南・かつらぎ)"),
                String(localized: "紀南 (田辺・新宮)")
            ]),
            // 中国
            RegionHierarchy(parent: String(localized: "鳥取県"), children: [
                String(localized: "中部 (倉吉)"),
                String(localized: "東部・西部 (鳥取・米子)")
            ]),
            RegionHierarchy(parent: String(localized: "島根県"), children: [
                String(localized: "出雲 (出雲・松江)"),
                String(localized: "石見 (大田・浜田)")
            ]),
            RegionHierarchy(parent: String(localized: "岡山県"), children: [
                String(localized: "備前 (赤磐・瀬戸内)"),
                String(localized: "備中 (倉敷・高梁)"),
                String(localized: "美作 (津山)")
            ]),
            RegionHierarchy(parent: String(localized: "広島県"), children: [
                String(localized: "西条 (東広島)"),
                String(localized: "呉・竹原"),
                String(localized: "備後 (福山・三次)")
            ]),
            RegionHierarchy(parent: String(localized: "山口県"), children: [
                String(localized: "岩国・周南"),
                String(localized: "萩・長門")
            ]),
            // 四国
            RegionHierarchy(parent: String(localized: "徳島県"), children: [
                String(localized: "吉野川流域 (阿波・美馬)")
            ]),
            RegionHierarchy(parent: String(localized: "香川県"), children: [
                String(localized: "中讃・西讃 (琴平・観音寺)")
            ]),
            RegionHierarchy(parent: String(localized: "愛媛県"), children: [
                String(localized: "東予 (西条・今治)"),
                String(localized: "南予 (宇和島・内子)")
            ]),
            RegionHierarchy(parent: String(localized: "高知県"), children: [
                String(localized: "土佐")
            ]),
            // 九州・沖縄
            RegionHierarchy(parent: String(localized: "福岡県"), children: [
                String(localized: "城島 (久留米)"),
                String(localized: "筑前・筑後")
            ]),
            RegionHierarchy(parent: String(localized: "佐賀県"), children: [
                String(localized: "鹿島・嬉野"),
                String(localized: "唐津・小城")
            ]),
            RegionHierarchy(parent: String(localized: "長崎県"), children: [
                String(localized: "平戸・壱岐"),
                String(localized: "島原・佐世保")
            ]),
            RegionHierarchy(parent: String(localized: "熊本県"), children: [
                String(localized: "熊本・菊池"),
                String(localized: "球磨")
            ]),
            RegionHierarchy(parent: String(localized: "大分県"), children: [
                String(localized: "日田・玖珠"),
                String(localized: "国東・宇佐")
            ]),
            RegionHierarchy(parent: String(localized: "宮崎県"), children: [
                String(localized: "高千穂・延岡")
            ]),
            RegionHierarchy(parent: String(localized: "鹿児島県"), children: [
                String(localized: "奄美・薩摩")
            ]),
            RegionHierarchy(parent: String(localized: "沖縄県"), children: [
                String(localized: "本島 (うるま)")
            ])
        ]
    }

    // MARK: - 3. ビール産地 (主要国〜クラフトビール新興国 > 地方・都市)
    private static var beerRegions: [RegionHierarchy] {
        [
            RegionHierarchy(parent: String(localized: "ドイツ"), children: [
                String(localized: "バイエルン (ミュンヘン)"),
                String(localized: "フランケン (バンベルク)"),
                String(localized: "ノルトライン (ケルン・デュッセルドルフ)"),
                String(localized: "ドルトムント"),
                String(localized: "ベルリン")
            ]),
            RegionHierarchy(parent: String(localized: "ベルギー"), children: [
                String(localized: "フランダース"),
                String(localized: "ワロン"),
                String(localized: "ブリュッセル"),
                String(localized: "パヨッテンラント (ランビック)")
            ]),
            RegionHierarchy(parent: String(localized: "イギリス"), children: [
                String(localized: "イングランド (ロンドン・マンチェスター)"),
                String(localized: "スコットランド (エジンバラ・アバディーン)"),
                String(localized: "バートン・オン・トレント")
            ]),
            RegionHierarchy(parent: String(localized: "アメリカ"), children: [
                String(localized: "西海岸 (ポートランド・サンディエゴ)"),
                String(localized: "ニューイングランド (バーモント・マサチューセッツ)"),
                String(localized: "中西部 (シカゴ・ミシガン)"),
                String(localized: "コロラド (デンバー)")
            ]),
            RegionHierarchy(parent: String(localized: "チェコ"), children: [
                String(localized: "プルゼニ (ピルゼン)"),
                String(localized: "プラハ"),
                String(localized: "モラヴィア")
            ]),
            RegionHierarchy(parent: String(localized: "日本"), children: [
                String(localized: "北海道"),
                String(localized: "岩手"),
                String(localized: "埼玉"),
                String(localized: "東京"),
                String(localized: "神奈川"),
                String(localized: "長野"),
                String(localized: "静岡"),
                String(localized: "三重"),
                String(localized: "京都"),
                String(localized: "大阪"),
                String(localized: "鳥取"),
                String(localized: "沖縄")
            ]),
            // --- クラフトビール注目国・マイナー産地 ---
            RegionHierarchy(parent: String(localized: "デンマーク"), children: [
                String(localized: "コペンハーゲン")
            ]),
            RegionHierarchy(parent: String(localized: "オランダ"), children: [
                String(localized: "アムステルダム"),
                String(localized: "アイントホーフェン")
            ]),
            RegionHierarchy(parent: String(localized: "カナダ"), children: [
                String(localized: "ブリティッシュコロンビア (バンクーバー)"),
                String(localized: "ケベック (モントリオール)"),
                String(localized: "オンタリオ (トロント)")
            ]),
            RegionHierarchy(parent: String(localized: "アイルランド"), children: [
                String(localized: "ダブリン"),
                String(localized: "コーク")
            ]),
            RegionHierarchy(parent: String(localized: "オーストラリア"), children: [
                String(localized: "ヴィクトリア (メルボルン)"),
                String(localized: "ニューサウスウェールズ (シドニー)")
            ]),
            RegionHierarchy(parent: String(localized: "ニュージーランド"), children: [
                String(localized: "ウェリントン"),
                String(localized: "ネルソン")
            ]),
            RegionHierarchy(parent: String(localized: "ノルウェー"), children: [
                String(localized: "オスロ"),
                String(localized: "スタヴァンゲル")
            ]),
            RegionHierarchy(parent: String(localized: "スウェーデン"), children: [
                String(localized: "ストックホルム"),
                String(localized: "ヨーテボリ")
            ]),
            RegionHierarchy(parent: String(localized: "エストニア"), children: [
                String(localized: "タリン")
            ]),
            RegionHierarchy(parent: String(localized: "イタリア"), children: [
                String(localized: "ピエモンテ"),
                String(localized: "ロンバルディア")
            ]),
            RegionHierarchy(parent: String(localized: "スペイン"), children: [
                String(localized: "バルセロナ"),
                String(localized: "バスク")
            ])
        ]
    }
}
