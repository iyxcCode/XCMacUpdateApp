//
//  ViewController.swift
//  XCMacUpdateApp
//
//  Created by yuan on 2020/06/25.
//  Copyright © 2020 xccn. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var actionLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.stringValue = "{{app_name}} Installer".replacingOccurrences(of: "{{app_name}}", with: Config.appName)

        let installationManager = InstallationManager()
        installationManager.installApp(progress: { (progress, message) in
            debugPrint("Progress: \(progress), message: \(message)")
            DispatchQueue.main.async {
                self.progressIndicator.doubleValue = Double(progress)
                self.actionLabel.stringValue = message
            }
        }) { (success) in
            debugPrint("Installed: \(success)")
            if success {
                DispatchQueue.main.async {
                    self.actionLabel.stringValue = "Done".localized
                }
                NSApplication.shared.terminate(nil)
            } else {
                DispatchQueue.main.async {
                    self.actionLabel.stringValue = "Failed".localized
                }
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

