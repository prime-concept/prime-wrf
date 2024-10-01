final public class PGCMain {
    
    public static let shared = PGCMain()
    
    public private(set) var chatAssemblyConstructor: (any ChatAssemblyConstructor)!
    public var config: (any ConfigProtocol)!
    public var featureFlags: (any FeatureFlagsProtocol)!
    public var palette: (any PaletteProtocol)!
    public var resourceProvider: (any ResourceProvider)!
    public var text: (any TextProtocol)!
    
    public func configure(
        chatAssemblyConstructor: any ChatAssemblyConstructor,
        config: (any ConfigProtocol),
        featureFlags: (any FeatureFlagsProtocol),
        palette: any PaletteProtocol,
        resourceProvider: any ResourceProvider,
        text: any TextProtocol
    ) {
        self.chatAssemblyConstructor = chatAssemblyConstructor
        self.config = config
        self.featureFlags = featureFlags
        self.palette = palette
        self.resourceProvider = resourceProvider
        self.text = text
    }
    
}
