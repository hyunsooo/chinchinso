//
//  ChatCell.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 12. 10..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

class ChatCell: UICollectionViewCell {
    let blindImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 30
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let matchMakerImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 15
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let messageBox: UIView = {
        let v = UIView()
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 5
        v.backgroundColor = Color.shared.chatBackground
        return v
    }()
    
    let messageLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lb.lineBreakMode = .byWordWrapping
        lb.numberOfLines = 2
        return lb
    }()
    
    let blindName: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        return lb
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        addSubview(blindImageView)
        addSubview(matchMakerImageView)
        addSubview(blindName)
        addSubview(messageBox)
        messageBox.addSubview(messageLabel)
        
        blindImageView.anchor(nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 60)
        blindImageView.anchorCenterYToSuperview(constant: -10)
        matchMakerImageView.anchor(nil, left: blindImageView.rightAnchor, bottom: blindImageView.bottomAnchor, right: nil, topConstant: 0, leftConstant: -15, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        blindName.anchor(blindImageView.bottomAnchor, left: blindImageView.leftAnchor, bottom: nil, right: nil, topConstant: 6, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 75, heightConstant: 20)
        messageBox.anchor(nil, left: matchMakerImageView.rightAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 70)
        messageBox.anchorCenterYToSuperview()
        
        messageLabel.anchor(nil, left: messageBox.leftAnchor, bottom: nil, right: messageBox.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 60)
        messageLabel.anchorCenterYToSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChatCell: CellProtocol {
    typealias Item = Chat.Message
    func update(data message: Chat.Message) {
        print("UPDATE FIREBASE BLIND: ", message.getBlindId())
        App.api.getUserInfo(firebaseId: message.getBlindId()) { (user) in
            print("UPDATE FIREBASE BLIND SUCCESS")
            self.blindName.text = user.name
            if let url = user.profileUrl { self.blindImageView.af_setImage(withURL: url) }
        }
        print("UPDATE FIREBASE MATCH : ", message.matchId)
        App.api.getUserInfo(firebaseId: message.matchId) { (user) in
            print("UPDATE FIREBASE BLIND MATCH")
            if let url = user.profileUrl { self.matchMakerImageView.af_setImage(withURL: url) }
        }
        self.messageLabel.text = message.message == "" && message.image_url.count > 0 ? "사진" : message.message
       
    }
    
//    func setLastMessage(messageId: String) {
//        let messageReference = Database.database().reference().child(FIREBASE_KEY.messages.rawValue).child(messageId)
//        messageReference.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
//            guard let `self` = self else { return }
//            if let data = snapshot.value {
//                let message = Chat.Message(json: JSON(data))
//                self.message.text = message.message == "" && message.image_url.count > 0 ? "사진" : message.message
//            }
//        })
//    }
    
//    private func getUserInfo(firebaseId: String, handler: @escaping (Chat.User) -> Void) {
//        let userReference = Database.database().reference().child(FIREBASE_KEY.users.rawValue)
//        userReference.child(firebaseId).observeSingleEvent(of: .value, with: { (snapshot) in
//            if let data = snapshot.value { handler(Chat.User(json: JSON(data))) }
//        })
//    }
}
