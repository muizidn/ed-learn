import Foundation

public final class DevToolsManager {
    public static let shared = DevToolsManager()
    public var userDefinedTools = [DevToolModel]()
    

    public func showDevTools() {
        guard let vc = UIApplication.shared.keyWindow?.rootViewController else { fatalError() }
        let nav = UINavigationController(rootViewController: DevToolsViewController())
        vc.present(nav, animated: true, completion: nil)
    }
}
