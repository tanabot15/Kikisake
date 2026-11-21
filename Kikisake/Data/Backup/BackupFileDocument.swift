//
//  BackupFileDocument.swift
//  Kikisake
//

import SwiftUI
import UniformTypeIdentifiers

public struct BackupFileDocument: FileDocument {
    public static var readableContentTypes: [UTType] { [.json] }

    public var payloadData: Data

    public init(payloadData: Data) {
        self.payloadData = payloadData
    }

    public init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.payloadData = data
    }

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: payloadData)
    }
}
