//
//  PokeController.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 12. 8..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class PokeController: UIViewController {

    var openDate: Model.OpenDate? {
        didSet {
            guard let openDate = openDate else { return }
            self.title = openDate.blind.user.name
            self.matchmakerNameLabel.text = "\(openDate.matchmaker.name)님의 친구"
            self.matchmakerMessageView.text = openDate.blind.recommend
            
            self.blindNameLabel.attributedText = NSMutableAttributedString(string: openDate.blind.user.name, attributes: [.kern: 10])
            
            if openDate.blind.user.profileUrlList.count > 0 { datasource = openDate.blind.user.profileUrlList }
            else {
                guard let url = openDate.blind.user.profileUrl else { datasource = []; return }
                datasource = [url]
            }
            
            for i in 0..<openDate.blind.user.hashlist.count {
                if i == 0 { hashLabel1.text = "# \(openDate.blind.user.hashlist[i].hash_name)" }
                else if i == 1 { hashLabel2.text = "# \(openDate.blind.user.hashlist[i].hash_name)" }
                else if i == 2 { hashLabel3.text = "# \(openDate.blind.user.hashlist[i].hash_name)" }
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
    
    let matchmakerNameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "주선자"
        lb.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return lb
    }()
    
    let blindNameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "상대방"
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
    
    lazy var pokeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 20
        btn.layer.masksToBounds = true
        btn.setTitle("콕 찌르기", for: .normal)
        btn.setTitleColor(Color.shared.font, for: .normal)
        btn.layer.borderColor = Color.shared.orangeYellow.cgColor
        btn.layer.borderWidth = 1
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(handlePoke), for: .touchUpInside)
        return btn
    }()
    
    let matchmakerMessageView: UITextView = {
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
        tv.alpha = 0
        return tv
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
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = Color.shared.background
        self.navigationController?.navigationBar.tintColor = .darkGray
        self.navigationController?.navigationBar.clipsToBounds = true               // bottom line hide
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-back").fillColor(.darkGray), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
        
        let matchmakerButton = UIButton(type: .system)
        matchmakerButton.backgroundColor = .white
        matchmakerButton.layer.borderColor = Color.shared.font.cgColor
        matchmakerButton.setTitleColor(Color.shared.font, for: .normal)
        matchmakerButton.setTitle("친구의 추천", for: .normal)
        matchmakerButton.layer.masksToBounds = true
        matchmakerButton.layer.cornerRadius = 15
        matchmakerButton.addTarget(self, action: #selector(toggleMatchmakerMessage), for: .touchUpInside)
        matchmakerButton.frame = CGRect(x: 0, y: 0, width: 90, height: 35)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: matchmakerButton)
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: matchmakerImageView)
    }
    
    
}

extension PokeController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    fileprivate func initBlindView() {
        view.backgroundColor = Color.shared.background
        view.addSubview(matchmakerMessageView)
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(matchmakerNameLabel)
        view.addSubview(blindNameLabel)
        view.addSubview(hashLabel1)
        view.addSubview(hashLabel2)
        view.addSubview(hashLabel3)
        view.addSubview(pokeButton)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BlindCell.self, forCellWithReuseIdentifier: cellName)
        
        matchmakerMessageView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 110, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 70)
        view.bringSubview(toFront: matchmakerMessageView)
        collectionView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: view.frame.width * 0.95)
        pageControl.anchor(nil, left: view.leftAnchor, bottom: collectionView.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        matchmakerNameLabel.anchor(collectionView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 20)
        blindNameLabel.anchor(matchmakerNameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 5, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 30)
        
        hashLabel1.anchor(nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 130, rightConstant: 0, widthConstant: 150, heightConstant: 30)
        hashLabel2.anchor(hashLabel1.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 30)
        hashLabel3.anchor(hashLabel2.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 30)
        pokeButton.anchor(nil, left: nil, bottom: hashLabel3.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 90, heightConstant: 40)
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

extension PokeController {
    @objc fileprivate func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func toggleMatchmakerMessage() {
        UIView.animate(withDuration: 0.7) { self.matchmakerMessageView.alpha = self.matchmakerMessageView.alpha == 0 ? 1 : 0 }
    }
    
    @objc fileprivate func handlePoke() {
        guard let date = self.openDate else { return }
        App.api.poke(matchmaker: date.matchmaker.sid, poke: date.blind.user.sid) { [weak self] (dataResponse: DataResponse<JSON>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(_):
                print("콕 찔렀습니다.")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
