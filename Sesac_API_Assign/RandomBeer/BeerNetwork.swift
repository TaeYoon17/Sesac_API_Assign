//
//  BeerNetwork.swift
//  Sesac_API_Assign
//
//  Created by 김태윤 on 2023/08/08.
//

import Alamofire
import Foundation
import SwiftyJSON
enum BeerNetwork{
    private static let baseURL = "https://api.punkapi.com/v2/beers"
    case Random
    private var getMethod:HTTPMethod{
        switch self{
        case .Random:
            return .get
        }
    }
    private var parameters:Parameters?{
        switch self{
        case .Random:
            return nil
        }
    }
    private var getURL:String{
        switch self{
        case .Random:
            return Self.baseURL + "/random"
        }
    }
    private var getDatas:(String,HTTPMethod,Parameters?){
        (self.getURL,self.getMethod,self.parameters)
    }
    var getDataRequest:DataRequest{
        let (url, method,params) = self.getDatas
        return AF.request(url,method: method,parameters: params)
    }
}
