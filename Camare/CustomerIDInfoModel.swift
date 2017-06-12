//
//  CustomerIDInfoModel.swift
//  Camare
//
//  Created by wkk on 2017/6/7.
//  Copyright © 2017年 TaikangOnline. All rights reserved.
//

import ObjectMapper

struct CustomerIDInfoModel: Mappable {

    var imageStatus : String?
    var logId : Int?
    var wordsResult : WordsResult?
    var wordsResultNum : Int?
    var result:BankCardInfo?
    var errorMsg: String?
    init?(map: Map){}
    mutating func mapping(map: Map)
    {
        imageStatus <- map["image_status"]
        logId <- map["log_id"]
        wordsResult <- map["words_result"]
        wordsResultNum <- map["words_result_num"]
        result <- map["result"]
        errorMsg <- map["error_msg"]
    }


}
struct BankCardInfo: Mappable {
    var bankNumber : String?
    var bankName : String?
    var type : Int?{
        didSet{
            switch type! {
            case 0:
                bankType = "不能识别"
            case 1:
                bankType = "借记卡"
            case 2:
                bankType = "信用卡"
            default:
                break
            }
        }
    }
    var bankType: String?
    
    init?(map: Map){}
    
    mutating func mapping(map: Map)
    {
        bankNumber <- map["bank_card_number"]
        bankName <- map["bank_name"]
        type <- map["bank_card_type"]
    }

}
struct WordsResult: Mappable {
    var address : InfoItem?
    var idNumber : InfoItem?
    var birthday : InfoItem?
    var name : InfoItem?
    var sex : InfoItem?
    var nation : InfoItem?
    
    
    
    init?(map: Map){}

    mutating func mapping(map: Map)
    {
        address <- map["住址"]
        idNumber <- map["公民身份号码"]
        birthday <- map["出生"]
        name <- map["姓名"]
        sex <- map["性别"]
        nation <- map["民族"]
        
    }
}

struct InfoItem :  Mappable{
    
    var location : Location?
    var words : String?
    
    
    init?(map: Map){}
    mutating func mapping(map: Map)
    {
        location <- map["location"]
        words <- map["words"]
        
    }
}
struct Location : Mappable{
        
        var height : Int?
        var left : Int?
        var top : Int?
        var width : Int?
        
        
    
        init?(map: Map){}
    
        
        mutating func mapping(map: Map)
        {
            height <- map["height"]
            left <- map["left"]
            top <- map["top"]
            width <- map["width"]
            
        }
}

