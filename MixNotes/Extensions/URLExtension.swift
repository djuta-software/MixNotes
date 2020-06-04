import Foundation

extension URL {
    
    func isRemote() -> Bool {
        return lastPathComponent.hasPrefix(".") && lastPathComponent.hasSuffix(".icloud")
    }
    
    func getDisplayName() -> String {
        if(!isRemote()) {
            return lastPathComponent
        }
        var file = lastPathComponent
        file = file.replacingOccurrences(of: ".icloud", with: "")
        file.remove(at: file.startIndex)
        return file
    }
    
    func getLocalURL() -> URL {
        if(!isRemote()) {
            return self
        }
        let filename = getDisplayName()
        return deletingLastPathComponent().appendingPathComponent(filename)
    }
    
    func getRemoteURL() -> URL {
        if(isRemote()) {
            return self
        }
        let filename = "." + lastPathComponent + ".icloud"
        return deletingLastPathComponent().appendingPathComponent(filename)
    }
}
