//
//  InstallationManager.swift
//  XCMacUpdateApp
//
//  Created by yuan on 2020/06/29.
//  Copyright © 2020 xccn. All rights reserved.
//

import Foundation
import Zip

class InstallationManager {
    
    func installApp(progress: ((Float, String) -> Void)?, completion: ((Bool) -> Void)?) {
        progress?(0, "Starting download...".localized)
        downloadAppFrom(link: Config.appZipUrl, progress: { (downloadProgress) in
            debugPrint("Download progress: \(downloadProgress * 100)")
            progress?(downloadProgress * 0.8, "Downloading...".localized)
        }) { (success, filePath) in
            DispatchQueue.global(qos: .utility).async {
                if success && filePath != nil {
                    debugPrint("Downloaded to: \(filePath!)")
                    progress?(0.8, "Extracting...".localized)
                    if let paths = self.unzip(file: filePath!) {
                        progress?(0.9, "Installing...".localized)
                        if self.move(apps: paths, toFolder: Config.installationPath) {
                            progress?(1, "Installed".localized)
                            self.launch(apps: paths)
                            completion?(true)
                        } else {
                            progress?(1, "Installation failed".localized)
                            completion?(false)
                        }
                    } else {
                        progress?(1, "Extracting failed".localized)
                        completion?(false)
                    }
                } else {
                    progress?(1, "Download failed".localized)
                    completion?(false)
                }
            }
        }
    }
    
    private func downloadAppFrom(link: String, progress: @escaping ((Float) -> Void), completion: @escaping ((Bool, String?) -> Void)) {
        let url = URL(string: Config.appZipUrl)!
        let downloader = FileDownloader()
        downloader.onProgress = progress
        downloader.onCompletion = completion
        downloader.download(file: url.absoluteString)
    }
    
    private func unzip(file: String) -> [String]? {
        let fileManager = FileManager()
        let fileURL = URL(string: file)!
        let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("unzipped_files")
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try Zip.unzipFile(fileURL, destination: destinationURL, overwrite: true, password: nil)
            
            let contents = try fileManager.contentsOfDirectory(atPath: destinationURL.path)
            
            var appFiles = [String]()
            for file in contents {
                if file.hasSuffix(".app") {
                    let appPath = destinationURL.appendingPathComponent(file).path
                    debugPrint("Found an app: \(appPath)")
                    appFiles.append(appPath)
                }
            }
            return appFiles
        } catch let error {
            debugPrint("Unzipping error: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func move(apps: [String], toFolder folder: String) -> Bool {
        let fileManager = FileManager.default
        do {
            for appPath in apps {
                let appUrl = URL(fileURLWithPath: appPath)
                let folderUrl = URL(fileURLWithPath: folder)
                let destination = folderUrl.appendingPathComponent(appUrl.lastPathComponent)
                if fileManager.fileExists(atPath: destination.path) {
                    try fileManager.removeItem(at: destination)
                }
                
                try fileManager.moveItem(atPath: appPath, toPath: destination.path)
            }
            return true
        } catch let error {
            debugPrint("Files placing error: \(error.localizedDescription)")
            return false
        }
    }
    
    private func launch(apps: [String]) {
        for app in apps {
            let installationFolder = URL(fileURLWithPath: Config.installationPath)
            let appUrl = URL(fileURLWithPath: app)
            
            NSWorkspace.shared.open(installationFolder.appendingPathComponent(appUrl.lastPathComponent))
        }
    }
    
}
