import ProjectDescription

public struct CrossPlatformValue<T> {
    public init(iOS: T, macOS: T) {
        self.iOS = iOS
        self.macOS = macOS
    }
    
    public let iOS: T
    public let macOS: T
}

public enum MaybeCrossPlatform<T> {
    case crossPlatform(CrossPlatformValue<T>)
    case direct(T)
    
    var crossPlatformValue: CrossPlatformValue<T> {
        switch(self) {
        case .crossPlatform(let value):
            return value
        case .direct(let value):
            return CrossPlatformValue(iOS: value, macOS: value)
        }
    }
    
    public static func crossPlatformValue<T>(iOS: T, macOS: T) -> MaybeCrossPlatform<T> {
        return .crossPlatform(CrossPlatformValue<T>(iOS: iOS, macOS: macOS))
    }
}
