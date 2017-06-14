//
//  Videos.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/8/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import RealmSwift
import SwiftyJSON

enum Kind: String {
    case Video = "youtube#video"
    case Playlist = "youtube#playlist"
    case Channel = "youtube#channel"
}

class Video: Object {
    
    var kind: Kind? = .Video
    
    dynamic var videoId: String!
    dynamic var publishedAt: Date!
    dynamic var channelId: String!
    dynamic var title: String!
    dynamic var descriptionVideo: String!
    dynamic var thumbnail: Thumbnail!
    dynamic var channelTitle: String!
    dynamic var duration: String!
    dynamic var dimension: String!
    dynamic var definition: String!
    dynamic var viewsCount: Int = 0
    dynamic var likesCount: Int = 0
    dynamic var dislikesCount: Int = 0
    dynamic var favoriteCount: Int = 0
    dynamic var commentsCount: Int = 0
    
    // Offline properties
    dynamic var offlinePath: String!
    dynamic var createdAt = NSDate()
    dynamic var modifiedAt = NSDate()
    
    convenience init(fromJson json: JSON){
        self.init()
        if json == nil{
            return
        }
        self.kind = Kind(rawValue: json["id"]["kind"].stringValue)
        videoId = json["id"].stringValue
        if videoId == "" {
            videoId = json["id"]["videoId"].stringValue
        }
        if let id = json["contentDetails"]["videoId"].string {
            videoId = id
        }
        if self.kind == .Playlist {
            videoId = json["id"]["playlistId"].stringValue
        }
        if self.kind == .Channel {
            videoId = json["id"]["channelId"].stringValue
        }
        let snippet = json["snippet"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let publishedAtString = snippet["publishedAt"].stringValue
        if publishedAtString != "" {
            publishedAt = dateFormatter.date(from: publishedAtString)!
        }
        
        channelId = snippet["channelId"].stringValue
        title = snippet["title"].stringValue
        descriptionVideo = snippet["description"].stringValue
        
        thumbnail = Thumbnail()
        thumbnail.basic = Image(url: snippet["thumbnails"]["default"]["url"].stringValue,
                                width: snippet["thumbnails"]["default"]["width"].intValue,
                                height: snippet["thumbnails"]["default"]["height"].intValue)
        
        thumbnail.medium = Image(url: snippet["thumbnails"]["medium"]["url"].stringValue,
                                 width: snippet["thumbnails"]["medium"]["width"].intValue,
                                 height: snippet["thumbnails"]["medium"]["height"].intValue)
        
        thumbnail.high = Image(url: snippet["thumbnails"]["high"]["url"].stringValue,
                               width: snippet["thumbnails"]["high"]["width"].intValue,
                               height: snippet["thumbnails"]["high"]["height"].intValue)
        
        thumbnail.maxres = Image(url: snippet["thumbnails"]["maxres"]["url"].stringValue,
                                 width: snippet["thumbnails"]["maxres"]["width"].intValue,
                                 height: snippet["thumbnails"]["maxres"]["height"].intValue)
        
        thumbnail.standard = Image(url: snippet["thumbnails"]["standard"]["url"].stringValue,
                                   width: snippet["thumbnails"]["standard"]["width"].intValue,
                                   height: snippet["thumbnails"]["standard"]["height"].intValue)
        channelTitle = snippet["channelTitle"].stringValue
        
        let contentDetails = json["contentDetails"]
        
        if let durationValue = contentDetails["duration"].string {
            duration = durationValue.formatDurationsFromYoutubeAPItoNormalTime(targetString: durationValue)
        }
        dimension = contentDetails["dimension"].stringValue
        definition = contentDetails["definition"].stringValue
        
        let statistics = json["statistics"]
        viewsCount = statistics["viewCount"].intValue
        likesCount = statistics["likeCount"].intValue
        dislikesCount = statistics["dislikeCount"].intValue
        favoriteCount = statistics["favoriteCount"].intValue
        commentsCount = statistics["commentCount"].intValue
    }
    
}

extension String{
    
    func formatDurationsFromYoutubeAPItoNormalTime (targetString : String) ->String{
        
        var timeDuration : NSString!
        let string: NSString = targetString as NSString
        
        if string.range(of: "H").location == NSNotFound && string.range(of: "M").location == NSNotFound{
            
            if string.range(of: "S").location == NSNotFound {
                timeDuration = NSString(format: "00:00")
            } else {
                var secs: NSString = targetString as NSString
                secs = secs.substring(from: secs.range(of: "PT").location + "PT".characters.count) as NSString
                secs = secs.substring(to: secs.range(of: "S").location) as NSString
                
                timeDuration = NSString(format: "00:%02d", secs.integerValue)
            }
        }
        else if string.range(of: "H").location == NSNotFound {
            var mins: NSString = targetString as NSString
            mins = mins.substring(from: mins.range(of: "PT").location + "PT".characters.count) as NSString
            mins = mins.substring(to: mins.range(of: "M").location) as NSString
            
            if string.range(of: "S").location == NSNotFound {
                timeDuration = NSString(format: "%02d:00", mins.integerValue)
            } else {
                var secs: NSString = targetString as NSString
                secs = secs.substring(from: secs.range(of: "M").location + "M".characters.count) as NSString
                secs = secs.substring(to: secs.range(of: "S").location) as NSString
                
                timeDuration = NSString(format: "%02d:%02d", mins.integerValue, secs.integerValue)
            }
        } else {
            var hours: NSString = targetString as NSString
            hours = hours.substring(from: hours.range(of: "PT").location + "PT".characters.count) as NSString
            hours = hours.substring(to: hours.range(of: "H").location) as NSString
            
            if string.range(of: "M").location == NSNotFound && string.range(of: "S").location == NSNotFound {
                timeDuration = NSString(format: "%02d:00:00", hours.integerValue)
            } else if string.range(of: "M").location == NSNotFound {
                var secs: NSString = targetString as NSString
                secs = secs.substring(from: secs.range(of: "H").location + "H".characters.count) as NSString
                secs = secs.substring(to: secs.range(of: "S").location) as NSString
                
                timeDuration = NSString(format: "%02d:00:%02d", hours.integerValue, secs.integerValue)
            } else if string.range(of: "S").location == NSNotFound {
                var mins: NSString = targetString as NSString
                mins = mins.substring(from: mins.range(of: "H").location + "H".characters.count) as NSString
                mins = mins.substring(to: mins.range(of: "M").location) as NSString
                
                timeDuration = NSString(format: "%02d:%02d:00", hours.integerValue, mins.integerValue)
            } else {
                var secs: NSString = targetString as NSString
                secs = secs.substring(from: secs.range(of: "M").location + "M".characters.count) as NSString
                secs = secs.substring(to: secs.range(of: "S").location) as NSString
                var mins: NSString = targetString as NSString
                mins = mins.substring(from: mins.range(of: "H").location + "H".characters.count) as NSString
                mins = mins.substring(to: mins.range(of: "M").location) as NSString
                
                timeDuration = NSString(format: "%02d:%02d:%02d", hours.integerValue, mins.integerValue, secs.integerValue)
            }
        }
        return timeDuration as String
    }
    
}
