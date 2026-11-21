//
//  KikisakeApp.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import SwiftUI
import SwiftData
import GoogleMobileAds
import AppTrackingTransparency
import os

@main
struct KikisakeApp: App {
    private let modelContainerManager = ModelContainerManager.shared
    @Bindable private var appState = AppState.shared

    private var isOnboardingPresented: Binding<Bool> {
        Binding(
            get: { !appState.hasCompletedOnboarding },
            set: { appState.hasCompletedOnboarding = !$0 }
        )
    }

    init() {
        MobileAds.shared.start(completionHandler: nil)
        PreviewSampleLoader.insertSamplesIfNeeded(into: modelContainerManager.container.mainContext)
    }

    public var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(modelContainerManager.container)
                .preferredColorScheme(appState.appearanceMode.colorScheme)
                .sheet(isPresented: isOnboardingPresented) {
                    BoardingView(isPresented: isOnboardingPresented)
                        .interactiveDismissDisabled(true)
                }
                .task {
                    await requestTrackingPermission()
                }
        }
    }

    private func requestTrackingPermission() async {
        // Delay ATT prompt slightly so initial view and onboarding settle first.
        try? await Task.sleep(for: .seconds(1))
        let status = await ATTrackingManager.requestTrackingAuthorization()
        switch status {
        case .authorized:
            AppLogger.general.info("ATT tracking authorized.")
        case .denied:
            AppLogger.general.info("ATT tracking denied.")
        case .restricted:
            AppLogger.general.info("ATT tracking restricted.")
        case .notDetermined:
            AppLogger.general.info("ATT tracking not determined.")
        @unknown default:
            break
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [BeverageItem.self, TastingLog.self], inMemory: true)
}
