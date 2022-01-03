extension String {
    /// Adds a `.` at the end of a string
    public var dot: String {
        return "\(self)."
    }
    
    /// Adds a `_` at the end of a string
    public var under: String {
        return "\(self)_"
    }
    
    /// Adds a `Tests` at the end of a string
    public var Tests: String {
        return "\(self)Tests"
    }
    
    /// Adds a `Extension` at the end of a string
    public var Extension: String {
        return "\(self)Extension"
    }
    
    /// Replaces spaces with underscores at the end of a string
    public var replaceSpaceWithUnder: String {
        return self.replacingOccurrences(of: " ", with: "_")
    }
}
