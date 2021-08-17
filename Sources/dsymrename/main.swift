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
        let url = subDir
        var files = [URL]()
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
                    if fileAttributes.isRegularFile == true {
                        files.append(fileURL)
                    }
                } catch { print(error, fileURL) }
            }
        }
        if let libUrl = files.first(where: { $0.lastPathComponent == libName }) {
            let dsymUUID = subDir.lastPathComponent.dropLast(".dSYM".count)
            print("Found dSYM for library '\(libName)' with UUID: \(dsymUUID)")
            let dsym = dsymUUID
                .replacingOccurrences(of: "-", with: "")
                .lowercased()

            let dsymData = dsym.hexa.data

            do {
                var data = try Data(contentsOf: libUrl)
                if let subRange = data.range(of: dsymData) {
                    print("Replacing internal UUID \(dsymUUID) with \(uuid.lowercased())")
                    data.replaceSubrange(subRange, with: uuidData)
                    try data.write(to: libUrl)
                    print("Success.\n\nYour dsym's internal UUID has been replaced. If you are using a tool like Crashlytics, please re-upload your .dSYM")
                    return
                } else if data.range(of: uuidData) != nil {
                    print("The dSYM's internal UUID has already been replaced with \(uuid). Nothing to do.\n\nIf you are using a tool like Crashlytics, please re-upload your .dSYM")
                    return
                }
            } catch { print(error) }
        }
    }
    print("No dSYM found for library '\(libName)'")
}

main.run()
