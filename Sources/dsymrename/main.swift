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

func findFiles(inSubDirectory subDir: URL) -> [URL] {
    var files = [URL]()
    if let enumerator = FileManager.default.enumerator(at: subDir, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
        for case let fileURL as URL in enumerator {
            do {
                let fileAttributes = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
                if fileAttributes.isRegularFile == true {
                    files.append(fileURL)
                }
            } catch { print(error, fileURL) }
        }
    }
    return files
}

func findAndReplace(binName: String,
                    uuid: String,
                    subDir: URL,
                    files: [URL]) -> Result<(found: Bool, message: String?), Error> {
    if let binURL = files.first(where: { $0.lastPathComponent == binName }) {
        let uuidData = uuid.replacingOccurrences(of: "-", with: "").hexa.data
        let dsymUUID = subDir.lastPathComponent.dropLast(".dSYM".count)
        print("Found dSYM for binary image '\(binName)' with UUID: \(dsymUUID)")
        let dsym = dsymUUID
            .replacingOccurrences(of: "-", with: "")
            .lowercased()

        let dsymData = dsym.hexa.data

        do {
            var data = try Data(contentsOf: binURL)
            if let subRange = data.range(of: dsymData) {
                print("Replacing internal UUID \(dsymUUID) with \(uuid.lowercased())")
                data.replaceSubrange(subRange, with: uuidData)
                try data.write(to: binURL)
                return .success((found: true, message: "Success.\n\nYour dsym's internal UUID has been replaced. If you are using a tool like Crashlytics, please re-upload your .dSYM"))
            } else if data.range(of: uuidData) != nil {
                return .success((found: true, message: "The dSYM's internal UUID has already been replaced with \(uuid). Nothing to do.\n\nIf you are using a tool like Crashlytics, please re-upload your .dSYM"))
            }
        } catch {
            return .failure(error)
        }
    }
    return .success((found: false, message: nil))
}

let main = command(
    Argument<String>("binName", description: "The name of the binary image whose UUID you want to rename."),
    Argument<String>("UUID", description: "The new UUID the dsym should have."),
    Option("path", default: FileManager.default.currentDirectoryPath, description: "The path to the directory that contains the .dSYM files.")
    ) { binName, uuid, path in

    print("Binary image name provided: \(binName)\nLooking for .dSYM files at: \(path)")
    let subDirs = getSubdirectories(path: path)
    guard subDirs.contains(where: { $0.lastPathComponent.lowercased().contains(".dsym") }) else {
        print("No .dSYM files found at: \(path)")
        return
    }
    for subDir in subDirs {
        let files = findFiles(inSubDirectory: subDir)
        let result = findAndReplace(binName: binName, uuid: uuid, subDir: subDir, files: files)
        switch result {
        case .success(let value):
            if value.found {
                if let text = value.message {
                    print(text)
                }
                exit(0)
            }
        case .failure(let error):
            print(error)
        }
    }
    print("No dSYM found for binary image '\(binName)'")
}

main.run()
