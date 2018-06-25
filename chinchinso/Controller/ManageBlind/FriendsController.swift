//
//  FriendsController.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 12. 15..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FriendsController: UIViewController {

    var manageBlindControllerDelegate: ManageBlindControllerDelegate?
    var dataSource = [Model.User]() {
        didSet { collectionView.reloadData() }
    }
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = Color.shared.background
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(FriendCell.self, forCellWithReuseIdentifier: cellId)
        return cv
    }()
    
    let cellId = "FriendCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initViews()
        App.api.getFriendsList { [weak self] (dataResponse: DataResponse<[Model.User]>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(let data):
                self.dataSource = data
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initNavigationBar() {
        title = "소개할 친구 고르기"
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = Color.shared.background
        self.navigationController?.navigationBar.tintColor = .darkGray
        self.navigationController?.navigationBar.clipsToBounds = true               // bottom line hide
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-back").fillColor(.darkGray), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
    }

    fileprivate func initViews() {
        view.backgroundColor = Color.shared.background
        view.addSubview(collectionView)
        collectionView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
}

extension FriendsController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? FriendCell else { return FriendCell() }
        cell.update(data: dataSource[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate = self.manageBlindControllerDelegate else { print("delegate is nil"); return }
        let friend = dataSource[indexPath.row]
        App.api.chooseFriend(friend: friend.sid) { [weak self] (dataResponse: DataResponse<JSON>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(_):
                delegate.refresh()
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension FriendsController {
    @objc fileprivate func back() { self.navigationController?.popViewController(animated: true) }
}
