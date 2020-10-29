## XCMacUpdateApp

#### Mac上应用版本更新，自动安装更新包

- 下载Zip安装包
- 提取压缩文件中安装包
- 安装对应的dmg安装包
- 下载安装进度提示


#### 使用方式
- 将Mac APP dmg或pkg包进行压缩
- 上传到服务器可下载压缩包
- 在Config 中配置相关参数


#### 安装更新包
```
let installationFolder = URL(fileURLWithPath: Config.installationPath)
let appUrl = URL(fileURLWithPath: app)
            
NSWorkspace.shared.open(installationFolder.appendingPathComponent(appUrl.lastPathComponent))
```


#### 移动安装包
```
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
```

#### 解压缩安装包

```
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
```
