//
//  OpenDateController.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 11. 27..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import Alamofire

protocol OpenDateControllerDelegate: class {
    func refresh()
}

class OpenDateController: BaseViewController {
    
    var datasource = [Model.OpenDate]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    let cellName = "OpenDateCell"
    let collectionView: UICollectionView = {
        let layout = PinterestLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.contentInset = UIEdgeInsetsMake(0, 10, 0, 10)
        cv.backgroundColor = Color.shared.background
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCollectionView()
        App.api.openBlind { [weak self] (dataResponse: DataResponse<Model.OpenDateList>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(let data):
                GlobalState.instance.openDate = data.isAgreeOpenDate
                self.datasource = data.list
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension OpenDateController: UICollectionViewDelegate, UICollectionViewDataSource, PinterestLayoutDelegate {
    
    fileprivate func initCollectionView() {
        view.addSubview(collectionView)
        
        if let layout = collectionView.collectionViewLayout as? PinterestLayout { layout.delegate = self }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(OpenDateCell.self, forCellWithReuseIdentifier: cellName)
        collectionView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as? OpenDateCell else { return OpenDateCell() }
        cell.update(data: datasource[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForDateItemAtIndexPath indexPath: IndexPath) -> CGFloat {
//        return OpenDateCell.getSize(openDate: self.datasource[indexPath.row], width: view.bounds.width / 2).height
        return (view.bounds.width / 2) - 20
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let openDate = datasource[indexPath.item]
        let pokeController = PokeController()
        pokeController.openDate = openDate
        self.navigationController?.modalTransitionStyle = .crossDissolve
        self.navigationController?.pushViewController(pokeController, animated: true)
    }
}

extension OpenDateController: OpenDateControllerDelegate {
    
    func refresh() {
        datasource.removeAll()
        collectionView.collectionViewLayout.invalidateLayout()
        let newLayout = PinterestLayout()
        collectionView.collectionViewLayout = newLayout
        newLayout.delegate = self
        
        App.api.openBlind { [weak self] (dataResponse: DataResponse<Model.OpenDateList>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(let data):
                GlobalState.instance.openDate = data.isAgreeOpenDate
                self.datasource = data.list
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
