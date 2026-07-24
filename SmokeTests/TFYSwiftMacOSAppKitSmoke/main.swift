import Foundation
import AppKit
import TFYSwiftMacOSAppKit

@main
enum TFYSwiftMacOSAppKitSmoke {
    static func main() {
        // Chain core
        let view = NSView()
        _ = view.chain.frame(NSRect(x: 0, y: 0, width: 10, height: 10)).build
        
        // Cache config + sync path (re-entrant safe)
        var config = TFYCacheConfig.smallMemory()
        config.enableObfuscation = false
        config.enableStatistics = true
        assert(TFYSwiftCacheKit.shared.updateConfig(config))
        let key = "smoke_key"
        switch TFYSwiftCacheKit.shared.setCacheSync("hello", forKey: key) {
        case .success:
            break
        case .failure(let error):
            fatalError("setCacheSync failed: \(error)")
        }
        switch TFYSwiftCacheKit.shared.getCacheSync(String.self, forKey: key) {
        case .success(let value):
            assert(value == "hello")
        case .failure(let error):
            fatalError("getCacheSync failed: \(error)")
        }
        
        // Array Hashable dedupe
        let deduped = [1, 2, 2, 3].removingDuplicates()
        assert(deduped == [1, 2, 3])
        
        // Notification name still exists for demos
        _ = Notification.Name.exampleNotification
        
        print("TFYSwiftMacOSAppKitSmoke: OK")
    }
}
