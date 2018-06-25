//
//  Model.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 11. 10..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Model { }

extension Model {
    struct User {
        let sid: Int
        let firebase_id: String
        let name: String
        let email: String
        let gender: String
        let pic1: String
        let profileUrl: URL?
        let profileUrlList: [URL]
        let heartCount: Int
        let hashlist: [Model.Hash]
        let recommend: String
        let pokeAt: Date?
        
        let loginResult: String
        
        init(json: JSON) {
            sid = json["sid"].intValue
            firebase_id = json["id_firebase"].stringValue
            name = json["user_name"].stringValue
            email = json["email"].stringValue
            gender = json["gender"].stringValue
            heartCount = json["heart_cnt"].intValue
            recommend = json["recomm_note"].stringValue
            hashlist = json["hash"].arrayValue.map({ (json: JSON) -> Model.Hash in return Model.Hash.init(json: json) })
            pic1 = json["pic1"].stringValue
            if let pic1 = json["pic1"].string { profileUrl = URL(string: "http://pumkit.com/\(pic1)") } else { profileUrl = nil }
            if let pic1 = json["pic1"].array {
                profileUrlList = pic1.map({ (json: JSON) -> URL in return URL(string: "http://pumkit.com/\(json["url"].stringValue)")! })
            }
            else { profileUrlList = [] }
            
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd"
            pokeAt = format.date(from: json["time_poke"].stringValue)
            loginResult = json["result_data"].stringValue
        }
        
    }
}

/* NewDateController - 주선자 선택 / 소개팅 상대 선택  */
extension Model {
    struct MatchmakerList {
        let matchmakers: [Model.User]
        init(json: JSON) {
            matchmakers = json["matchmakers"].arrayValue.map({ (json: JSON) -> Model.User in
                return Model.User(json: json)
            })
        }
    }
    
    struct BlindList {
        let blinds: [Model.User]
        init(json: JSON) {
            blinds = json["blind_list"].arrayValue.map({ (json: JSON) -> Model.User in
                return Model.User(json: json)
            })
        }
    }
}
/* NewDateController, OpenDateController - 친친팅 / 오픈팅  */
extension Model {
    struct ChinchinDate {
        let matchmaker: Model.User
        let blind: Model.Blind
        let dateAt: Date?
        
        init(json: JSON) {
            matchmaker = Model.User(json: json["match"])
            blind = Model.Blind(json: json["blind"])
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd"
            dateAt = format.date(from: json["time_date"].stringValue)
        }
    }
    
    struct OpenDate {
        let matchmaker: Model.User
        let blind: Model.Blind
        init(json: JSON) {
            matchmaker = Model.User(json: json["match"])
            blind = Model.Blind(json: json["blind"])
        }
    }
}

extension Model {
    struct DatedList {
        let list: [Model.ChinchinDate]
        let myProfileUrl: URL?
        
        init(json: JSON) {
            list = json["dated_list"].arrayValue.map({ (json: JSON) -> Model.ChinchinDate in return Model.ChinchinDate(json: json) })
            if let myPic = json["my_pic"].string { myProfileUrl = URL(string: "http://pumkit.com/\(myPic)") } else { myProfileUrl = nil }
        }
    }
    
    struct OpenDateList {
        let isAgreeOpenDate: Bool
        let list: [Model.OpenDate]
        init(json: JSON) {
            list = json["public_date"].arrayValue.map({ (json: JSON) -> Model.OpenDate in
                return Model.OpenDate(json: json)
            })
            isAgreeOpenDate = json["public_yn"].stringValue == "y"
        }
    }
}

extension Model {
    struct Hash {
        let sid: Int
        let hash_name: String
        let open: Int
        init(json: JSON) {
            sid = json["sid"].intValue
            hash_name = json["hash_name"].stringValue
            open = json["open"].intValue
        }
    }
}

extension Model {
    struct Menu {
        enum Controller {
            case friendDate
            case openDate
            case friendManage
            case myInfoManage
            case logout
        }
        
        let title: String
        let isNew: Bool
        let controller: Controller
        
        init(title: String, controller: Controller, isNew: Bool) {
            self.title = title
            self.controller = controller
            self.isNew = isNew
        }
    }
}

extension Model {
    struct Blind {
        let user: Model.User
        let appeal: String
        let recommend: String
        
        init(json: JSON) {
            user = Model.User(json: json)
            appeal = json["appeal"].stringValue
            recommend = json["recomm_note"].stringValue
        }
    }
}

extension Model {
    struct Profile {
        let type: String
        let match: Model.User
        let profile: Model.User
        init(json: JSON) {
            type = json["type"].stringValue
            match = Model.User(json: json["match"])
            profile = Model.User(json: json["profile"])
        }
    }
    
    struct Picture {
        let sid: Int
        let url: URL?
        let isMain: Int // == 1 is Main
        init(json: JSON) {
            sid = json["sid"].intValue
            isMain = json["main"].intValue
            if let myPic = json["url"].string { url = URL(string: "http://pumkit.com/\(myPic)") } else { url = nil }
        }
    }
    
    struct MyInfo {
        let name: String
        let profileUrl: URL?
        let isAgreeDate: Bool
        let isAgreeOpenDate: Bool
        let pokeCount: Int
        let pokeToMe: [Model.Poke]
        
        init(json: JSON) {
            name = json["user_name"].stringValue
            if let pic1 = json["pic1"].string { profileUrl = URL(string: "http://pumkit.com/\(pic1)") } else { profileUrl = nil }
            isAgreeDate = json["status"].stringValue == "y"
            isAgreeOpenDate = json["public_yn"].stringValue == "y"
            pokeCount = json["cnt_poke"].intValue
            pokeToMe = json["poke_to_me"].arrayValue.map({ (json: JSON) -> Model.Poke in
                return Model.Poke(json: json)
            })
        }
    }
}

extension Model {
    struct Poke {
        let type: String    // c: 친친 소개팅, p: 오픈 소개팅
        let match: Model.User
        let from: Model.User
        init(json: JSON) {
            type = json["type"].stringValue
            match = Model.User(json: json["match"])
            from = Model.User(json: json["from"])
        }
    }
}

extension Model {
    struct ManageBlind {
        let user: Model.User
        let friend: Model.User
        let pokes: [Model.Poke]
        
        init(json: JSON) {
            user = Model.User(json: json["my"])
            friend = Model.User(json: json["my_friend"])
            pokes = json["poke_to_my_fr"].arrayValue.map({ (json: JSON) -> Model.Poke in
                return Model.Poke(json: json)
            })
        }
    }
}
