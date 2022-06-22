/**
 Document
 - token: String
 - status: Bool
 - enterprise: String?
 */


struct Document {
    let token: String
    let status: Bool
    let enterprise: String?
}

// belum final
protocol LoadDocument {
    func load() -> [Document]
}
