//
//  MyHashController.swift
//  chinchinso
//
//  Created by hyunsu han on 2018. 1. 8..
//  Copyright © 2018년 hyunsu han. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol MyHashControllerDelegate: class {
    func refresh()
}

class MyHashController: UIViewController {

    var cellId = "hashCell"
    var cellId2 = "getHashCell"
    
    lazy var mainHashTableView: UITableView = {
        let tv = UITableView()
        tv.tag = 0
        tv.delegate = self
        tv.dataSource = self
        tv.register(HashCell.self, forCellReuseIdentifier: cellId)
        tv.bounces = false
        return tv
    }()
    
    var mh_dataSource = [Model.Hash]() {    // 사용 프로필해쉬
        didSet {
            mainHashTableView.reloadData()
        }
    }
    
    lazy var hashTableView: UITableView = {
        let tv = UITableView()
        tv.tag = 1
        tv.delegate = self
        tv.dataSource = self
        tv.register(HashCell.self, forCellReuseIdentifier: cellId)
        tv.bounces = false
        tv.allowsMultipleSelectionDuringEditing = false
        return tv
    }()
    
    var dataSource = [Model.Hash]() {   // 보유 프로필해쉬
        didSet {
//            hashTableView.reloadData()
        }
    }
    
    var famous_dataSource = [Model.Hash]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(GetHashCell.self, forCellWithReuseIdentifier: cellId2)
        cv.contentInset = UIEdgeInsetsMake(10, 15, 10, 15)
        cv.backgroundColor = .white
        cv.layer.masksToBounds = true
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "해쉬 직접 입력하기"
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        view.backgroundColor = Color.shared.background
        App.api.getMyHash { (dataResponse: DataResponse<([Model.Hash], [Model.Hash])>) in
            switch dataResponse.result {
            case .success(let data):
                data.0.forEach({ [weak self] (hash: Model.Hash) in
                    guard let `self` = self else { return }
                    if hash.open == 1 {  self.mh_dataSource.append(hash) } // 사용할 프로필 해쉬
                    else { self.dataSource.append(hash) } // 보유 프로필 해쉬
                })
                
                data.1.forEach({ [weak self] (hash: Model.Hash) in
                    guard let `self` = self else { return }
                    self.famous_dataSource.append(hash)
                })
                self.hashTableView.reloadData()
                GlobalState.instance.hashCount = self.mh_dataSource.count   // 갱신
            case .failure(let err):
                print(err)
            }
        }
        
        view.addSubview(mainHashTableView)
        view.addSubview(hashTableView)
        let header = UIView()
        header.backgroundColor = .lightGray
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "남들은 어떤 해쉬를 보유하고 있을까요?"
        header.addSubview(label)
        label.anchor(header.topAnchor, left: header.leftAnchor, bottom: nil, right: header.rightAnchor, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 30)
        
        view.addSubview(header)
        view.addSubview(collectionView)
        mainHashTableView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 180)
        hashTableView.anchor(mainHashTableView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 205)
        header.anchor(hashTableView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 30)
        collectionView.anchor(header.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func initNavigationBar() {
        title = "소개팅 해쉬 관리"
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = Color.shared.background
        self.navigationController?.navigationBar.tintColor = .darkGray
        self.navigationController?.navigationBar.clipsToBounds = true               // bottom line hide
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-back").fillColor(.darkGray), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
    }
    
}

extension MyHashController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 { return mh_dataSource.count }
        else { return dataSource.count }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? HashCell else { return HashCell() }
        if tableView.tag == 0 { cell.update(data: mh_dataSource[indexPath.row]) }
        else { cell.update(data: dataSource[indexPath.row]) }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    fileprivate func initPlusHashView(_ header: UIView, _ label: UILabel) {
        let view = UIView()
        view.backgroundColor = .white
        header.addSubview(view)
        view.anchor(label.bottomAnchor, left: header.leftAnchor, bottom: nil, right: header.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        let roundView = UIView()
        roundView.layer.borderColor = UIColor.lightGray.cgColor
        roundView.layer.borderWidth = 1
        roundView.layer.masksToBounds = true
        roundView.layer.cornerRadius = 5
        
        let plusButton = UIImageView(image: #imageLiteral(resourceName: "plus"))
        plusButton.contentMode = .scaleAspectFill
        plusButton.isUserInteractionEnabled = true
        plusButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addHash)))
        view.addSubview(roundView)
        roundView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 5, leftConstant: 15, bottomConstant: 5, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        roundView.addSubview(textField)
        roundView.addSubview(plusButton)
        
        textField.anchor(roundView.topAnchor, left: roundView.leftAnchor, bottom: roundView.bottomAnchor, right: plusButton.leftAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 5, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        plusButton.anchor(nil, left: nil, bottom: nil, right: roundView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 25, heightConstant: 25)
        plusButton.anchorCenterYToSuperview()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .lightGray
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = tableView.tag == 0 ? "사용할 프로필해쉬" : "보유 프로필해쉬"
        header.addSubview(label)
        label.anchor(header.topAnchor, left: header.leftAnchor, bottom: nil, right: header.rightAnchor, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 30)
        if (tableView.tag == 1) { initPlusHashView(header, label) }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.tag == 0 ? 30 : 80
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.tag == 1
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "해쉬 삭제"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let cell = tableView.cellForRow(at: indexPath) as? HashCell else { return }
            App.api.delHash(hashId: cell.hashId, handler: { [weak self] (dataResponse: DataResponse<JSON>) in
                guard let `self` = self else { return }
                self.dataSource.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            })
        }
    }
}

extension MyHashController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return famous_dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId2, for: indexPath) as? GetHashCell else { return GetHashCell() }
        cell.delegate = self
        cell.update(data: famous_dataSource[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width - 40) / 2 , height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension MyHashController {
    @objc fileprivate func back() { self.navigationController?.popViewController(animated: true) }
    @objc fileprivate func addHash() {
        guard let hash = textField.text else { return }
        App.api.addHash(hashName: hash) { [weak self] (dataResponse: DataResponse<JSON>) in
            guard let `self` = self else { return }
            self.refresh()
        }
    }
}

extension MyHashController: MyHashControllerDelegate {
    func refresh() {
        App.api.getMyHash { (dataResponse: DataResponse<([Model.Hash], [Model.Hash])>) in
            switch dataResponse.result {
            case .success(let data):
                self.mh_dataSource.removeAll()
                self.dataSource.removeAll()
                self.famous_dataSource.removeAll()
                
                data.0.forEach({ [weak self] (hash: Model.Hash) in
                    guard let `self` = self else { return }
                    if hash.open == 1 {  self.mh_dataSource.append(hash) } // 사용할 프로필 해쉬
                    else { self.dataSource.append(hash) } // 보유 프로필 해쉬
                })
                
                data.1.forEach({ [weak self] (hash: Model.Hash) in
                    guard let `self` = self else { return }
                    self.famous_dataSource.append(hash)
                    print(hash.hash_name)
                })
                
                self.hashTableView.reloadData()
                GlobalState.instance.hashCount = self.mh_dataSource.count   // 갱신
            case .failure(let err):
                print(err)
            }
        }
    }
}
