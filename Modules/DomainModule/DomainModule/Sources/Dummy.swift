/**
 Document
 - token: String
 - status: Bool
 - enterprise: String?
 */


public struct Document {
    public init(token: String, status: Bool, enterprise: String?) {
        self.token = token
        self.status = status
        self.enterprise = enterprise
    }
    
    public let token: String
    public let status: Bool
    public let enterprise: String?
}


public enum LoadDocumentResult {
    case success([Document])
    case failure(Error)
}

public protocol LoadDocument {
    func load(completion: @escaping (LoadDocumentResult) -> Void)
}
