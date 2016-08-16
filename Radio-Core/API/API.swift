//
//  API.swift
//  Radio
//
//  Created by Rodrigo Prestes on 7/8/16.
//
//

import Foundation

internal protocol APIble {
    
    static var requesting: Bool { get set }
    static func baseURL() -> String
    static func sessionConfiguration() -> NSURLSessionConfiguration
    
}

internal extension APIble {
    
    static func baseURL() -> String {
        return "https://r-a-d.io/api/"
    }
    
    private static func performRequest(route: String, asJson: Bool, completion: (response: AnyObject?, error: NSError?) -> Void) {
        
        let session = NSURLSession(configuration: self.sessionConfiguration())
        
        let url = NSURL(string: baseURL() + route)!
        let task = session.dataTaskWithURL(url) { data, response, error in
            if let responseData = data {
                if asJson == true {
                    do {
                        let object = try NSJSONSerialization.JSONObjectWithData(responseData, options: .MutableContainers)
                        dispatch_async(dispatch_get_main_queue(), {
                            completion(response: object, error: nil)
                        })
                    }
                    catch let error as NSError {
                        dispatch_async(dispatch_get_main_queue(), {
                            completion(response: nil, error: error)
                        })
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), {
                        completion(response: responseData, error: nil)
                    })
                }
                
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(response: nil, error: error)
            })
        }
        
        task.resume()
    }
    
    static func sessionConfiguration() -> NSURLSessionConfiguration {
        return NSURLSessionConfiguration.defaultSessionConfiguration();
    }
    
}

public struct RadioData {
    
    var nowPlaying: Track
    var dj: DJ
    var requestingAllowed: Bool = false
    var listeners: Int?
    
    var last = [Track]()
    var queue = [Track]()
    
    init(response: [String : AnyObject]) {
        let responseData = response["main"] as! [String : AnyObject]
        
        listeners = responseData["listeners"] as? Int
        
        nowPlaying = Track()
        nowPlaying.metadata = responseData["np"] as? String
        nowPlaying.start = NSDate(timeIntervalSince1970: responseData["start_time"] as! Double)
        nowPlaying.end = NSDate(timeIntervalSince1970: responseData["end_time"] as! Double)
        
        let startTime = nowPlaying.start!.timeIntervalSince1970
        nowPlaying.currentTime = responseData["current"] as! Double - startTime
        nowPlaying.endTime = nowPlaying.end!.timeIntervalSince1970 - startTime
        
        nowPlaying.start = NSDate().dateByAddingTimeInterval(Double(-nowPlaying.currentTime!))
        nowPlaying.end = NSDate().dateByAddingTimeInterval(Double(nowPlaying.endTime!))
        
        let djObject = responseData["dj"] as! [String : AnyObject]
        dj = DJ(object: djObject)
        dj.afk = responseData["isafkstream"] as? Bool
        
        requestingAllowed = responseData["requesting"] as! Bool
        
        func listTrack(object: [String : AnyObject]) -> Track {
            let track = Track()
            
            track.metadata = object["meta"] as? String
            track.start = NSDate(timeIntervalSince1970: object["timestamp"] as! Double)
            
            return track
        }
        
        if let lp = responseData["lp"] as? [[String : AnyObject]] {
            for trackObject in lp {
                let track = listTrack(trackObject)
                last.append(track)
            }
        }
        
        if let q = responseData["queue"] as? [[String : AnyObject]] {
            for trackObject in q {
                let track = listTrack(trackObject)
                queue.append(track)
            }
        }
    }
}

public struct RadioAPI: APIble {

    // MARK: - Base
    
    static var requesting: Bool = false
    
    // MARK - Requests
    // DOCUMENTATION: https://r-a-d.io/docs/
    
    public static func getData(completion: (data: RadioData?) -> Void) {
        if requesting == true {
            return
        }
        
        requesting = true
        
        self.performRequest("", asJson: true) { (response, error) in
            requesting = false
            
            if let responseData = response as? [String : AnyObject] {
                let data = RadioData(response: responseData)
                completion(data: data)
                return
            }
            
            completion(data: nil)
        }
    }
    
}

public struct ImageAPI: APIble {
    
    // MARK: - Base
    
    static let route = "dj-image/"
    static var requesting: Bool = false
    
    public static func imageURL(dj: DJ) -> String {
        return "\(baseURL())\(route)\(dj.id)"
    }
    
    // MARK - Requests
    
    public static func getDJImage(dj: DJ, completion: (image: NSData?) -> Void) {
        if requesting == true {
            return
        }
        
        requesting = true
        self.performRequest("\(route)\(dj.id)", asJson: false, completion: { (response, error) in
            requesting = false
            
            if let data = response as? NSData {
                completion(image: data)
                return
            }
            
            completion(image: nil)
        })
    }
    
    static func sessionConfiguration() -> NSURLSessionConfiguration {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration();
        configuration.HTTPAdditionalHeaders = [ "Content-Type" : "image/*" ]
        return configuration
    }
}
