//
//  TranslateVC.swift
//  Sesac_API_Assign
//
//  Created by 김태윤 on 2023/08/10.
//

import UIKit
import SwiftyJSON
class TranslateVC:UIViewController{
    @IBOutlet weak var fromText: UITextView!
    @IBOutlet weak var toText: UITextView!
    @IBOutlet weak var fromSelector: UITextField!
    @IBOutlet weak var toSelector: UITextField!
    @IBOutlet weak var translateBtn: UIButton!
    static let identifier = "TranslateVC"
    var codes = LangCode.allCases
    var fromPicker = UIPickerView()
    var toPicker = UIPickerView()
    var fromLangCode : LangCode? = nil{
        didSet{self.fromSelector.text = fromLangCode?.korean ?? "자동 선택"}
    }
    var toLangCode: LangCode? = nil{
        didSet{
            self.toSelector.text = toLangCode?.korean ?? "이상한 선택"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fromSelector.delegate = self
        self.toSelector.delegate = self
        self.fromText.delegate = self
        self.toText.delegate = self
        self.fromPicker.delegate = self;self.fromPicker.dataSource = self
        self.toPicker.delegate = self; self.toPicker.dataSource = self
        fromSelector.inputView = fromPicker
        toSelector.inputView = toPicker
        self.translateBtn.isEnabled = false
    }
    @IBAction func translateBtnTapped(_ sender: UIButton) {
        let sendText = self.fromText.text.trimmingCharacters(in: [" ","\n"])
        guard !sendText.isEmpty else {return}
        if let fromLangCode,let toLangCode{
            print(fromLangCode,toLangCode)
            PapagoRouter.detect(query: sendText).action{[weak self] response in
                guard let self else { return }
                switch response.result{
                case .success(let data):
                    let json = JSON(data)
                    let codeName = json["langCode"].stringValue
                    if let fromcode = LangCode.getCode(codeName: codeName), fromcode != fromLangCode {
                        let alert = UIAlertController(title: "입력 언어와 번역 시작 언어가 일치하지 않아요", message: nil, preferredStyle: .alert)
                        alert.addAction(.init(title: "그럴 수 있지...", style: .cancel))
                        present(alert,animated: true)
                        return
                    }
                    translateToView(from: fromLangCode, to: toLangCode, text: sendText)
                case .failure(let err):
                    print(err)
                    translateToView(from: fromLangCode, to: toLangCode, text: sendText)
                }
            }
        }else if let toLangCode{
            PapagoRouter.detect(query: sendText).action {[weak self] response in
                guard let self else {return}
                switch response.result{
                case .success(let data):
                    let json = JSON(data)
                    let codeName = json["langCode"].stringValue
                    if let fromcode = LangCode.getCode(codeName: codeName){
                        translateToView(from: fromcode, to: toLangCode, text: sendText)
                    }else{
                        let alert = UIAlertController(title: "언어 감지 실패", message: nil, preferredStyle: .alert)
                        alert.addAction(.init(title: "확인", style: .cancel))
                        present(alert,animated: true)
                    }
                case .failure(let err):
                    print(err)
                }
            }
        }
    }
    func checkTranslate(){
        if !fromText.text.isEmpty && !toSelector.text!.isEmpty && !fromSelector.text!.isEmpty{
            translateBtn.isEnabled = true
        }else {
            translateBtn.isEnabled = false
        }
    }
    func translateToView(from: LangCode,to:LangCode,text: String){
        PapagoRouter.translate(from: from, to: to, query: text)
            .action {[weak self] response in
                guard let self else {return}
                switch response.result{
                case .success(let data):
                    let json = JSON(data)
                    print(json)
                    self.toText.text = json["message"]["result"]["translatedText"].stringValue
                case .failure(let err): print(err)
                }
            }
    }
}

extension TranslateVC: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        checkTranslate()
    }
}

extension TranslateVC: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let text = textField.text, text.isEmpty else {return}
        switch textField{
        case fromSelector:
            self.fromLangCode = LangCode(rawValue: -1)
        case toSelector:
            self.toLangCode = LangCode(rawValue: 0)
        default:break
        }
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkTranslate()
    }
}


extension TranslateVC: UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView{
        case fromPicker:
            return codes.count + 1
        case toPicker:
            return codes.count
        default: return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView{
        case fromPicker:
            self.fromLangCode = LangCode(rawValue: row - 1)
        case toPicker:
            self.toLangCode = LangCode(rawValue: row)
        default: break
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView{
        case fromPicker:
//            if row == 0{ return "자동 선택"}
            return LangCode(rawValue: row - 1)?.korean ?? "자동 선택"
        case toPicker:
            return LangCode(rawValue: row)?.korean ?? "이상한 언어 선택"
        default: return ""
        }
    }
}
