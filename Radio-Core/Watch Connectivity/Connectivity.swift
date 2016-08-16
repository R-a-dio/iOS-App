//
//  Connectivity.swift
//  Radio
//
//  Created by Rodrigo Prestes on 7/11/16.
//
//

import WatchConnectivity

public enum ConnectivityMethod: Int {
    case Play
    case Stop
}

public class RadioContext: NSObject {
    
    private enum RepresentationKeys: String {
        case Metadata
        case StartDate
        case EndTime
        case ImageData
        case Playing
    }
    
    public var isPlaying: Bool?
    public var nowPlaying: Track?
    public var dj: DJ?
    
    convenience init(representation: [String : AnyObject]) {
        self.init()
        
        if let playing = representation[RepresentationKeys.Playing.rawValue] as? Bool {
            isPlaying = playing
        }
        
        if let metadata = representation[RepresentationKeys.Metadata.rawValue] as? String {
            let track = Track()
            track.metadata = metadata
            track.start = representation[RepresentationKeys.StartDate.rawValue] as? NSDate
            track.endTime = representation[RepresentationKeys.EndTime.rawValue] as? Double
            nowPlaying = track
        }
            
        if let _ = representation[DJKey.id.rawValue] as? Int {
            let newDJ = DJ(object: representation)
            newDJ.imageData = representation[RepresentationKeys.ImageData.rawValue] as? NSData
            dj = newDJ
        }
    }
    
    func representation() -> [String : AnyObject] {
        var representation = [String : AnyObject]()
        representation[RepresentationKeys.Playing.rawValue] = isPlaying
        
        if let np = nowPlaying {
            representation[RepresentationKeys.Metadata.rawValue] = np.metadata
            representation[RepresentationKeys.StartDate.rawValue] = np.start
            representation[RepresentationKeys.EndTime.rawValue] = np.endTime
        }
        
        if let validDJ = dj {
            representation[DJKey.id.rawValue] = validDJ.id
            representation[DJKey.djname.rawValue] = validDJ.name
            representation[RepresentationKeys.ImageData.rawValue] = validDJ.imageData
        }
        
        return representation
    }
    
}

public protocol ConnectivityDelegate {
    func connectivityUpdatedContext(context: RadioContext)
}

public protocol ConnectivityDataSource {
    func connectivityCalledMethod(method: ConnectivityMethod)
}

public class Connectivity: NSObject, WCSessionDelegate {
    
    // MARK: - Properties

    private static let MethodKey = "Method"
    private let session = WCSession.defaultSession()
    
    public var delegate: ConnectivityDelegate?
    public var dataSource: ConnectivityDataSource?
    
    // MARK: - Operations

    public func startSession() {
        if WCSession.isSupported() && session.activationState != .Activated {
            session.delegate = self
            session.activateSession()
        }
    }
    
    // MARK: - Send
    
    public func sendContext(context: RadioContext) {
        #if os(iOS)
            if session.paired && session.watchAppInstalled && session.activationState == .Activated {
                do {
                    try session.updateApplicationContext(context.representation())
                }
                catch {
                    NSLog("Could not update watch context")
                }
            }
        #endif
    }
    
    public func sendMethod(method: ConnectivityMethod) {
        session.sendMessage([Connectivity.MethodKey : method.hashValue], replyHandler: nil) { (error) in
            NSLog("Error sending message: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Session Delegate
    
    public func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        dispatch_async(dispatch_get_main_queue()) { 
            self.delegate?.connectivityUpdatedContext(RadioContext(representation: applicationContext))
        }
    }
    
    public func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        receiveMessage(message)
    }
    
    public func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        receiveMessage(message)
        replyHandler([String : AnyObject]())
    }
    
    private func receiveMessage(message: [String : AnyObject]) {
        if let raw = message[Connectivity.MethodKey] as? Int, method = ConnectivityMethod(rawValue: raw) {
            dispatch_async(dispatch_get_main_queue(), {
                self.dataSource?.connectivityCalledMethod(method)
            })
        }
    }

}
