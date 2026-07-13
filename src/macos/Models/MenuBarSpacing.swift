import Foundation

enum MenuBarSpacing {
    static let appleDefaultsPadding = 10
    static let appleDefaultsSpacing = 6

    static let minPadding = 0
    static let maxPadding = 20
    static let minSpacing = 0
    static let maxSpacing = 20

    private static let paddingKey = "NSStatusItemSelectionPadding"
    private static let spacingKey = "NSStatusItemSpacing"

    static func readPadding() -> Int? {
        CFPreferencesCopyValue(
            paddingKey as CFString,
            kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser,
            kCFPreferencesCurrentHost
        ) as? Int
    }

    static func readSpacing() -> Int? {
        CFPreferencesCopyValue(
            spacingKey as CFString,
            kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser,
            kCFPreferencesCurrentHost
        ) as? Int
    }

    static func write(padding: Int?, spacing: Int?) {
        if let p = padding {
            CFPreferencesSetValue(
                paddingKey as CFString,
                p as CFNumber,
                kCFPreferencesAnyApplication,
                kCFPreferencesCurrentUser,
                kCFPreferencesCurrentHost
            )
        }
        if let s = spacing {
            CFPreferencesSetValue(
                spacingKey as CFString,
                s as CFNumber,
                kCFPreferencesAnyApplication,
                kCFPreferencesCurrentUser,
                kCFPreferencesCurrentHost
            )
        }
        CFPreferencesAppSynchronize(kCFPreferencesAnyApplication)
        restartControlCenter()
    }

    static func reset() {
        CFPreferencesSetValue(
            paddingKey as CFString,
            nil,
            kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser,
            kCFPreferencesCurrentHost
        )
        CFPreferencesSetValue(
            spacingKey as CFString,
            nil,
            kCFPreferencesAnyApplication,
            kCFPreferencesCurrentUser,
            kCFPreferencesCurrentHost
        )
        CFPreferencesAppSynchronize(kCFPreferencesAnyApplication)
        restartControlCenter()
    }

    private static func restartControlCenter() {
        let task = Process()
        task.launchPath = "/usr/bin/killall"
        task.arguments = ["ControlCenter"]
        try? task.run()
    }
}
