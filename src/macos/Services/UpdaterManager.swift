import AppKit
import Combine
import Foundation
import Sparkle
import SwiftUI

private final class ChannelFeedProvider: NSObject, SPUUpdaterDelegate {
    nonisolated func feedURLString(for updater: SPUUpdater) -> String? {
        let isDevBuild = (Bundle.main.object(forInfoDictionaryKey: "PKpowerlinesBuildChannel") as? String) == "dev"
        let isDevChannel = UserDefaults.standard.string(forKey: "updateChannel") == "dev"
        let address = (isDevBuild || isDevChannel)
            ? "https://raw.githubusercontent.com/mondary/Macos_PKpowerlines/main/appcast-dev.xml"
            : "https://raw.githubusercontent.com/mondary/Macos_PKpowerlines/main/appcast.xml"
        guard var components = URLComponents(string: address) else { return address }
        components.queryItems = (components.queryItems ?? []) + [URLQueryItem(name: "_pk_refresh", value: UUID().uuidString)]
        return components.url?.absoluteString ?? address
    }
}

@MainActor
final class UpdaterManager: NSObject, ObservableObject {
    static let shared = UpdaterManager()
    static let channelKey = "updateChannel"
    static let stableFeedURL = "https://raw.githubusercontent.com/mondary/Macos_PKpowerlines/main/appcast.xml"
    static let devFeedURL = "https://raw.githubusercontent.com/mondary/Macos_PKpowerlines/main/appcast-dev.xml"

    private let controller: SPUStandardUpdaterController
    private let feedProvider: ChannelFeedProvider
    @Published private(set) var canCheckForUpdates = false
    @Published private(set) var latestStableVersion: String?
    @Published private(set) var latestDevVersion: String?
    @Published private(set) var availableUpdateVersion: String?
    private var latestStableBuild: String?
    private var latestDevBuild: String?

    private override init() {
        let feedProvider = ChannelFeedProvider()
        self.feedProvider = feedProvider
        controller = SPUStandardUpdaterController(
            startingUpdater: false,
            updaterDelegate: feedProvider,
            userDriverDelegate: nil
        )
        super.init()
        controller.updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }

    func start() {
        #if DEBUG
        return
        #else
        configure(channel: UserDefaults.standard.string(forKey: Self.channelKey) ?? "stable")
        controller.startUpdater()
        #endif
    }

    func updateChannelChanged(to channel: String) {
        #if !DEBUG
        configure(channel: channel)
        #endif
        refreshAvailableVersions()
    }

    func checkForUpdates() {
        #if DEBUG
        return
        #else
        refreshAvailableVersions()
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        controller.checkForUpdates(nil)
        #endif
    }

    private func configure(channel: String) {
        let isDevBuild = (Bundle.main.object(forInfoDictionaryKey: "PKpowerlinesBuildChannel") as? String) == "dev"
        controller.updater.automaticallyDownloadsUpdates = isDevBuild || channel == "dev"
    }

    func refreshAvailableVersions() {
        Task {
            async let stable = Self.latestInfo(at: Self.stableFeedURL)
            async let dev = Self.latestInfo(at: Self.devFeedURL)
            let feeds = await (stable, dev)
            latestStableVersion = feeds.0?.shortVersion
            latestStableBuild = feeds.0?.buildVersion
            latestDevVersion = feeds.1?.shortVersion
            latestDevBuild = feeds.1?.buildVersion
            refreshUpdateAvailability()
        }
    }

    func versionStatus(for channel: String) -> PowerlinesChannelVersionStatus {
        let installedChannel = (Bundle.main.object(forInfoDictionaryKey: "PKpowerlinesBuildChannel") as? String) == "dev" ? "dev" : "stable"
        guard installedChannel == channel else { return .otherChannel }
        guard let publishedBuild = channel == "dev" ? latestDevBuild : latestStableBuild,
              let installedBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String,
              let order = compareBuildNumbers(publishedBuild, installedBuild) else { return .unavailable }
        switch order {
        case .orderedDescending: return .updateAvailable
        case .orderedSame: return .upToDate
        case .orderedAscending: return .installedAhead
        }
    }

    private func refreshUpdateAvailability() {
        let isDevBuild = (Bundle.main.object(forInfoDictionaryKey: "PKpowerlinesBuildChannel") as? String) == "dev"
        let channel = isDevBuild ? "dev" : UserDefaults.standard.string(forKey: Self.channelKey) ?? "stable"
        let latestBuild = channel == "dev" ? latestDevBuild : latestStableBuild
        let installedBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        availableUpdateVersion = if let latestBuild, let installedBuild,
                                    compareBuildNumbers(latestBuild, installedBuild) == .orderedDescending {
            channel == "dev" ? latestDevVersion : latestStableVersion
        } else {
            nil
        }
    }

    private static func latestInfo(at address: String) async -> PowerlinesAppcastInfo? {
        guard var components = URLComponents(string: address) else { return nil }
        components.queryItems = (components.queryItems ?? []) + [URLQueryItem(name: "_pk_refresh", value: UUID().uuidString)]
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        request.setValue("no-cache, no-store", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
        let parser = PowerlinesAppcastParser()
        let xml = XMLParser(data: data)
        xml.delegate = parser
        return xml.parse() ? parser.info : nil
    }
}

enum PowerlinesChannelVersionStatus {
    case updateAvailable, upToDate, installedAhead, otherChannel, unavailable

    var symbol: String {
        switch self {
        case .updateAvailable: "arrow.down.circle.fill"
        case .upToDate: "checkmark.circle.fill"
        case .installedAhead: "arrow.up.circle.fill"
        case .otherChannel: "circle.dashed"
        case .unavailable: "questionmark.circle"
        }
    }

    var title: String {
        switch self {
        case .updateAvailable: "Mise à jour disponible"
        case .upToDate: "À jour"
        case .installedAhead: "Version installée plus récente"
        case .otherChannel: "Autre canal"
        case .unavailable: "Version indisponible"
        }
    }

    var color: Color {
        switch self {
        case .updateAvailable: .accentColor
        case .upToDate: .green
        case .installedAhead: .orange
        case .otherChannel, .unavailable: .secondary
        }
    }
}

private struct PowerlinesAppcastInfo {
    let shortVersion: String
    let buildVersion: String
}

private func compareBuildNumbers(_ lhs: String, _ rhs: String) -> ComparisonResult? {
    func components(_ value: String) -> [UInt64]? {
        let parts = value.split(separator: ".")
        guard !parts.isEmpty else { return nil }
        let numbers = parts.compactMap { UInt64($0) }
        return numbers.count == parts.count ? numbers : nil
    }
    guard let left = components(lhs), let right = components(rhs) else { return nil }
    for index in 0..<max(left.count, right.count) {
        let a = index < left.count ? left[index] : 0
        let b = index < right.count ? right[index] : 0
        if a != b { return a < b ? .orderedAscending : .orderedDescending }
    }
    return .orderedSame
}

private final class PowerlinesAppcastParser: NSObject, XMLParserDelegate {
    private var inShortVersion = false
    private var inBuildVersion = false
    private var text = ""
    private var shortVersion: String?
    private var buildVersion: String?

    var info: PowerlinesAppcastInfo? {
        guard let shortVersion, let build = buildVersion else { return nil }
        return PowerlinesAppcastInfo(shortVersion: shortVersion, buildVersion: build)
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        if elementName == "sparkle:shortVersionString" || qName == "sparkle:shortVersionString" { inShortVersion = true; text = "" }
        else if elementName == "sparkle:version" || qName == "sparkle:version" { inBuildVersion = true; text = "" }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if inShortVersion || inBuildVersion { text += string }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if inShortVersion && (elementName == "sparkle:shortVersionString" || qName == "sparkle:shortVersionString") {
            shortVersion = text.trimmingCharacters(in: .whitespacesAndNewlines)
            inShortVersion = false
        } else if inBuildVersion && (elementName == "sparkle:version" || qName == "sparkle:version") {
            buildVersion = text.trimmingCharacters(in: .whitespacesAndNewlines)
            inBuildVersion = false
        }
    }
}
