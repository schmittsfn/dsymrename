import Foundation
import Commander

func getSubdirectories(path: String) -> [URL] {
    do {
        let url: URL = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        return try url.subDirectories()
    } catch {
        print(error)
        return []
    }
}

let main = command(
    Argument<String>("libName", description: "The name of the library whose UUID you want to rename."),
    Argument<String>("UUID", description: "The new UUID the dsym should have."),
    Option("path", default: FileManager.default.currentDirectoryPath, description: "The path to the directory that contains the .dSYM files.")
    ) { libName, uuid, path in
    
    print("Library name provided: \(libName)\nLooking for .dSYM files at: \(path)")
    let subDirs = getSubdirectories(path: path)
    guard subDirs.contains(where: { $0.lastPathComponent.lowercased().contains(".dsym") }) else {
        print("No .dSYM files found at: \(path)")
        return
    }
    
    let uuidStr = uuid.replacingOccurrences(of: "-", with: "").lowercased()
    let uuidData = uuidStr.hexa.data
        
    for subDir in subDirs {
//        print("Processing \(subDir.lastPathComponent)")
        
        let url = subDir
        var files = [URL]()
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    if fileAttributes.isRegularFile == true {
                        files.append(fileURL)
                    }
                } catch { print(error, fileURL) }
            }
        }
        if let libUrl = files.first(where: { $0.lastPathComponent == libName }) {
            let dsymUUID = subDir.lastPathComponent
                .dropLast(".dSYM".count)
            print("Found dSYM for library '\(libName)' with UUID: \(dsymUUID)")
            let dsym = dsymUUID
                .replacingOccurrences(of: "-", with: "")
                .lowercased()
            
            let dsymData = dsym.hexa.data
            
            do {
                var data = try Data(contentsOf: libUrl)
    //            var dataRange = NSRange(location: 0, length: data.length)
    //            var handNumbers: [Int32] = [Int32](repeating: 0, count: data.length)
    //            data.getBytes(&handNumbers, range: dataRange)
    //            handNumbers.forEach({ print(String(format:"%02X", $0)) })
//                print(data.hexEncodedString())
                
                if let subRange = data.range(of: dsymData) {
                    print("Replacing \(dsymUUID) with \(uuid.lowercased())")
                    data.replaceSubrange(subRange, with: uuidData)
                    try data.write(to: libUrl)
                    print("Success.")
                    return
                }
                
                if let subRange = data.range(of: uuidData) {
                    print(subRange)
                }
                
                var str: String = ""
                for (i, element) in data.enumerated() {
                    str += String(format: "%02hhx", element)
                    if str.hasSuffix(uuidStr) {
                        
                    }
                }
                
                
                
                
                
            } catch { print(error) }
        }
    }
}

main.run()

