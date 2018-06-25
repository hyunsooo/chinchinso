//
//  MyProfileController.swift
//  chinchinso
//
//  Created by hyunsu han on 2018. 1. 7..
//  Copyright © 2018년 hyunsu han. All rights reserved.
//

import UIKit

class MyProfileController: UIViewController {
    var profile: Model.Profile? {
        didSet {
            guard let profile = profile else { return }
            self.nameLabel.attributedText = NSMutableAttributedString(string: profile.profile.name, attributes: [.kern: 10])
            if profile.profile.profileUrlList.count > 0 { datasource = profile.profile.profileUrlList }
            else { guard let url = profile.profile.profileUrl else { datasource = []; return }
                datasource = [url]
            }
            for i in 0..<profile.profile.hashlist.count {
                if i == 0 { hashLabel1.text = "# \(profile.profile.hashlist[i].hash_name)" }
                else if i == 1 { hashLabel2.text = "# \(profile.profile.hashlist[i].hash_name)" }
                else if i == 2 { hashLabel3.text = "# \(profile.profile.hashlist[i].hash_name)" }
                else { break }
            }
        }
    }
    let cellName: String = "BlindCell"
    var datasource = [URL]() {
        didSet {
            collectionView.reloadData()
            if datasource.count > 0 { pageControl.numberOfPages = datasource.count }
        }
    }
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = Color.shared.background
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = .lightGray
        pc.currentPageIndicatorTintColor = Color.shared.orangeYellow
        pc.hidesForSinglePage = true
        pc.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        return pc
    }()
    
    let justLabel: UILabel = {
        let lb = UILabel()
        lb.text = "나의 프로필"
        lb.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return lb
    }()
    
    let nameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "내 이름"
        lb.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return lb
    }()
    
    let hashLabel1: UILabel = {
        let lb = UILabel()
        lb.text = "# 첫번째 해쉬"
        lb.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lb.textAlignment = .left
        return lb
    }()
    
    let hashLabel2: UILabel = {
        let lb = UILabel()
        lb.text = "# 두번째 해쉬"
        lb.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lb.textAlignment = .left
        return lb
    }()
    
    let hashLabel3: UILabel = {
        let lb = UILabel()
        lb.text = "# 세번째 해쉬"
        lb.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lb.textAlignment = .left
        return lb
    }()
    
    lazy var hashButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 20
        btn.layer.masksToBounds = true
        btn.setTitle("해쉬 관리", for: .normal)
        btn.setTitleColor(Color.shared.font, for: .normal)
        btn.layer.borderColor = Color.shared.orangeYellow.cgColor
        btn.layer.borderWidth = 1
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(handleHash), for: .touchUpInside)
        return btn
    }()
    
    lazy var pictureButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 20
        btn.layer.masksToBounds = true
        btn.setTitle("사진 관리", for: .normal)
        btn.setTitleColor(Color.shared.font, for: .normal)
        btn.layer.borderColor = Color.shared.orangeYellow.cgColor
        btn.layer.borderWidth = 1
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(handlePicture), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.shared.background
        initNavigationBar()
        initBlindView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initNavigationBar() {
        title = "내 프로필"
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = Color.shared.background
        self.navigationController?.navigationBar.tintColor = .darkGray
        self.navigationController?.navigationBar.clipsToBounds = true               // bottom line hide
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-back").fillColor(.darkGray), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
        
    }

}

extension MyProfileController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    fileprivate func initBlindView() {
        view.backgroundColor = Color.shared.background
       
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(justLabel)
        view.addSubview(nameLabel)
        view.addSubview(hashLabel1)
        view.addSubview(hashLabel2)
        view.addSubview(hashLabel3)
        view.addSubview(hashButton)
        view.addSubview(pictureButton)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BlindCell.self, forCellWithReuseIdentifier: cellName)
        
        collectionView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: view.frame.width * 0.95)
        pictureButton.anchor(nil, left: nil, bottom: collectionView.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 20, widthConstant: 90, heightConstant: 40)
        pageControl.anchor(nil, left: view.leftAnchor, bottom: collectionView.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        justLabel.anchor(collectionView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 20)
        nameLabel.anchor(justLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 5, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 30)
        
        
        
        hashLabel1.anchor(nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 130, rightConstant: 0, widthConstant: 150, heightConstant: 30)
        hashLabel2.anchor(hashLabel1.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 30)
        hashLabel3.anchor(hashLabel2.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 30)
        hashButton.anchor(nil, left: nil, bottom: hashLabel3.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 90, heightConstant: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as? BlindCell else { return BlindCell() }
        cell.update(data: datasource[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset.pointee.x / collectionView.frame.width)
        pageControl.currentPage = pageNumber
    }
}

extension MyProfileController {
    @objc fileprivate func back() { self.navigationController?.popViewController(animated: true) }
    
    @objc fileprivate func handlePicture() {
        guard GlobalState.instance.uid != -1 else { return }    // logout
        let myPictureController = MyPictureController()
        self.navigationController?.pushViewController(myPictureController, animated: true)
    }
    
    @objc fileprivate func handleHash() {
        guard GlobalState.instance.uid != -1 else { return }    // logout
        let myHashController = MyHashController()
        self.navigationController?.pushViewController(myHashController, animated: true)
    }
}

