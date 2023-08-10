//
//  PapagoRouter.swift
//  Sesac_API_Assign
//
//  Created by 김태윤 on 2023/08/10.
//

import Foundation
import Alamofire

enum LangCode:Int,CaseIterable{
    case ko,en,ja,es,fr
    var code: String{
        PapagoResources.LangCodeTable[self] ?? "unk"
    }
    var korean:String{
        PapagoResources.LangCodeKoreanTable[self] ?? "이상한 언어 코드"
    }
    static func getCode(codeName: String)->Self?{
        Self.allCases.first { langCode in langCode.code == codeName }
    }
}
// https://openapi.naver.com/v1/papago/detectLangs
enum PapagoRouter{
    static let baseURL = "https://openapi.naver.com/v1/papago"
    case detect(query:String)
    case translate(from:LangCode,to:LangCode,query:String)
    
    private var url: String{
        switch self{
        case .translate: return Self.baseURL + "/n2mt"
        case .detect: return Self.baseURL + "/detectLangs"
        }
    }
    private var headers: HTTPHeaders{
        var headers = HTTPHeaders()
        headers["X-Naver-Client-Id"] = API_Key.papagoID
        headers["X-Naver-Client-Secret"] = API_Key.papagoSecret
        return headers
    }
    
    private var method: HTTPMethod{
        switch self{
        case .detect, .translate: return .post
        }
    }
    private var params: Parameters{
        var param = Parameters()
        switch self{
        case let .translate(from,to,query):
            param["source"] = from.code
            param["target"] = to.code
            //            if let text = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
            //                print("Router Text",text)
            param["text"] = query
            //            }
        case let .detect(query):
            //            if let text = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
            param["query"] = query
            //            }
        }
        return param
    }
    
    func action(_ completion:@escaping (AFDataResponse<Any>)->Void){
        AF.request(url,method: method,parameters: params, headers: headers).validate(statusCode: 200...300)
            .responseJSON(completionHandler: completion)
    }
}

