//
//  MyPictureController.swift
//  chinchinso
//
//  Created by hyunsu han on 2018. 2. 1..
//  Copyright © 2018년 hyunsu han. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

import TLPhotoPicker
import Photos

import RxSwift
import RxCocoa

protocol MyPictureControllerDelegate: class {
    func refresh()
}

class MyPictureController: UIViewController {

    var selectedAssets = [TLPHAsset]()
    var dataSource = [Model.Picture]() {
        didSet { collectionView.reloadData() }
    }
    var cellId = "pictureCell"
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(PictureCell.self, forCellWithReuseIdentifier: cellId)
        cv.backgroundColor = .white
        cv.layer.masksToBounds = true
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.shared.background
        initNavigationBar()
        view.addSubview(collectionView)
        collectionView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        App.api.getMyPicture { [weak self] (dataResponse: DataResponse<[Model.Picture]>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(let data):
                self.dataSource = data
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    fileprivate func initNavigationBar() {
        title = "사진 관리"
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = Color.shared.background
        self.navigationController?.navigationBar.tintColor = .darkGray
        self.navigationController?.navigationBar.clipsToBounds = true               // bottom line hide
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-back").fillColor(.darkGray), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true
        
        let uploadButton = UIButton(type: .custom)
        uploadButton.setImage(#imageLiteral(resourceName: "photo").withRenderingMode(.alwaysOriginal).scaleToSize(aSize: CGSize(width: 35, height: 35)), for: .normal)
        
        uploadButton.addTarget(self, action: #selector(uploadPicture), for: .touchUpInside)
        uploadButton.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uploadButton)
    }
    
}

extension MyPictureController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? PictureCell else { return PictureCell() }
        cell.delegate = self
        cell.controller = self
        cell.update(data: dataSource[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width , height: view.frame.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}


extension MyPictureController: MyPictureControllerDelegate {
    
    func refresh() {
        dataSource.removeAll()
        App.api.getMyPicture { [weak self] (dataResponse: DataResponse<[Model.Picture]>) in
            guard let `self` = self else { return }
            switch dataResponse.result {
            case .success(let data):
                self.dataSource = data
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    @objc fileprivate func back() { self.navigationController?.popViewController(animated: true) }
    
    @objc fileprivate func uploadPicture() {
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            self?.showExceededMaximumAlert(vc: picker)
        }
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.maxSelectedAssets = 5
        configure.selectedColor = Color.shared.orangeYellow
        configure.cancelTitle = "취소"
        configure.doneTitle = "확인"
        configure.allowedVideo = false
        configure.allowedVideoRecording = false
        configure.allowedLivePhotos = false
        viewController.configure = configure
        viewController.selectedAssets = self.selectedAssets
        
        self.present(viewController, animated: true, completion: nil)
    }
}


extension MyPictureController: TLPhotosPickerViewControllerDelegate {
    
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        // use selected order, fullresolution image
        self.selectedAssets = withTLPHAssets
        getSelectedImage()
    }
    
    func getSelectedImage() {
        guard let uid = GlobalState.instance.uid else { return }
        self.selectedAssets.forEach { (asset: TLPHAsset) in
            guard let image = asset.fullResolutionImage else { return }
            guard let data = UIImageJPEGRepresentation(image, 0.9) else { return }
            let parameters: [String: String] = [
                "opt": OPT.uploadPicture.rawValue,
                "my_id": "\(uid)",
                "main" : "0"
            ]
            
            Alamofire.upload(multipartFormData: { (form) in
                form.append(data, withName: "uploadedfile", fileName: "fileUpload.jpg", mimeType: "image/jpg")
                parameters.forEach({ (arg :(key: String, value: String)) in
                    form.append(arg.value.data(using: .utf8)!, withName: arg.key)
                })
            }, to: PumkitRouter.apiUrlString, encodingCompletion: { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(_, _, _):
                    self.refresh()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
        }
    }
    func photoPickerDidCancel() {
        // cancel
    }
    
    func dismissComplete() {
        // picker dismiss completion
    }
    
    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        self.showExceededMaximumAlert(vc: picker)
    }
    
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        let alert = UIAlertController(title: "", message: "카메라 권한이 없습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showExceededMaximumAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "", message: "선택하실 수 있는 사진 개수를 초과했습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }

}
