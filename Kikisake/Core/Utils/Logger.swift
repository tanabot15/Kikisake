//
//  Logger.swift
//  Kikisake
//
//  Created by Kenichiro Suzuki on 2026/10/14.
//

import Foundation
import OSLog

public enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.kikisake.app"

    public static let general = Logger(subsystem: subsystem, category: "General")
    public static let persistence = Logger(subsystem: subsystem, category: "Persistence")
    public static let ui = Logger(subsystem: subsystem, category: "UI")
}
