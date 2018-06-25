//
//  Extensions.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 10. 20..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Foundation

enum BackendError: Error {
    case network(error: Error)
    case dataSerialization(reason: String)
    case jsonSerialization(error: Error)
    case objectSerialization(reason: String)
    case xmlSerialization(error: Error)
}

extension DataRequest {
    @discardableResult
    public func responseSwiftyJSON(_ completionHandler: @escaping (DataResponse<JSON>) -> Void) -> Self {
        let responseSerializer = DataResponseSerializer<JSON> { request, response, data, error in
            guard error == nil else {
                DataRequest.errorMessage(response, error: error, data: data)
                return .failure(error!)
            }
            let result = DataRequest
                .jsonResponseSerializer(options: .allowFragments)
                .serializeResponse(request, response, data, error)
            switch result {
            case .success(let value):
                if let _ = response {
                    return .success(JSON(value))
                } else {
                    let failureReason = "JSON could not be serialized into response object: \(value)"
                    let error = BackendError.objectSerialization(reason: failureReason)
                    DataRequest.errorMessage(response, error: error, data: data)
                    return .failure(error)
                }
            case .failure(let error):
                DataRequest.errorMessage(response, error: error, data: data)
                return .failure(error)
            }
        }
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    static func errorMessage(_ response: HTTPURLResponse?, error: Error?, data: Data?) {
        debugPrint("status: \(response?.statusCode ?? -1), error message:\(error.debugDescription)")
    }
}



extension UIImage {
    
    // 이미지 사이즈 변경
    func scaleToSize(aSize :CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(aSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: aSize.width, height: aSize.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    // 이미지 컬러 변경
    func fillColor(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0);
        context?.setBlendMode(.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}

extension UIView {
    // Make Triangle Layer Path
    func createTrianglePath(radius: CGFloat) -> CGPath {
        
        let point1 = CGPoint(x: -self.frame.width / 2, y: self.frame.height / 2)
        let point2 = CGPoint(x: 0, y: -self.frame.height / 2)
        let point3 = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: self.frame.height / 2))
        path.addArc(tangent1End: point1, tangent2End: point2, radius: radius)
        path.addArc(tangent1End: point2, tangent2End: point3, radius: radius)
        path.addArc(tangent1End: point3, tangent2End: point1, radius: radius)
        path.closeSubpath()
        
        return path
    }
}
