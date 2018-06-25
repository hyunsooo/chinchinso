//
//  ChatListController.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 12. 9..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import LBTAComponents
import Firebase
import SwiftyJSON

class ChatListController: UIViewController {

    var datasource = [Chat.Message]() {
        didSet { self.collectionView.reloadData() }
    }
    var messages = [String : Chat.Message]()
    
    var homeController: HomeController?
    let cellName = "ChatCell"
    let database = Database.database().reference()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = Color.shared.background
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        view.backgroundColor = Color.shared.background
        view.addSubview(collectionView)
        collectionView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: cellName)
       
        loadList()
    }

    fileprivate func initNavigationBar() {
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = Color.shared.background
        self.navigationController?.navigationBar.tintColor = .darkGray
        self.navigationController?.navigationBar.clipsToBounds = true       // bottom line hide
        
        self.title = "채팅 리스트"
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-back").fillColor(.darkGray), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ChatListController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as? ChatCell else { return ChatCell() }
        cell.update(data: datasource[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let message = datasource[indexPath.row]
        getUserInfo(firebaseId: message.getBlindId()) { (blind) in
            self.chat(title: blind.name, blind: message.getBlindId(), matchmaker: message.matchId)
        }
    }
}

extension ChatListController {
    
    fileprivate func loadList() {
        guard let firebaseId = GlobalState.instance.firebaseId else { print("no firebase id");return }
        print("FIREBASE : ", firebaseId)
        let reference = Database.database().reference().child(FIREBASE_KEY.chatting.rawValue).child(firebaseId)
        reference.observe(.childAdded, with: { (snapshot) in
            let matchId = snapshot.key
            print("FIREBASE MATCH ID: ", matchId)
            reference.child(matchId).observe(.childAdded, with: { (snapshot) in
                let blinderId = snapshot.key
                print("FIREBASE BLINDER ID: ", blinderId)
               reference.child(matchId).child(blinderId).queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
                    let messageId = snapshot.key
                    let messageReference = Database.database().reference().child(FIREBASE_KEY.messages.rawValue).child(messageId)
                    messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
                        guard let data = snapshot.value else { return }
                        let message = Chat.Message(json: JSON(data))
                        self.messages[message.getBlindId()] = message
                        self.datasource = Array(self.messages.values)
                    })
                })
            })
        })
    }
    
    fileprivate func getUserInfo(firebaseId: String, handler: @escaping (Chat.User) -> Void) {
        let userReference = Database.database().reference().child(FIREBASE_KEY.users.rawValue)
        userReference.child(firebaseId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value { handler(Chat.User(json: JSON(data))) }
        })
    }
    
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func chat(title: String, blind: String, matchmaker: String) {
        let chattingController = ChattingController()
        chattingController.blindId = blind
        chattingController.matchmakerId = matchmaker
        chattingController.title = title
        self.navigationController?.pushViewController(chattingController, animated: true)
    }
}
