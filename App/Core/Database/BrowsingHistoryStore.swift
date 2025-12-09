//
//  BrowsingHistoryStore.swift
//  Smth
//
//  浏览历史数据存储，管理用户浏览过的帖子历史记录
//  Created by tony
//

import Foundation

struct TopicHistoryEntry: Codable, Identifiable, Equatable {
    let id: String
    var subject: String
    var boardTitle: String?
    var lastVisitedAt: Date
}

@MainActor
protocol BrowsingHistoryStoreProtocol: AnyObject {
    var entries: [TopicHistoryEntry] { get }
    var visitedTopicIDs: Set<String> { get }
    func record(_ topic: Topic)
    func clear()
}

@MainActor
final class BrowsingHistoryStore: ObservableObject, BrowsingHistoryStoreProtocol {
    @Published private(set) var entries: [TopicHistoryEntry] = []
    @Published private(set) var visitedTopicIDs: Set<String> = []

    private let storageURL: URL
    private let maxEntryCount: Int
    private let ioQueue = DispatchQueue(label: "com.smth.history.io", qos: .utility)
    private let fileManager: FileManager

    init(
        fileManager: FileManager = .default,
        storageURL: URL? = nil,
        maxEntryCount: Int = 200
    ) {
        self.maxEntryCount = maxEntryCount
        self.fileManager = fileManager
        self.storageURL = storageURL ?? BrowsingHistoryStore.makeStorageURL(using: fileManager)
        loadFromDisk()
    }

    func record(_ topic: Topic) {
        let now = Date()
        if let existingIndex = entries.firstIndex(where: { $0.id == topic.id }) {
            entries[existingIndex].subject = topic.subject
            entries[existingIndex].boardTitle = topic.board?.title
            entries[existingIndex].lastVisitedAt = now
            let updatedEntry = entries.remove(at: existingIndex)
            entries.insert(updatedEntry, at: 0)
        } else {
            let entry = TopicHistoryEntry(
                id: topic.id,
                subject: topic.subject,
                boardTitle: topic.board?.title,
                lastVisitedAt: now
            )
            entries.insert(entry, at: 0)
            if entries.count > maxEntryCount {
                entries = Array(entries.prefix(maxEntryCount))
            }
        }
        visitedTopicIDs = Set(entries.map(\.id))
        saveToDisk()
    }

    func clear() {
        entries.removeAll()
        visitedTopicIDs.removeAll()
        saveToDisk()
    }

    private func loadFromDisk() {
        guard fileManager.fileExists(atPath: storageURL.path) else { return }
        do {
            let data = try Data(contentsOf: storageURL)
            let decoded = try JSONDecoder().decode([TopicHistoryEntry].self, from: data)
            entries = decoded.sorted(by: { $0.lastVisitedAt > $1.lastVisitedAt })
            visitedTopicIDs = Set(entries.map(\.id))
        } catch {
            #if DEBUG
            print("BrowsingHistoryStore load error: \(error)")
            #endif
            entries = []
            visitedTopicIDs = []
        }
    }

    private func saveToDisk() {
        let entriesToSave = entries
        ioQueue.async { [storageURL, fileManager] in
            do {
                let directoryURL = storageURL.deletingLastPathComponent()
                if !fileManager.fileExists(atPath: directoryURL.path) {
                    try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
                }
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                let data = try encoder.encode(entriesToSave)
                try data.write(to: storageURL, options: [.atomic])
            } catch {
                #if DEBUG
                print("BrowsingHistoryStore save error: \(error)")
                #endif
            }
        }
    }

    private static func makeStorageURL(using fileManager: FileManager) -> URL {
        let directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        return directory.appendingPathComponent("BrowsingHistory", conformingTo: .directory)
            .appendingPathComponent("topic_history.json")
    }
}


