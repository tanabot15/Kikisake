//  AnalyticsView.swift
//  Kikisake

import SwiftUI
import SwiftData

public struct AnalyticsView: View {
    @Query private var logs: [TastingLog]
    @State private var viewModel = AnalyticsViewModel()
    @State private var isShowingFilterSheet: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !AppState.shared.isProVersion {
                    ConditionalAdMobBannerView()
                        .frame(height: 50)
                        .background(Color(.systemBackground))
                }
                
                // セグメントピッカー（タブ選択と連動）
                Picker(String(localized: "分析カテゴリ"), selection: $viewModel.selectedSection) {
                    ForEach(AnalyticsSection.allCases) { section in
                        Text(section.displayName).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color(.systemGroupedBackground))

                // 左右スワイプで切り替え可能なタブビュー
                TabView(selection: $viewModel.selectedSection) {
                    // 1. 飲酒量・ログタブ
                    ScrollView {
                        let targetLogs = viewModel.filteredLogs(from: logs)
                        contentView(targetLogs: targetLogs, for: .consumption)
                            .padding()
                    }
                    .background(Color(.systemGroupedBackground))
                    .tag(AnalyticsSection.consumption)

                    // 2. 評価・好みタブ
                    ScrollView {
                        let targetLogs = viewModel.filteredLogs(from: logs)
                        contentView(targetLogs: targetLogs, for: .evaluation)
                            .padding()
                    }
                    .background(Color(.systemGroupedBackground))
                    .tag(AnalyticsSection.evaluation)
                }
                .tabViewStyle(.page(indexDisplayMode: .never)) // ページインジケーターを非表示にし、スワイプ操作を有効化
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("分析")
                        .font(.headline)
                        .fontWeight(.semibold)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingFilterSheet = true
                    } label: {
                        Image(systemName: viewModel.hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundStyle(viewModel.hasActiveFilters ? Color.accentColor : Color.primary)
                    }
                    .accessibilityLabel(String(localized: "分析フィルター"))
                }
            }
            .sheet(isPresented: $isShowingFilterSheet) {
                AnalyticsFilterSheet(viewModel: viewModel, allLogs: logs)
            }
        }
    }

    @ViewBuilder
    private func contentView(targetLogs: [TastingLog], for section: AnalyticsSection) -> some View {
        if logs.isEmpty || targetLogs.isEmpty {
            ContentUnavailableView(
                String(localized: "該当する分析データがありません"),
                systemImage: "chart.bar.xaxis",
                description: Text(viewModel.hasActiveFilters ? String(localized: "フィルター条件を変更してみてください。") : String(localized: "「追加」タブからお酒を記録すると、ここに分析が表示されます。"))
            )
            .padding(.top, 40)
        } else {
            switch section {
            case .consumption:
                ConsumptionAnalyticsView(viewModel: viewModel, targetLogs: targetLogs, allLogs: logs)
            case .evaluation:
                EvaluationAnalyticsView(viewModel: viewModel, targetLogs: targetLogs)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BeverageItem.self, TastingLog.self, configurations: config)
    
    let sampleItem = BeverageItem(name: "バローロ DOCG", producer: "プルノット", category: .wine)
    let sampleLog = TastingLog(rating: 4.8, aromaTags: ["チェリー", "樽香"], isCostEffective: true, isWillingToRepeat: true, item: sampleItem)
    
    container.mainContext.insert(sampleItem)
    container.mainContext.insert(sampleLog)

    return AnalyticsView()
        .modelContainer(container)
}
