public enum EnvironmentType: String {
    case dev
    case stg
    case prod
}

public class Environment {
    public static let shared = Environment()
    
    public var type = EnvironmentType.dev
}
