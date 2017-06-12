//
//  ViewController.swift
//  Camare
//
//  Created by wkk on 2017/5/27.
//  Copyright © 2017年 TaikangOnline. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import MBProgressHUD


enum  DiscernType: String{
    case identiCard = "/idcard"
    case bankCard = "/bankcard"
}

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
    
    /// 照片Data数组
    var imageData:Data?
    
    /// 控制输入和输出设备之间的数据传递
    var session = AVCaptureSession()
    
    /// 调用所有的输入硬件。例如摄像头和麦克风
    var videoIput = AVCaptureDeviceInput()
    
    /// 镜头捕捉到得预览图层
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    /// 是否在去照片
    var isPhoto: Bool = false
    
    /// 获取的身份证信息信息
    var infoModel: CustomerIDInfoModel?
    
    /// app的Token信息
    var asscessTokenModel: BaiDuOCRAccessTokenModel?
    
    /// 已经识别的次数
    var count = 0
    
    /// 展示获取到的信息的视图
    var showInfoView: UIView?
    
    /// 识别请求地址
    var baseURL = "https://aip.baidubce.com/rest/2.0/ocr/v1"
    
    /// 最大重试次数
    let MAXTRYCOUNT = 4
    
    var maskView:Even_OddView?
    
    var type: DiscernType = .bankCard
    
    let appID = "你的appid"
    let appSecretID = "你的Secretid"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showTypeView()
    }
    
    func showTypeView(){
        let alertVc = UIAlertController(title: "选择识别类型", message: "", preferredStyle: .actionSheet)
        let alertAction1 = UIAlertAction(title: "身份证", style: .default, handler: { (action) in
            self.type = .identiCard
            self.getAccessToken()
        })
        let alertAction2 = UIAlertAction(title: "银行卡", style: .default, handler: { (action) in
            self.type = .bankCard
            self.getAccessToken()
        })
        alertVc.addAction(alertAction1)
        alertVc.addAction(alertAction2)
        self.present(alertVc, animated: true, completion: nil)
    }
    
    /// 对相机进行初始化
    func setCaramer(){
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        //更改闪关灯和对焦模式，更改设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
        try! device?.lockForConfiguration()
        device?.flashMode = .off
        device?.focusMode = .continuousAutoFocus
        device?.unlockForConfiguration()
        // 初始化输入
        try? videoIput = AVCaptureDeviceInput(device: device)
        // 添加输入
        if session.canAddInput(videoIput){
            session.addInput(videoIput)
        }
        // 初始化输出
        let videoDataOutPut = AVCaptureVideoDataOutput()
        videoDataOutPut.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable:kCVPixelFormatType_32BGRA]
        videoDataOutPut.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue.global())
        // 添加输出
        if session.canAddOutput(videoDataOutPut){
            session.addOutput(videoDataOutPut)
        }
        // 初始化预览层
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.frame = view.bounds
        
        maskView = Even_OddView(frame: view.bounds, tipType: type)
        view.layer.addSublayer(previewLayer)
        view.addSubview(maskView!)
        // 开始捕获图像
        session.startRunning()
    }
    //捕获取样buffer里的内容，创建一个图片
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if isPhoto == true{
            return
        }else{
            isPhoto = true
        }
        let data = image(from: sampleBuffer)
        imageData = data
        
        // MARK: 在此处打开此处注释，可以通过百度ocr识别身份证和银行卡，在这之前你需要花五分钟注册一个百度应用，然后把获取到的appID，和secretID在上替换即可
        
        //上传服务器进行识别
//        discernIdentifercation()

    }

    ///  捕获取样buffer里的内容，创建一个图片
    func image(from sampleBuffer:CMSampleBuffer) -> Data{
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        CVPixelBufferLockBaseAddress(imageBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer!)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!)
        let width = CVPixelBufferGetWidth(imageBuffer!)
        let height = CVPixelBufferGetHeight(imageBuffer!)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        
        /// 初始化上下文
        let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        let quartzImage = context!.makeImage()
        
        CVPixelBufferUnlockBaseAddress(imageBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let image = UIImage(cgImage: quartzImage!)
        let data = UIImageJPEGRepresentation(image, 0.5)
        return data!
        
    }
    
    /// 获取token
    func getAccessToken(){
        
        let hub = MBProgressHUD.showAdded(to: view, animated: true)
        hub.mode = .indeterminate
        hub.label.text = "请求token中"
        hub.minShowTime = 1
        let param = [
            "grant_type": "client_credentials",
            "client_id":appID,
            "client_secret":appSecretID
        ]
        weak var `self` = self
        Alamofire.request("https://aip.baidubce.com/oauth/2.0/token", method: .post, parameters: param, encoding: URLEncoding.default, headers: nil).responseJSON { (respone) in
            if let dict = respone.result.value{
                let value = dict as! [String: Any]
                self?.asscessTokenModel = BaiDuOCRAccessTokenModel(JSON: value)
                hub.progress = 1
                MBProgressHUD.hide(for: self!.view, animated: true)
                //设置相机
                self?.setCaramer()
            }
        }
    }
    
    /// 图片发送到服务器识别
    func discernIdentifercation(){
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            let hub = MBProgressHUD.showAdded(to: self.view, animated: true)
            hub.mode = .indeterminate
            hub.label.text = "识别中..."
            hub.minShowTime = 1
        }
        
        guard let imageData = imageData else {
            return
        }
        count += 1
        let url = baseURL + type.rawValue + "?access_token=" + "\(asscessTokenModel?.accessToken ?? "")"
        let img = imageData.base64EncodedString()
        Alamofire.upload(multipartFormData: { (formData) in
            formData.append(img.data(using: .utf8)!, withName: "image")
            formData.append("front".data(using: .utf8)!, withName: "id_card_side")
            formData.append("true".data(using: .utf8)!, withName: "detect_direction")
        }, to: url) { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _ ):
                upload.responseJSON(completionHandler: { (respones) in
                    let object = respones.result.value
                    self.handleResult(object)
                })
            case .failure(let encodingError):
                print("Failure")
                print(encodingError)
            }
        }
    }
   
    /// 处理请求结果
    func handleResult(_ object: Any?){
        guard let object = object else {
            self.reStart()
            return
        }
        print(object)
        let dict = object as!  [String : Any]
        self.infoModel = CustomerIDInfoModel(JSON: dict)
        //识别银行卡
        if type == .bankCard {
            if infoModel!.errorMsg == nil {
                showinfo()
                MBProgressHUD.hide(for: self.view, animated: true)
            }else if count < MAXTRYCOUNT{
                reStart()
            }else{
               showfailAlert()
            }
            return
        }
        if self.infoModel?.imageStatus != "normal" && self.count < MAXTRYCOUNT{
            self.reStart()
        }else if self.infoModel?.imageStatus == "normal"{
            DispatchQueue.main.async {
                self.showinfo()
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }else{
           showfailAlert()
        }

    }
    func showfailAlert(){
        MBProgressHUD.hide(for: self.view, animated: true)
        let alertVc = UIAlertController(title: "识别超时！", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "确定", style: .cancel, handler: { (action) in
            self.tryAgain()
        })
        alertVc.addAction(alertAction)
        self.present(alertVc, animated: true, completion: nil)

    }
    
    /// 展示识别出来的信息
    func showinfo(){
        if showInfoView == nil{
            showInfoView = UIView(frame: self.view.bounds)
            showInfoView?.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            let btn = UIButton(frame: CGRect(x: 40, y: 40, width: 100, height: 100))
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.setTitleColor(UIColor.black, for: .normal)
            btn.backgroundColor = #colorLiteral(red: 0.1595295668, green: 0.9977020621, blue: 0.07541743666, alpha: 1)
            btn.setTitle("好想再来一次", for: .normal)
            btn.layer.cornerRadius = 50
            btn.clipsToBounds = true
            btn.addTarget(self, action: #selector(reStart), for: .touchUpInside)
            showInfoView?.addSubview(btn)
            let lablel = UILabel()
            lablel.frame = CGRect(x: 20, y: 200, width: view.bounds.width, height: 400)
            lablel.text = makeShowStr()
            lablel.textAlignment = .left
            lablel.numberOfLines = 0
            lablel.textColor = #colorLiteral(red: 0.1595295668, green: 0.9977020621, blue: 0.07541743666, alpha: 1)
            lablel.sizeToFit()
            showInfoView?.addSubview(lablel)
            self.view.addSubview(showInfoView!)
            maskView?.isHidden = true
        }else{
            showInfoView?.isHidden = false
            maskView?.isHidden = true
        }
       
       
    }
    
    func makeShowStr() -> String{
        
        let str: String
        switch type {
        case .identiCard:
            let result = infoModel?.wordsResult
            str = "姓名：\(result?.name?.words ?? "")\n住址：\(result?.address?.words ?? "")\n生日：\(result?.birthday?.words ?? "")\n证件号码：\(result?.idNumber?.words ?? "")\n性别：\(result?.sex?.words ?? "")\n名族：\(result?.nation?.words ?? "")\n"
        case .bankCard:
            let result = infoModel?.result
            str  = "账号：\(result?.bankNumber ?? "")\n银行：\(result?.bankName ?? "")\n卡类型：\(result?.bankType ?? "")\n"
        }
       
        return str
    }
    
    /// 再试一次
    func tryAgain(){
        count = 0
        showInfoView?.isHidden = true
        maskView?.isHidden = false
        isPhoto = false
    }
    
    /// 重新识别
    func reStart(){
        showInfoView?.isHidden = true
        maskView?.isHidden = false
        isPhoto = false
    }
}


