//
//  FriendManageController.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 11. 27..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import LBTAComponents

protocol ManageBlindControllerDelegate: class {
    func refresh()
}

class ManageBlindController: BaseViewController {

    var manage: Model.ManageBlind? {
        didSet {
            guard let manage = manage else { return }
            print(manage)
            if let url = manage.user.profileUrl { myImageView.af_setImage(withURL: url) }
            if let url = manage.friend.profileUrl { friendImageView.af_setImage(withURL: url); view.bringSubview(toFront: friendImageView) }
            else { view.bringSubview(toFront: choiceFriendButton) }
            view.bringSubview(toFront: myImageView)
            
            friendNameLabel.attributedText = NSMutableAttributedString(string: manage.friend.name, attributes: [.kern: 3])
            recommendMessageView.text = manage.friend.recommend
            
            dataSource = manage.pokes
        }
    }
    let cellName = "PokeCell"
    var dataSource = [Model.Poke]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    let label1: UILabel = {
        let lb = UILabel()
        lb.text = "# 친구 소개팅 관리"
        lb.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lb.textAlignment = .left
        return lb
    }()
    
    let myImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 25
        iv.layer.masksToBounds = true
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var friendImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "profile"))
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 75
        iv.layer.masksToBounds = true
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(choiceFriend)))
        return iv
    }()
    
    let friendNameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lb.textAlignment = .center
        return lb
    }()
    
    let label2: UILabel = {
        let lb = UILabel()
        lb.text = "# 나를 콕 찌른 친구들"
        lb.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lb.textAlignment = .left
        return lb
    }()
    
    let recommendMessageView: UITextView = {
        let tv = UITextView()
        tv.layer.cornerRadius = 5
        tv.layer.masksToBounds = true
        tv.layer.borderWidth = 3
        tv.layer.borderColor = Color.shared.darkGreen.cgColor
        tv.backgroundColor = .white
        tv.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        tv.contentInset = UIEdgeInsetsMake(10, 10, 10, 10)
        tv.allowsEditingTextAttributes = false
        tv.isEditable = false
        return tv
    }()
    
    lazy var recommendEditButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .white
        btn.layer.borderColor = Color.shared.font.cgColor
        btn.setTitleColor(Color.shared.font, for: .normal)
        btn.setTitle("편집", for: .normal)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 15
        btn.addTarget(self, action: #selector(editRecommendMessage), for: .touchUpInside)
        return btn
    }()
    
    lazy var choiceFriendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .white
        btn.layer.borderColor = Color.shared.font.cgColor
        btn.setTitleColor(Color.shared.font, for: .normal)
        btn.setTitle("친구 선택", for: .normal)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 75
        btn.addTarget(self, action: #selector(choiceFriend), for: .touchUpInside)
        return btn
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = Color.shared.darkGreen
        cv.contentInset = UIEdgeInsetsMake(10, 0, 10, 0)
        cv.layer.cornerRadius = 5
        cv.layer.masksToBounds = true
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        App.api.manageBlind { [weak self] (dataResponse: DataResponse<Model.ManageBlind>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(let data): self.manage = data
            case .failure(let error): print(error)
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initView() {
        view.addSubview(label1)
        view.addSubview(myImageView)
        view.addSubview(friendNameLabel)
        view.addSubview(friendImageView)
        view.addSubview(choiceFriendButton)
        view.addSubview(recommendMessageView)
        view.addSubview(recommendEditButton)
        view.addSubview(label2)
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PokeCell.self, forCellWithReuseIdentifier: cellName)
        
        label1.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 20)
        friendImageView.anchor(label1.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 150)
        friendImageView.anchorCenterXToSuperview()
        choiceFriendButton.anchor(label1.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 150)
        choiceFriendButton.anchorCenterXToSuperview()
        friendNameLabel.anchor(friendImageView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 20)
        friendNameLabel.anchorCenterXToSuperview()
        myImageView.anchor(nil, left: nil, bottom: friendImageView.bottomAnchor, right: friendImageView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: -8, widthConstant: 50, heightConstant: 50)
        
        recommendMessageView.anchor(friendNameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 25, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 150)
        recommendEditButton.anchor(nil, left: nil, bottom: recommendMessageView.topAnchor, right: recommendMessageView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 5, rightConstant: 0, widthConstant: 80, heightConstant: 30)
        
        label2.anchor(recommendMessageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 30, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 20)
        collectionView.anchor(label2.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 150)
    }

}

extension ManageBlindController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as? PokeCell else { return PokeCell() }
        cell.update(data: dataSource[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}

extension ManageBlindController: ManageBlindControllerDelegate {
    func refresh() {
        App.api.manageBlind { [weak self] (dataResponse: DataResponse<Model.ManageBlind>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(let data): self.manage = data
            case .failure(let error): print(error)
            }
        }
    }
}

extension ManageBlindController {
    
    @objc fileprivate func choiceFriend() {
        guard GlobalState.instance.uid != -1 else { return }
        let friendsController = FriendsController()
        friendsController.manageBlindControllerDelegate = self
        self.navigationController?.pushViewController(friendsController, animated: true)
    }
    
    @objc fileprivate func editRecommendMessage() {
        let recommendController = RecommendController()
        recommendController.textView.text = recommendMessageView.text
        recommendController.manageBlindControllerDelegate = self
        self.navigationController?.pushViewController(recommendController, animated: true)
//        if recommendMessageView.isEditable {
//            // 저장 액션
//            print("\(recommendMessageView.text)")
//        }
//        recommendMessageView.isEditable = !recommendMessageView.isEditable
//        recommendEditButton.setTitle(recommendMessageView.isEditable ? "저장" : "편집", for: .normal)
        
    }
}
