//
//  DevToolsViewController.swift
//  DevTools
//
//  Created by Muhammad Muizzsudin on 16/02/22.
//

import Foundation

public struct DevToolModel {
    public let name: String
    public let description: String
    public let type: DevToolType
    
    public init(name: String, description: String, type: DevToolType) {
        self.name = name
        self.description = description
        self.type = type
    }
}

public enum DevToolType {
    case options(
        options: [String],
        current: () -> String?,
        onSet: (String) -> Void
    )
    case functionCall(call: () -> Void)
}

final class DevToolsViewController: UITableViewController {
    private let defaultTools = [DevToolModel]()
    private lazy var tools = (defaultTools + DevToolsManager.shared.userDefinedTools)
        .sorted(by: { $0.name < $1.name })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DevTools"
        tableView.register(DevToolsTableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tools.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DevToolsTableViewCell
        cell.textLabel?.text = tools[indexPath.row].name
        cell.detailTextLabel?.text = tools[indexPath.row].description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tool = tools[indexPath.row]
        switch tool.type {
        case .options(let options, let current, let onSet):
            let alertController = UIAlertController(
                title: tool.name,
                message: tool.description,
                preferredStyle: .actionSheet
            )
            for env in options {
                let currentPrefix = current() == env ? "✅ " : ""
                alertController.addAction(UIAlertAction(title: currentPrefix + env, style: .default, handler: { _ in
                    onSet(env)
                }))
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            }))
            present(alertController, animated: true, completion: nil)
        case .functionCall(let call):
            call()
        }
    }
}

final class DevToolsTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
