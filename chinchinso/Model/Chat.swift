//
//  Chat.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 12. 9..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import Foundation
import SwiftyJSON

enum FIREBASE_KEY: String {
    case chatting = "user-match-messages"
    case users = "users"
    case messages = "messages"
}

enum STORAGE_KEY: String {
    case images = "message_images"
}

struct Chat {}

extension Chat {
    struct Message {
        var messageId: String?
        
        let fromId: String
        let toId: String
        let matchId: String
        let message: String
        let timestamp: NSNumber
        let unread: NSNumber
        
        let image_url: String
        let image_width: NSNumber
        let image_height: NSNumber
        
        init(json: JSON) {
            fromId = json["fromId"].stringValue
            toId = json["toId"].stringValue
            matchId = json["matchId"].stringValue
            message = json["text"].stringValue
            timestamp = json["timestamp"].numberValue
            unread = json["unread"].numberValue
            
            image_url = json["imageUrl"].stringValue
            image_width = json["imageWidth"].numberValue
            image_height = json["imageHeight"].numberValue
        }
        mutating func setMessageId(id: String) { messageId = id }
        func getBlindId() -> String { return GlobalState.instance.firebaseId ?? "" == fromId ? toId : fromId }
    }
}

extension Chat {
    struct User {
        let profileUrl: URL?
        let sid: Int
        let fcmToken: String
        let name: String
        
        init(json: JSON) {
            if let url = json["img_url"].string { profileUrl = URL(string: "http://pumkit.com/\(url)") } else { profileUrl = nil }
            sid = json["myid"].intValue
            fcmToken = json["token"].stringValue
            name = json["username"].stringValue
        }
    }
}

extension Chat {
    struct Chatting {
        let lastMessageId : String?
        var lastMessage: Chat.Message?
        let matchmaker: Chat.User?
        let blind: Chat.User?
        
        init(dictionary: [String: Any]){
            lastMessageId = dictionary["messageId"] as? String
            lastMessage = dictionary["lastMessage"] as? Chat.Message
            matchmaker = dictionary["matchmaker"] as? Chat.User
            blind = dictionary["blind"] as? Chat.User
        }
    }
}
