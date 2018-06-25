//
//  API.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 11. 3..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Firebase

enum OPT: String {
    case join = "join"
    case login = "login"
    case account = "account"
    case fetchContacts = "auto_fr_req"
    
    // ChinchinDate
    case datedList = "dated_list"
    case myMatchlist = "my_match_list"
    case pickMatch = "pick_match"
    case pickBlind = "pick_blind"
    
    // OpenDate
    case publicDate = "public_date"
    case poke = "poke"
    
    // MyInfo
    case profile = "profile"
    case myPage = "my_page"
    case myPictures = "my_pics"
    case uploadPicture = "upload_profile"
    case delPicture = "del_profile"
    case updateMainPicture = "set_profile_main"
    case modifyDateStatus = "update_date_yn"
    case modifyOpenDateStatus = "update_publicdate_yn"
    
    // Hash
    case myHash = "my_hash"
    case getHash = "get_hash"
    case delHash = "del_hash"
    case addHash = "make_hash"
    case modHash = "update_hash_open"

    // Friend
    case manageBlind = "iam_match"
    case friendsList = "list_friend"
    case chooseFriend = "choose_public_friend"
    case uploadRecommend = "edit_rocomm"
}


protocol API {
//    typealias UserResponseHandler = (DataResponse<Model.User>) -> Void
    typealias DatedListResponseHandler = (DataResponse<Model.DatedList>) -> Void
    typealias MatchmakerListResponseHandler = (DataResponse<Model.MatchmakerList>) -> Void
    typealias BlindListResponseHandler = (DataResponse<Model.BlindList>) -> Void
    typealias DateResponseHandler = (DataResponse<Model.ChinchinDate>) -> Void
    
    typealias OpenDateResponseHandler = (DataResponse<Model.OpenDateList>) -> Void
    
    typealias MyInfoResponseHandler = (DataResponse<Model.MyInfo>) -> Void
    
    func login(email: String, password: String, handler: @escaping () -> Void)
    func join(email: String, password: String, name: String, age: Int, phone: String, gender: String, handler: @escaping () -> Void)
    func fetchContacts(phones: String)
    
    func account(handler: @escaping (DataResponse<Model.User>) -> Void)
    func getDatedList(handler: @escaping DatedListResponseHandler)
    func getMatchmakerList(handler: @escaping MatchmakerListResponseHandler)
    func pickMatchmaker(matchmaker: Model.User, handler: @escaping BlindListResponseHandler)
    func pickBlind(matchmaker: Model.User, blind: Model.User, handler: @escaping DateResponseHandler)
    
    func openBlind(handler: @escaping OpenDateResponseHandler)
    func poke(matchmaker: Int, poke: Int, handler: @escaping (DataResponse<JSON>) -> Void)
    
    func getMyInfo(handler: @escaping MyInfoResponseHandler)
    func getMyProfile(handler: @escaping (DataResponse<Model.Profile>) -> Void)
    func getMyPicture(handler: @escaping (DataResponse<[Model.Picture]>) -> Void)
    func manageBlind(handler: @escaping (DataResponse<Model.ManageBlind>) -> Void)
    func setMainProfilePicture(picture: Int, handler: @escaping (DataResponse<JSON>) -> Void)
    func uploadPicture(isMain: Int, handler: @escaping (DataResponse<JSON>) -> Void)
    func deletePicture(picture: Int, handler: @escaping (DataResponse<JSON>) -> Void)
    func modifyDateStatus(yn: String, handler: @escaping (DataResponse<JSON>) -> Void)
    func modifyOpenDateStatus(yn: String, handler: @escaping (DataResponse<JSON>) -> Void)
    
    func pushNotification(message: String, fcmToken: String, handler: @escaping () -> Void)
    
    func getUserInfo(firebaseId: String, handler: @escaping (Chat.User) -> Void)
    func getMyHash(handler: @escaping (DataResponse<([Model.Hash], [Model.Hash])>) -> Void)
    func getHash(hashId: Int, handler: @escaping (DataResponse<JSON>) -> Void)
    func delHash(hashId: Int, handler: @escaping (DataResponse<JSON>) -> Void)
    func addHash(hashName: String, handler: @escaping (DataResponse<JSON>) -> Void)
    func modHash(hashId: Int, open: Int, handler: @escaping (DataResponse<JSON>) -> Void)
    
    func getFriendsList(handler: @escaping(DataResponse<[Model.User]>) -> Void)
    func chooseFriend(friend: Int, handler: @escaping(DataResponse<JSON>) -> Void)
    func uploadRecommend(recommend: String, handler: @escaping(DataResponse<JSON>) -> Void)
}

struct PumkitAPI: API {
   
    static let FIREBASE = Database.database().reference()
    static let shared = PumkitAPI()
    
    func login(email: String, password: String, handler: @escaping () -> Void) {
        
        let bytes: Array<UInt8> = password.bytes // Array("password".utf8)
        let cryptoPassword = bytes.sha512().toHexString()
        
        Auth.auth().signIn(withEmail: email, password: cryptoPassword) { (user, error) in
            if error != nil { print(error?.localizedDescription ?? ""); return }
            guard let user = user, let fcmToken = Messaging.messaging().fcmToken else { return }
            GlobalState.instance.firebaseId = user.uid
            GlobalState.instance.email = user.email
            GlobalState.instance.password = cryptoPassword
            PumkitAPI.FIREBASE.child(FIREBASE_KEY.users.rawValue).child(user.uid).updateChildValues(["token": fcmToken], withCompletionBlock: { (error, reference) in
                if error != nil { print(error?.localizedDescription ?? ""); return }
                PumkitAPI.FIREBASE.child(FIREBASE_KEY.users.rawValue).child(user.uid).observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
                    guard let data = snapshot.value else { return }
                    let json = JSON(data)
                    GlobalState.instance.name = json["username"].stringValue
                    GlobalState.instance.uid = json["my_id"].intValue
                    handler()
                })
            })
        }
    }
    
    func join(email: String, password: String, name: String, age: Int, phone: String, gender: String, handler: @escaping () -> Void) {
        // 비밀번호 암호화 적용 (SHA512)
        let bytes: Array<UInt8> = password.bytes // Array("password".utf8)
        let cryptoPassword = bytes.sha512().toHexString()
        
        let parameters: Parameters = [
            "opt": OPT.join.rawValue,
            "email": email,
            "password": cryptoPassword,
            "user_name": name,
            "phone": phone,
            "age": age,
            "gender": gender
        ]
        
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            // Firebase Auth 계정 생성
            switch dataResponse.result {
            case .success(let data):
                let result = data["result"].intValue
                guard result == 0 else { print("가입을 실패했습니다."); return }
                Auth.auth().createUser(withEmail: email, password: cryptoPassword, completion: { (user, error) in
                    guard let user = user, let fcmToken = Messaging.messaging().fcmToken, error == nil else { return }
                    let values: [AnyHashable: Any] = ["username" : name, "my_id" : data["my_id"].stringValue, "token": fcmToken]   // img_url은 나중에 사진 등록 후 추가
                    let reference = PumkitAPI.FIREBASE.child(FIREBASE_KEY.users.rawValue).child(user.uid)
                    reference.updateChildValues(values, withCompletionBlock: { (error2, reference) in
                        guard error2 == nil else { print(error2!.localizedDescription); return }
                        // 회원가입 완료, 로그인 처리
                        return handler()
                    })
                })
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchContacts(phones: String) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.fetchContacts.rawValue,
            "phones": phones,
            "my_id": uid
        ]
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            switch dataResponse.result {
            case .success(_): print("Fetching Contacts Completed")
            case .failure(let error): print(error.localizedDescription)
            }
        }
    }
    
    func account(handler: @escaping (DataResponse<Model.User>) -> Void) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.account.rawValue,
            "user_id": uid
        ]
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result: DataResponse<Model.User> = dataResponse.map({ (json: JSON) -> Model.User in
                return Model.User(json: json)
            })
            handler(result)
        }
    }
    
    func getDatedList(handler: @escaping DatedListResponseHandler) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.datedList.rawValue,
            "my_id": uid
        ]
        print("getDatedList parameters : ", parameters)
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            handler(dataResponse.map { Model.DatedList(json: $0)})
        }
    }
    
    func getMatchmakerList(handler: @escaping MatchmakerListResponseHandler) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.myMatchlist.rawValue,
            "my_id": uid
        ]
        
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result: DataResponse<Model.MatchmakerList> = dataResponse.map({ (json: JSON) -> Model.MatchmakerList in
                return Model.MatchmakerList.init(json: json)
            })
            handler(result)
        }
    }
    
    func pickMatchmaker(matchmaker: Model.User, handler: @escaping BlindListResponseHandler) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.pickMatch.rawValue,
            "my_id": uid,
            "match_id": matchmaker.sid
        ]
        
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result: DataResponse<Model.BlindList> = dataResponse.map({ (json: JSON) -> Model.BlindList in
                return Model.BlindList.init(json: json)
            })
            handler(result)
        }
    }
    
    func pickBlind(matchmaker: Model.User, blind: Model.User, handler: @escaping DateResponseHandler) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.pickBlind.rawValue,
            "my_id": uid,
            "match_id": matchmaker.sid,
            "blind_id": blind.sid
        ]
        
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result: DataResponse<Model.ChinchinDate> = dataResponse.map({ (json: JSON) -> Model.ChinchinDate in
                return Model.ChinchinDate.init(json: json)
            })
            handler(result)
        }
    }
    
    func openBlind(handler: @escaping OpenDateResponseHandler) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.publicDate.rawValue,
            "my_id": uid
        ]
        
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result: DataResponse<Model.OpenDateList> = dataResponse.map({ (json: JSON) -> Model.OpenDateList in
                return Model.OpenDateList(json: json)
            })
            handler(result)
        }
    }
    
    func poke(matchmaker: Int, poke: Int, handler: @escaping (DataResponse<JSON>) -> Void) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.poke.rawValue,
            "my_id": uid,
            "match_id": matchmaker,
            "poke_id": poke
        ]
        
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            return handler(dataResponse)
        }
    }
    
    func getMyInfo(handler: @escaping MyInfoResponseHandler) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.myPage.rawValue,
            "my_id": uid
        ]
        
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result: DataResponse<Model.MyInfo> = dataResponse.map({ (json: JSON) -> Model.MyInfo in
                return Model.MyInfo(json: json)
            })
            handler(result)
        }
    }
    
    func modifyDateStatus(yn: String, handler: @escaping (DataResponse<JSON>) -> Void) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.modifyDateStatus.rawValue,
            "my_id": uid,
            "yn": yn
        ]
        
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            return handler(dataResponse)
        }
    }
    
    func modifyOpenDateStatus(yn: String, handler: @escaping (DataResponse<JSON>) -> Void) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.modifyOpenDateStatus.rawValue,
            "my_id": uid,
            "yn": yn
        ]
        
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            return handler(dataResponse)
        }
    }
    
    func getMyProfile(handler: @escaping (DataResponse<Model.Profile>) -> Void) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.profile.rawValue,
            "my_id": uid,
            "match_id": "",
            "user_id": uid
        ]
        
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result: DataResponse<Model.Profile> = dataResponse.map({ (json: JSON) -> Model.Profile in
                return Model.Profile(json: json)
            })
            handler(result)
        }
    }
    
    func getMyPicture(handler: @escaping ((DataResponse<[Model.Picture]>) -> Void)) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.myPictures.rawValue,
            "my_id": uid
        ]
        
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result: DataResponse<[Model.Picture]> = dataResponse.map({ (json: JSON) -> [Model.Picture] in
                return json["pics"].arrayValue.map({ (json: JSON) -> Model.Picture in
                    return Model.Picture(json: json)
                })
            })
            handler(result)
        }
    }
    
    func uploadPicture(isMain: Int, handler: @escaping (DataResponse<JSON>) -> Void) {
        // 사진 업로드
    }
    
    func deletePicture(picture: Int, handler: @escaping (DataResponse<JSON>) -> Void) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.delPicture.rawValue,
            "my_id": uid,
            "profile_id": picture
        ]
        
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            return handler(dataResponse)
        }
    }
    
    func setMainProfilePicture(picture: Int, handler: @escaping (DataResponse<JSON>) -> Void) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.updateMainPicture.rawValue,
            "my_id": uid,
            "profile_id": picture
        ]
        
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            return handler(dataResponse)
        }
    }
    
    func getMyHash(handler: @escaping (DataResponse<([Model.Hash], [Model.Hash])>) -> Void) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.myHash.rawValue,
            "my_id": uid
        ]
        
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result: DataResponse<([Model.Hash], [Model.Hash])> = dataResponse.map({ (json: JSON) -> ([Model.Hash], [Model.Hash]) in
                return (json["my_hash"].arrayValue.map({ (innerJson: JSON) -> Model.Hash in
                    return Model.Hash(json: innerJson)
                }), json["famous_hash"].arrayValue.map({ (innerJson: JSON) -> Model.Hash in
                    return Model.Hash(json: innerJson)
                }))
            })
            handler(result)
        }
    }
    
    func getHash(hashId: Int, handler: @escaping (DataResponse<JSON>) -> Void) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.getHash.rawValue,
            "my_id": uid,
            "hash_id": hashId
        ]
        
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            return handler(dataResponse)
        }
    }
    
    func delHash(hashId: Int, handler: @escaping (DataResponse<JSON>) -> Void) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.delHash.rawValue,
            "my_id": uid,
            "hash_id": hashId
        ]
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            return handler(dataResponse)
        }
    }
    
    func addHash(hashName: String, handler: @escaping (DataResponse<JSON>) -> Void) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.addHash.rawValue,
            "my_id": uid,
            "hash_name": hashName
        ]
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            return handler(dataResponse)
        }
    }
    
    func modHash(hashId: Int, open: Int, handler: @escaping (DataResponse<JSON>) -> Void) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.modHash.rawValue,
            "my_id": uid,
            "hash_id": hashId,
            "open": open
        ]
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            return handler(dataResponse)
        }
    }
    
    func getFriendsList(handler: @escaping (DataResponse<[Model.User]>) -> Void) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt": OPT.friendsList.rawValue,
            "my_id": uid
        ]
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result: DataResponse<[Model.User]> = dataResponse.map({ (json: JSON) -> [Model.User] in
                return json["friends"].arrayValue.map({ (innerJson: JSON) -> Model.User in
                    return Model.User(json: innerJson)
                })
            })
            handler(result)
        }
    }
    
    func chooseFriend(friend: Int, handler: @escaping (DataResponse<JSON>) -> Void) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameter: Parameters = [
            "opt" : OPT.chooseFriend.rawValue,
            "my_id" : uid,
            "date1" : friend
        ]
        
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameter)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            return handler(dataResponse)
        }
    }
    
    func uploadRecommend(recommend: String, handler: @escaping (DataResponse<JSON>) -> Void) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameter: Parameters = [
            "opt" : OPT.uploadRecommend.rawValue,
            "my_id" : uid,
            "text" : recommend
        ]
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameter)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            return handler(dataResponse)
        }
    }
    
    func manageBlind(handler: @escaping (DataResponse<Model.ManageBlind>) -> Void) {
        guard let uid = GlobalState.instance.uid else { return }
        let parameters: Parameters = [
            "opt" : OPT.manageBlind.rawValue,
            "my_id" : uid
        ]
        
        PumkitRouter.manager.request(PumkitRouter.request(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            let result: DataResponse<Model.ManageBlind> = dataResponse.map({ (json: JSON) -> Model.ManageBlind in
                return Model.ManageBlind(json: json)
            })
            handler(result)
        }
    }
    
    func pushNotification(message: String, fcmToken: String, handler: @escaping () -> Void) {
        guard let fromName = GlobalState.instance.name else { return }
        let parameters: Parameters = [
            "token": fcmToken,
            "message": message,
            "from_user_name": fromName
        ]
        
        PumkitRouter.manager.request(PumkitRouter.push(parameters: parameters)).responseSwiftyJSON { (dataResponse: DataResponse<JSON>) in
            print(dataResponse.map({ (json: JSON) -> String in return json.stringValue }))
            handler()
        }
    }
    
}

extension PumkitAPI {
    func getUserInfo(firebaseId: String, handler: @escaping (Chat.User) -> Void) {
        let userReference = Database.database().reference().child(FIREBASE_KEY.users.rawValue)
        userReference.child(firebaseId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value { handler(Chat.User(json: JSON(data))) }
        })
    }
}



enum PumkitRouter {
    case push(parameters: Parameters)
    case request(parameters: Parameters)
}

extension PumkitRouter: URLRequestConvertible {
    
    static let serverUrlString: String = "http://pumkit.com/"
    static let apiUrlString: String = "http://pumkit.com/json/"
    static let pushUrlString: String = "http://pumkit.com/fcm/push_chat.php"
    
    
    static let manager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        let manager = Alamofire.SessionManager(configuration: configuration)
        return manager
    }()
    
    func asURLRequest() throws -> URLRequest {
        let url = try PumkitRouter.apiUrlString.asURL()
        let pushUrl = try PumkitRouter.pushUrlString.asURL()
        var urlRequest = URLRequest(url: url)
        var pushRequest = URLRequest(url: pushUrl)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        pushRequest.httpMethod = HTTPMethod.post.rawValue
        
        switch self {
        case let .push(parameter):
            return try URLEncoding.default.encode(pushRequest, with: parameter)
        case let .request(parameters):
            return try URLEncoding.default.encode(urlRequest, with: parameters)
        }
//
//        Alamofire.upload(multipartFormData: { (form) in
//            form.append(data, withName: "uploadedfile", fileName: "fileUpload.jpg", mimeType: "image/png")
//        }, to: PumkitRouter., encodingCompletion: { result in
//            switch result {
//            case .success(let upload, _, _):
//                upload.responseString { response in
//                    print(response.value ?? "")
//                }
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        })
//
    }
}

