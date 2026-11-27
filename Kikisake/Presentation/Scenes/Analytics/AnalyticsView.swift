//
//  AnalyticsView.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// Root analytics screen containing consumption, evaluation, blind, and comparison tabs.
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

                sectionPicker

                TabView(selection: $viewModel.selectedSection) {
                    sectionScrollContainer {
                        contentView(for: .consumption)
                    }
                    .tag(AnalyticsSection.consumption)

                    sectionScrollContainer {
                        contentView(for: .evaluation)
                    }
                    .tag(AnalyticsSection.evaluation)

                    sectionScrollContainer {
                        BlindAnalyticsView(viewModel: viewModel, targetLogs: viewModel.filteredLogs(from: logs))
                    }
                    .tag(AnalyticsSection.blind)

                    sectionScrollContainer {
                        LogComparisonView(viewModel: viewModel, allLogs: logs)
                    }
                    .tag(AnalyticsSection.comparison)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle(String(localized: "分析"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { analyticsToolbarContent }
            .sheet(isPresented: $isShowingFilterSheet) {
                AnalyticsFilterSheet(viewModel: viewModel, allLogs: logs)
            }
        }
    }

    private var sectionPicker: some View {
        Picker(String(localized: "分析カテゴリ"), selection: $viewModel.selectedSection) {
            ForEach(AnalyticsSection.allCases) { section in
                Text(section.displayName).tag(section)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemGroupedBackground))
    }

    @ToolbarContentBuilder
    private var analyticsToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isShowingFilterSheet = true
            } label: {
                Image(
                    systemName: viewModel.hasActiveFilters
                        ? "line.3.horizontal.decrease.circle.fill"
                        : "line.3.horizontal.decrease.circle"
                )
                .foregroundStyle(viewModel.hasActiveFilters ? Color.accentColor : Color.primary)
            }
            .accessibilityLabel(String(localized: "分析フィルター"))
        }
    }

    private func sectionScrollContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ScrollView {
            content()
                .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private func contentView(for section: AnalyticsSection) -> some View {
        let targetLogs = viewModel.filteredLogs(from: logs)

        if logs.isEmpty || targetLogs.isEmpty {
            ContentUnavailableView(
                String(localized: "該当する分析データがありません"),
                systemImage: "chart.bar.xaxis",
                description: Text(
                    viewModel.hasActiveFilters
                        ? String(localized: "フィルター条件を変更してみてください。")
                        : String(localized: "「追加」タブからお酒を記録すると、ここに分析が表示されます。")
                )
            )
            .padding(.top, 40)
        } else {
            switch section {
            case .consumption:
                ConsumptionView(viewModel: viewModel, targetLogs: targetLogs)
            case .evaluation:
                EvaluationView(viewModel: viewModel, targetLogs: targetLogs)
            case .blind, .comparison:
                EmptyView()
            }
        }
    }
}

#Preview {
    AnalyticsViewPreviewHost(initialSection: .consumption)
}

private struct AnalyticsViewPreviewHost: View {
    @State private var isReady = false
    let initialSection: AnalyticsSection

    var body: some View {
        AnalyticsView()
            .modelContainer(PreviewSampleData.container)
            .onAppear {
                if !isReady {
                    AppState.shared.selectedTab = 1
                    isReady = true
                }
            }
    }
}
