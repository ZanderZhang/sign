
import Cocoa

@available(OSX 10.12, *)
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var mainView: MainView!
    let fileManager = FileManager.default
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        try? fileManager.removeItem(atPath: Log.logName)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    
    @IBAction func viewLog(_ sender: AnyObject) {
        NSWorkspace.shared.openFile(Log.logName)
    }
    
}

