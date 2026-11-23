//
//  LogView.swift
//  Kikisake
//

import SwiftUI
import SwiftData

/// [Tab 1] Tasting log list, timeline, and collection book container view.
public struct LogView: View {
    @Query(sort: \TastingLog.date, order: .reverse) private var logs: [TastingLog]
    @State private var viewModel = LogViewModel()
    @State private var collectionViewModel = CollectionViewModel()
    @State private var editMode: EditMode = .inactive
    @State private var isShowingFilterSheet: Bool = false

    private var filteredLogs: [TastingLog] {
        viewModel.filteredLogs(logs)
    }

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
                    ListView(
                        viewModel: viewModel,
                        filteredLogs: filteredLogs,
                        editMode: $editMode
                    )
                    .tag(LogMainSection.list)

                    TimelineSectionView(
                        logs: filteredLogs,
                        hasActiveFilters: viewModel.hasActiveFilters
                    )
                    .tag(LogMainSection.timeline)

                    ScrollView {
                        CollectionBookView(
                            allLogs: logs,
                            logViewModel: viewModel,
                            viewModel: collectionViewModel
                        )
                        .padding()
                    }
                    .background(Color(.systemGroupedBackground))
                    .tag(LogMainSection.collectionBook)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle(String(localized: "ログ"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { logToolbarContent }
            .sheet(isPresented: $isShowingFilterSheet) {
                LogFilterSheet(
                    viewModel: viewModel,
                    collectionViewModel: collectionViewModel,
                    currentCollectionCategory: collectionViewModel.selectedCategory,
                    isPro: AppState.shared.isProVersion
                )
            }
            .onChange(of: viewModel.selectedSection) { _, newSection in
                if newSection != .list {
                    editMode = .inactive
                }
            }
            .onAppear(perform: consumePendingNavigationFilters)
        }
    }

    private var sectionPicker: some View {
        Picker(String(localized: "表示モード"), selection: $viewModel.selectedSection) {
            ForEach(LogMainSection.allCases) { section in
                Text(section.displayName).tag(section)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemGroupedBackground))
    }

    @ToolbarContentBuilder
    private var logToolbarContent: some ToolbarContent {
        if viewModel.selectedSection == .list {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.toggleListDisplayStyle()
                    }
                } label: {
                    Image(systemName: viewModel.listDisplayStyleIconName)
                }
                .tint(.primary)
                .accessibilityLabel(String(localized: "表示形式の切り替え"))
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isShowingFilterSheet = true
            } label: {
                Image(
                    systemName: viewModel.hasActiveCurrentSectionFilters
                        ? "line.3.horizontal.decrease.circle.fill"
                        : "line.3.horizontal.decrease.circle"
                )
                .foregroundStyle(viewModel.hasActiveCurrentSectionFilters ? Color.accentColor : Color.primary)
            }
        }

        if viewModel.selectedSection == .list {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation {
                        editMode = (editMode == .active) ? .inactive : .active
                    }
                } label: {
                    Image(systemName: editMode == .active ? "checkmark.circle" : "square.and.pencil")
                        .foregroundStyle(editMode == .active ? Color.accentColor : Color.primary)
                }
                .tint(.primary)
            }
        }
    }

    private func consumePendingNavigationFilters() {
        if let pendingFilter = AppState.shared.pendingLogFilter {
            viewModel.resetFilters()
            switch pendingFilter {
            case .costEffective:
                viewModel.filterCostEffective = true
            case .willingToRepeat:
                viewModel.filterWillingToRepeat = true
            case .agingPotential:
                viewModel.filterAgingPotential = true
            }
            AppState.shared.pendingLogFilter = nil
        }

        if let pendingAroma = AppState.shared.pendingAromaTagFilter {
            viewModel.resetFilters()
            viewModel.aromaTagFilter = pendingAroma
            AppState.shared.pendingAromaTagFilter = nil
        }
    }
}

#Preview("Free") {
    AppState.shared.isProVersion = false
    return LogView()
        .modelContainer(PreviewSampleData.container)
}

#Preview("Pro") {
    AppState.shared.isProVersion = true
    return LogView()
        .modelContainer(PreviewSampleData.container)
}
