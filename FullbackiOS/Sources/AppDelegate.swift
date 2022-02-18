import UIKit
import DomainModule
#if DEVELOPMENT || DEBUG
import DevTools
import FLEX
#endif

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let window = FullbackWindow(frame: UIScreen.main.bounds)
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

enum EnvironmentType: String {
    case dev
    case stg
    case prod
}

class Environment {
    static let shared = Environment()
    private init() {}
    var type: EnvironmentType = .dev
}

final class FullbackWindow: UIWindow {}

extension FullbackWindow {
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        if motion == .motionShake {
#if DEVELOPMENT || DEBUG
            DevToolsManager.shared.userDefinedTools = [
                DevToolModel(name: "Testing Environment",
                             description: "Change dev, stg, prod environment (REQUIRES RELAUNCH APPLICATION ‼️)",
                             type: .options(options: [EnvironmentType.dev, .stg, .prod].map({ $0.rawValue }),
                                            current: {
                                                UserDefaults.standard.string(forKey: "app-env") ?? Environment.shared.type.rawValue
                                            },
                                            onSet: {
                                                UserDefaults.standard.set($0, forKey: "app-env")
                                                Environment.shared.type = EnvironmentType(rawValue: $0)!
                                            })),
                DevToolModel(name: "FLEX",
                     description: "Show FLEX Runtime Debuggger",
                     type: .functionCall(call: { FLEXManager.shared.showExplorer() }))
            ]
            DevToolsManager.shared.showDevTools()
#endif
        }
    }
}
