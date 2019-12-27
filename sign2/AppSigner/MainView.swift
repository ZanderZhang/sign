import Cocoa
@available(OSX 10.12, *)
class MainView: NSView, NSTextFieldDelegate{
    
    @IBOutlet weak var NewApplicationIDTextField: NSTextField!
    @IBOutlet weak var appDisplayName: NSTextField!
    @IBOutlet weak var ipa: NSTextField!
    @IBOutlet weak var p12: NSTextField!
    @IBOutlet weak var pp: NSTextField!
    @IBOutlet weak var password: NSTextField!
    @IBOutlet weak var message: NSTextField!
    var outputFile: String?
    let fileManager = FileManager.default
    @IBOutlet weak var startBtn: NSButton!
    @IBOutlet weak var suoBtn: NSButton!
    
    
    var fileTypeIsOk = false
    let chmodPath = "/bin/chmod"
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(sender) == true {
            self.fileTypeIsOk = true
            return .copy
        } else {
            self.fileTypeIsOk = false
            return NSDragOperation()
        }
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        if self.fileTypeIsOk {
            return .copy
        } else {
            return NSDragOperation()
        }
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        if let board = pasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray {
            if let filePath = board[0] as? String {
                switch(filePath.pathExtension.lowercased()){
                case "ipa":ipa.stringValue = filePath;break
                case "p12":p12.stringValue = filePath;break
                case "mobileprovision":pp.stringValue = filePath;break
                default:ipa.stringValue = filePath;break
                }
                return true
            }
        }
        return false
    }
    
    func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        return true
    }
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        if #available(OSX 10.13, *) {
            registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL, NSPasteboard.PasteboardType.URL])
        } else {
        }
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        if #available(OSX 10.13, *) {
            registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL, NSPasteboard.PasteboardType.URL])
        } else {
        }
        
    }
    
    @IBAction func qusuo(_ sender: NSButton) {
        if ipa.stringValue=="" {message.stringValue="ipa不存在";return}
        if ipa.stringValue.pathExtension != "ipa" {message.stringValue="ipa选择错误，ipa结尾";return}
        if(!fileManager.fileExists(atPath: ipa.stringValue)) {message.stringValue="ipa路径不存在";return}
        let hook = Bundle.main.path(forResource: "hook", ofType: "")
        let otl = Bundle.main.path(forResource: "otl", ofType: "")
        let jtl = Bundle.main.path(forResource: "jtl", ofType: "")
        self.message.stringValue="执行中..";self.suoBtn.isEnabled=false
        self.outputFile=ipa.stringValue.stringByDeletingPathExtension+"-ok.ipa"
        DispatchQueue.global().async {
            CommandRunner.async(shellPath: hook!, arguments:[otl!,jtl!,self.ipa.stringValue,self.outputFile!], output: { (out) in
                self.setStatus(out)
            }) { (end) in
                self.suoBtn.isEnabled=true
                self.message.stringValue="去锁完成，点击此处查看"
            }
        }
    }
    @IBAction func run(_ sender: NSButton) {
        
        let hook1 = Bundle.main.path(forResource: "hook1", ofType: "")
        let signall = Bundle.main.path(forResource: "signall", ofType: "")
        let sign = Bundle.main.path(forResource: "Sign", ofType: "")
        _ = Process().execute(self.chmodPath, workingDirectory: nil, arguments: ["+x", hook1!])
        
        _ = Process().execute(self.chmodPath, workingDirectory: nil, arguments: ["+x", signall!])
        _ = Process().execute(self.chmodPath, workingDirectory: nil, arguments: ["+x", hook1!])
        if(ipa.stringValue.pathExtension != "ipa"){
            
            
            if(directoryExistsAtPath(ipa.stringValue)){
                
                if p12.stringValue=="" {message.stringValue="证书不存在";return}
                if p12.stringValue.pathExtension != "p12" {message.stringValue="证书选择错误，p12结尾";return}
                if(!fileManager.fileExists(atPath: p12.stringValue)) {message.stringValue="证书路径不存在";return}
                
                
                if pp.stringValue=="" {message.stringValue="描述文件不存在";return}
                if pp.stringValue.pathExtension != "mobileprovision" {message.stringValue="描述文件选择错误，mobileprovision结尾";return}
                if(!fileManager.fileExists(atPath: pp.stringValue)) {message.stringValue="描述文件路径不存在";return}
                
                self.message.stringValue="执行中..";self.startBtn.isEnabled=false
                
                DispatchQueue.global().async {
                    
                    let start = CFAbsoluteTimeGetCurrent()
                    CommandRunner.async(shellPath: signall!, arguments:[self.ipa.stringValue,sign!,self.p12.stringValue,self.password.stringValue,self.pp.stringValue], output: { (out) in
                        self.setStatus(out)
                        if(out.contains("密码错误")||out.contains("描述文件不存在")){
                            self.message.stringValue="密码错误";self.startBtn.isEnabled=true;return
                        }
                        
                    }) { (end) in
                        if(self.message.stringValue=="密码错误"){return}
                        self.outputFile=self.ipa.stringValue+"-ok"
                        self.startBtn.isEnabled=true
                        let t = CFAbsoluteTimeGetCurrent()-start
                        self.message.stringValue="文件夹签名完成，总共"+String.init(format: "%.2f", t)+"s，点击此处查看"
                    }
                }
            }else{
                message.stringValue="文件夹不存在"
            }
            return
        }
        
        if ipa.stringValue=="" {message.stringValue="ipa不存在";return}
        if ipa.stringValue.pathExtension != "ipa" {message.stringValue="ipa选择错误，ipa结尾";return}
        if(!fileManager.fileExists(atPath: ipa.stringValue)) {message.stringValue="ipa路径不存在";return}
        
        
        if p12.stringValue=="" {message.stringValue="证书不存在";return}
        if p12.stringValue.pathExtension != "p12" {message.stringValue="证书选择错误，p12结尾";return}
        if(!fileManager.fileExists(atPath: p12.stringValue)) {message.stringValue="证书路径不存在";return}
        
        
        if pp.stringValue=="" {message.stringValue="描述文件不存在";return}
        if pp.stringValue.pathExtension != "mobileprovision" {message.stringValue="描述文件选择错误，mobileprovision结尾";return}
        if(!fileManager.fileExists(atPath: pp.stringValue)) {message.stringValue="描述文件路径不存在";return}
        
        
        
        
        self.startBtn.isEnabled=false
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-HH-mm"
        outputFile=ipa.stringValue.stringByDeletingPathExtension+"-"+formatter.string(from: Date())+".ipa"
        self.message.stringValue="执行中..";self.startBtn.isEnabled=false
        
        DispatchQueue.global().async {
            CommandRunner.async(shellPath: sign!, arguments:["-b",self.NewApplicationIDTextField.stringValue,"-n",self.appDisplayName.stringValue,"-p",self.password.stringValue, "-k",self.p12.stringValue,"-m",self.pp.stringValue,"-o",self.outputFile!,"-z 9",self.ipa.stringValue,"-l",hook1!], output: { (out) in
                self.setStatus(out)
                if(out.contains("密码错误")){
                    DispatchQueue.main.async {
                        self.message.stringValue="密码错误";self.startBtn.isEnabled=true
                    }
                }
            }) { (end) in
                if(self.message.stringValue=="密码错误"){return}
                self.startBtn.isEnabled=true
                self.message.stringValue="签名完成，点击此处查看"
            }
        }
    }
    fileprivate func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setStatus("准备")
        
        if checkXcodeCLI() == false {
            if #available(OSX 10.10, *) {
                let _ = installXcodeCLI()
            } else {
                let alert = NSAlert()
                alert.messageText = "请先安装Xcode后重启应用"
                alert.runModal()
            }
            NSApplication.shared.terminate(self)
        }
        
    }
    
    func installXcodeCLI() -> AppSignerTaskOutput {
        return Process().execute("/usr/bin/xcode-select", workingDirectory: nil, arguments: ["--install"])
    }
    
    func checkXcodeCLI() -> Bool {
        if #available(OSX 10.10, *) {
            if Process().execute("/usr/bin/xcode-select", workingDirectory: nil, arguments: ["-p"]).status   != 0 {
                return false
            }
        } else {
            if Process().execute("/usr/sbin/pkgutil", workingDirectory: nil, arguments: ["--pkg-info=com.apple.pkg.DeveloperToolsCLI"]).status != 0 {
                return false
            }
        }
        return true
    }
    
    func setStatus(_ status: String){
        Log.write(status)
        if (!Thread.isMainThread){
            DispatchQueue.main.sync{
                setStatus(status)
            }
        }
        else{
            message.stringValue = status
        }
    }
    
    func controlsEnabled(_ enabled: Bool){
        
    }
    
    @IBAction func doBrowse(_ sender: AnyObject) {
        var allowedFileTypes = ["ipa"];
        if(sender.tag! == 2){
            allowedFileTypes = ["p12"]
        }else if(sender.tag! == 3){
            allowedFileTypes = ["mobileprovision"]
        }
        let openDialog = NSOpenPanel()
        openDialog.canChooseFiles = true
        openDialog.canChooseDirectories = false
        openDialog.allowsMultipleSelection = false
        openDialog.allowsOtherFileTypes = false
        openDialog.allowedFileTypes = allowedFileTypes
        openDialog.runModal()
        if let filename = openDialog.urls.first {
            if(sender.tag! == 1){
                ipa.stringValue=filename.path
            }else if(sender.tag! == 2){
                p12.stringValue=filename.path
            }else if(sender.tag! == 3){
                pp.stringValue=filename.path
            }
        }
    }
    
    @IBAction func statusLabelClick(_ sender: NSButton) {
        if let outputFile = self.outputFile {
            if fileManager.fileExists(atPath: outputFile) {
                NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: outputFile)])
            }
        }
    }
}

