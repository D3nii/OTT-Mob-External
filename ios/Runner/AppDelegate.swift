import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    private lazy var dartDefines: [String: String] = {
        guard let dartDefinesString = Bundle.main.object(forInfoDictionaryKey: "DART_DEFINES") as? String else {
            fatalError("DART_DEFINES not found in Info.plist. Please ensure dart defines are properly configured.")
        }
        
        var dartDefinesDictionary: [String: String] = [:]
        
        for item in dartDefinesString.components(separatedBy: ",") {
            guard let data = Data(base64Encoded: item),
                  let decoded = String(data: data, encoding: .utf8) else {
                continue
            }
            
            let keyValue = decoded.components(separatedBy: "=")
            if keyValue.count == 2 {
                dartDefinesDictionary[keyValue[0]] = keyValue[1]
            }
        }
        
        return dartDefinesDictionary
    }()
    
    private func getRequiredDartDefine(key: String) -> String {
        guard let value = dartDefines[key], !value.isEmpty else {
            fatalError("\(key) is not defined in dart defines or is empty. Please ensure \(key) is properly configured.")
        }
        return value
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let googleMapsApiKey = getRequiredDartDefine(key: "GOOGLE_MAPS_API_KEY")
        GMSServices.provideAPIKey(googleMapsApiKey)
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
