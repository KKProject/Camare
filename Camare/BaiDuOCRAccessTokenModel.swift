//
//  BaiDuOCRAccessTokenModel.swift
//  Camare
//
//  Created by wkk on 2017/6/7.
//  Copyright © 2017年 TaikangOnline. All rights reserved.
//

import ObjectMapper

struct BaiDuOCRAccessTokenModel: Mappable {

    var scope : String?
    var accessToken : String?
    var expiresIn : Int?
    var refreshToken : String?
    var sessionKey : String?
    var sessionSecret : String?
    
    

    init?(map: Map){}
    
    mutating func mapping(map: Map)
    {
        scope <- map["scope"]
        accessToken <- map["access_token"]
        expiresIn <- map["expires_in"]
        refreshToken <- map["refresh_token"]
        sessionKey <- map["session_key"]
        sessionSecret <- map["session_secret"]
        
    }


}
