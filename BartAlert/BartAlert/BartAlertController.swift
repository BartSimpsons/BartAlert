//
//  BartAlertController.swift
//  BARTAlert
//
//  Created by simpsons on 2017/2/9.
//  Copyright © 2017年 simpsons. All rights reserved.
//

import UIKit

let HEIGHT = UIScreen.main.bounds.height
let WIDTH = UIScreen.main.bounds.width


typealias BartActionHandler = ((_ action:BartAction) -> Void)

enum BartActionStyle {
    case grayStyle
    case blueStyle
    case defaultStyle
}

class BartAction : NSObject{
    
    fileprivate var ActionTitle:String!
    fileprivate var ActionHandler:BartActionHandler?
    fileprivate var ActionBGColor:UIColor?
    fileprivate var ActionTitleColor:UIColor!
    fileprivate var ActionStyle:BartActionStyle?
    fileprivate var ActionHeight:CGFloat!
    
    convenience init(title:String, handler: @escaping (BartActionHandler)){
        
        self.init()
        self.ActionTitle = title
        self.ActionStyle = BartActionStyle.defaultStyle
        self.ActionHeight = 50
        self.ActionHandler = handler
        
    }
    
    convenience init(title:String, color:UIColor, titleColor:UIColor, handler:@escaping (BartActionHandler)){
        
        self.init()
        self.ActionTitle = title
        self.ActionBGColor = color
        self.ActionTitleColor = titleColor
        self.ActionHeight = 40
        self.ActionHandler = handler
        
    }
    
    convenience init(title:String, style:BartActionStyle, handler:@escaping (BartActionHandler)){
        
        self.init()
        self.ActionTitle = title
        self.ActionStyle = style
        self.ActionHeight = 40
        self.ActionHandler = handler

    }
    
}


class BartAlertController: UIViewController,UITextFieldDelegate {

    /*界面元素*/
    private var alertView:UIView!
    private var contentView:UIView!
    
    private var titleLabel:UILabel!
    private var messageLabel:UILabel!
    
    private var contentMargin:UIEdgeInsets!
    private var contentViewWidth:CGFloat!
//    private var buttonHeight:CGFloat!
    private var textFieldHeight:CGFloat!
    
    private var contentViewFrameNormal:CGRect!
    private var KeyboardFrame:CGRect!
    
    //有不同的按钮高度 定义一个所有高度的变量
    private var allButtonHeight:CGFloat = 0
    
    /*点击按钮*/
    var actions = [BartAction]()
    
    /*输入框*/
    var inputTextFields = [UITextField]()
    
    //防止重复弹出视图
    private var firstShow:Bool!
    
    //是否带输入框
    private var hasTextFields:Bool!
    
    //文字排列
    var messageAlignment:NSTextAlignment!
    private var dismissDelay:Double = 0.0
    
    private var AlertTitle:String = ""
    private var AlertMessage:String = ""
    
    convenience init(title:String,message:String){
        
        self.init()
        self.modalPresentationStyle = UIModalPresentationStyle.custom
        self.AlertTitle = title
        self.AlertMessage = message
        self.Setdefault()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //创建界面
        self.creatAlertView()
        self.creatContentView()
        self.creatTitleLabel()
        self.creatMessageLabel()
        self.creatAllInputText()
        self.creatActionButton()
        self.creatAllSeparatorLine()
        
        //键盘监听
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
        if self.inputTextFields.count > 0{
            
            self.inputTextFields[0].becomeFirstResponder()
            
        }
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }

    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        self.view.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2)
        
        print("====\(self.alertView.frame)====")
        
        if self.hasTextFields == true{
            
            //更新标题的frame
            self.updateTitleLabelFrame()
            
            //更新文字的frame
            self.updateMessageLabelFrame()
            
            //更新输入框的frame
            self.updateAllTextFieldFrame()
            
            //更新按钮的frame
            self.updateAllButtonFrame()
            
            //更新分割线的frame
            self.updateAllSeparatorLine()
            
            //更新alert的frame
            self.updateAlertContentViewFrame()
            
        }
        
        if dismissDelay == 0.0{
            self.showAlert()
        }else{
            self.showAndDismiss(delay: self.dismissDelay)
        }
        
    }
    
    private func Setdefault(){
        
        self.contentMargin = UIEdgeInsets.init(top: 25, left: 20, bottom: 0, right: 20)
        self.contentViewWidth = 0.8*WIDTH
        self.textFieldHeight = 30
        self.firstShow = true
        self.hasTextFields = true
        self.messageAlignment = NSTextAlignment.center
        
    }
    
    private func creatAlertView(){
        
        self.alertView = UIView()
        self.alertView.layer.masksToBounds = false
        
        //警告框的初始尺寸为1.2倍
        self.alertView.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
        //阴影颜色
        self.alertView.layer.shadowColor = UIColor.black.cgColor
        //shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使
        self.alertView.layer.shadowOffset =  CGSize.init(width: 10, height: -10)
        //阴影半径
        self.alertView.layer.shadowRadius = 13
        //阴影透明度
        self.alertView.layer.shadowOpacity = 0.4
        self.view.addSubview(self.alertView)
        
    }

    //文字内容
    private func creatContentView(){
        
        self.contentView = UIView()
        self.contentView.backgroundColor = UIColor.white
        self.contentView.layer.cornerRadius = 8
        self.contentView.layer.masksToBounds = true
        self.alertView.addSubview(self.contentView)
        
    }
    
    //寻常label的初始化调用
    private func creatGeneralLabel(fontSize:CGFloat) -> UILabel{
        
        let label = UILabel.init()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: fontSize)
        return label
        
    }
    
    //标题
    private func creatTitleLabel(){
        
        self.titleLabel = self.creatGeneralLabel(fontSize: 20)
        self.titleLabel.textColor = UIColor.bartBlack
        self.titleLabel.textAlignment = NSTextAlignment.center
        self.titleLabel.text = self.AlertTitle
        self.contentView.addSubview(self.titleLabel)
        
    }

    private func creatMessageLabel(){
        
        self.messageLabel = self.creatGeneralLabel(fontSize: 15)
        self.messageLabel.textColor = UIColor.bartGray
        self.messageLabel.textAlignment = NSTextAlignment.center
        self.messageLabel.text = self.AlertMessage
        self.contentView.addSubview(self.messageLabel)
        
    }
    
    private func creatAllInputText(){
        
        for (index, textFields) in self.inputTextFields.enumerated(){
            
            let textfield = textFields
            textfield.borderStyle = .line
            textfield.layer.borderColor = UIColor.init(white: 0.85, alpha: 0.6).cgColor
            textfield.layer.borderWidth = 0.5
            textfield.tag = 10 + index
            textfield.delegate = self
            self.contentView.addSubview(textfield)
            
        }
        
    }
    
    private func creatActionButton(){
        
        for (index, obj) in self.actions.enumerated(){
            
            let btn = UIButton.init(type: .custom)
            btn.tag = 100 + index
            
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            
            let actTitle:String! = obj.ActionTitle
            
            btn.setTitle(actTitle, for: .normal)

            if let style = obj.ActionStyle{
                
                switch style {
                case .grayStyle:
                    
                    obj.ActionTitleColor = UIColor.bartBlack
                    obj.ActionBGColor = UIColor.bartGrayBG
                    btn.layer.borderWidth = 1
                    btn.layer.cornerRadius = 6.0
                    btn.layer.borderColor = UIColor.init(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1.0).cgColor
                    
                case .blueStyle:
                    
                    obj.ActionTitleColor = UIColor.white
                    obj.ActionBGColor = UIColor.bartBlue
                    btn.layer.borderWidth = 1
                    btn.layer.cornerRadius = 6.0
                    btn.layer.borderColor = UIColor.init(red: 38/255.0, green: 138/255.0, blue: 209/255.0, alpha: 1.0).cgColor
                    
                case .defaultStyle:
                    
                    obj.ActionTitleColor = UIColor.bartGray
                    obj.ActionBGColor = UIColor.white
                    
                }
                
            }else{
                
                btn.layer.borderWidth = 1
                btn.layer.cornerRadius = 6.0
                btn.layer.borderColor = UIColor.init(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1.0).cgColor
                
            }
            
            if obj.ActionBGColor != UIColor.white{
                
                btn.backgroundColor = obj.ActionBGColor
                btn.setBackgroundImage(UIColor().creatImageWithColor(color: UIColor.black.withAlphaComponent(0.1)), for: UIControlState.highlighted)
                
                
            }else{
                
                btn.setBackgroundImage(UIColor().creatImageWithColor(color: UIColor.init(white: 0.97, alpha: 1)), for: UIControlState.highlighted)
                
            }
            
            btn.setTitleColor(obj.ActionTitleColor, for: .normal)
            btn.addTarget(self, action:#selector(didClickButton(sender:)) , for: .touchUpInside)
            self.contentView.addSubview(btn)
            
        }
        
    }
    
    private func creatAllSeparatorLine(){
        
        if self.actions.count > 0{
            
            let linesAmount = self.getLineCount()
            for index in 0..<linesAmount{
                
                let separatorLine = UIView()
                separatorLine.tag = 1000 + index
                separatorLine.backgroundColor = UIColor.init(white: 0.85, alpha: 1.0)
                self.contentView.addSubview(separatorLine)
                
            }
        }
    }
    
    //点击事件
    @objc private func didClickButton(sender:UIButton){
        
        self.dismissAnimation()
        let act = self.actions[sender.tag - 100]
        if (act.ActionHandler != nil){
            act.ActionHandler!(act)
        }
        
    }
    
    func addAction(action:BartAction){
        
        self.actions.append(action)
        
    }
    
    func addTextField(textfield:UITextField){
        
        self.inputTextFields.append(textfield)
        
    }
    
    func show(_ target:AnyObject){
        
        target.present(self, animated: false, completion: nil)
        
    }
    
    func showWith(target:AnyObject, delay:Double) {
        
        target.present(self, animated: false, completion: nil)
        self.dismissDelay = delay
        
    }
    
    private func updateTitleLabelFrame(){
        
        let titleWidth = contentViewWidth - contentMargin.left - contentMargin.right
        
        if self.AlertTitle.characters.count > 0{
            
            let size = self.titleLabel.sizeThatFits(CGSize.init(width: titleWidth, height: CGFloat.greatestFiniteMagnitude))
            
            self.titleLabel.frame = CGRect.init(x: contentMargin.left, y: contentMargin.top, width: titleWidth, height: size.height)
            
        }
        
    }
    
    private func updateMessageLabelFrame(){
        
        let MessageWidth = contentViewWidth - contentMargin.left - contentMargin.right
        let messageY = self.AlertTitle.characters.count > 0 ? self.titleLabel.frame.maxY + 20 : contentMargin.top
        
        if self.AlertMessage.characters.count > 0 {
            
            let size = self.messageLabel.sizeThatFits(CGSize.init(width: MessageWidth, height: CGFloat.greatestFiniteMagnitude))
            
            self.messageLabel.frame = CGRect.init(x: contentMargin.left, y: messageY, width: MessageWidth, height: size.height)
            
        }
        
    }
    
    private func updateAllTextFieldFrame(){

        for (index, obj) in self.inputTextFields.enumerated(){
            
            let textfieldWidth:CGFloat = contentViewWidth - contentMargin.left - contentMargin.right
            let fieldX = contentMargin.left
            let fieldY = self.getCharacterHeight() + textFieldHeight * CGFloat(index)
            obj.frame = CGRect.init(x: fieldX, y: fieldY, width: textfieldWidth, height: textFieldHeight)
            
        }
        
    }
    
    private func updateAllButtonFrame(){
        
        if self.actions.count > 0{
            
            let buttonMarginLeft:CGFloat = 15
            let buttonWidth:CGFloat = self.actions.count == 2 ? (contentViewWidth - buttonMarginLeft * 3)/2 : contentViewWidth - buttonMarginLeft * 2
            var btnY:CGFloat = 0
            
            for (index, obj) in self.actions.enumerated(){
                
                let btn = self.contentView.viewWithTag(100 + index)
                let btnX = self.actions.count > 2 ? buttonMarginLeft : buttonWidth * CGFloat(index) + buttonMarginLeft * CGFloat(index + 1)
                
                let y = index == 0 ? 0 : self.actions[index - 1].ActionHeight * CGFloat(index)
                
                btnY = self.actions.count > 2 ? self.getCharacterHeight() + y : self.getCharacterHeight()
                
                if index == self.actions.count - 1 && (obj.ActionStyle == .blueStyle || obj.ActionStyle == .grayStyle) && self.actions.count != 2{
                    
                    btnY += 15
                    allButtonHeight += 15
                    
                }
                
                let textfieldY = self.inputTextFields.count > 0 ? textFieldHeight * CGFloat(self.inputTextFields.count) + 15 : 0
                
                btn?.frame = CGRect.init(x: btnX, y: btnY + textfieldY, width: buttonWidth, height: obj.ActionHeight)
                allButtonHeight += self.actions.count == 2 ? obj.ActionHeight/2 : obj.ActionHeight
                
            }
            
        }
    }
    
    private func updateAllSeparatorLine(){
        
        if self.actions.count > 0{
            
            let linesAmount = self.getLineCount()
            
            //如果没有标题和内容，按钮大于2个，分割线从第一个按钮的下方开始,例如3个按钮的无内容无标题弹框
            let offsetAmount = (self.AlertTitle.characters.count > 0 || self.AlertMessage.characters.count > 0) ? 0 : 1
            
            for index in 0..<linesAmount {
                
                let separatorLine = self.contentView.viewWithTag(1000 + index)
                
                if index == linesAmount - 1{
                    
                    let btn = self.contentView.viewWithTag(100 + index - 1 + offsetAmount)
                    
                    let y = (btn?.frame.origin.y)! + (btn?.frame.height)!
                    separatorLine?.frame = CGRect.init(x: 15, y: y, width: contentViewWidth - 30, height: 0.5)
                    
                }else{
                    
                    //获取对应的按钮，如果没有标题和内容，分割线从第一个按钮的下方开始  如果有则是从按钮上方开始
                    let btn = self.contentView.viewWithTag(100 + index + offsetAmount)
                    let y = btn?.frame.origin.y
                    separatorLine?.frame = CGRect.init(x: 15, y: y!, width: contentViewWidth - 30, height: 0.5)
                    
                }
                
            }
            
        }
    }
    
    private func updateAlertContentViewFrame(){
        
        let textfieldHeigth:CGFloat = self.inputTextFields.count > 0 ? textFieldHeight * CGFloat(self.inputTextFields.count) + 15 : 0
        
        self.alertView.frame = CGRect.init(x: (WIDTH - contentViewWidth)/2, y: 0, width: contentViewWidth, height: self.getCharacterHeight() + allButtonHeight/2 + textfieldHeigth + 30)
        contentViewFrameNormal = self.alertView.frame
        
        if self.inputTextFields.count > 0 && KeyboardFrame != nil && KeyboardFrame.origin.y <= self.view.center.y + self.alertView.frame.height/2{
            
            self.alertView.frame.origin.y = KeyboardFrame.origin.y - self.alertView.frame.height - 15
            self.contentView.frame = self.alertView.bounds
            
        }else{
            
            self.alertView.center = self.view.center
            self.contentView.frame = self.alertView.bounds
           
        }
        
         print("====\(self.alertView.frame)====")
        
    }
    
    // MARK: - 计算方法
    private func getLineCount() -> Int {
        
        //分割线条数
        var linesAmount = 0

        for obj in self.actions{
            
            if obj.ActionStyle == BartActionStyle.defaultStyle{
                linesAmount += 1
            }
            
        }
        
        linesAmount += linesAmount == 0 ? 0 : 1
        
        //如果没有标题和内容，分割线条数就减一
        linesAmount -= (self.AlertTitle.characters.count > 0 || self.AlertMessage.characters.count > 0) ? 0 : 1
        
        return linesAmount < 0 ? 0 : linesAmount
    }
    
    private func getCharacterHeight() -> CGFloat{
    
        
        var characterHeight:CGFloat = 0
        
        if self.AlertTitle.characters.count > 0 {
            
            characterHeight = self.titleLabel.frame.maxY
            
        }
        
        if self.AlertMessage.characters.count > 0 {
            
            characterHeight = self.messageLabel.frame.maxY
            
        }
        
        characterHeight += characterHeight > 0 ? 15 : 0
        return characterHeight
    
    }
    
    /*键盘弹出*/
    func keyboardWillShow(_ showNoti:Notification){
        
        KeyboardFrame = (showNoti.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardY = KeyboardFrame.origin.y
        if keyboardY <= self.view.center.y + self.alertView.frame.height/2{
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 15.0, options: .curveLinear, animations: {
                
                if (self.hasTextFields == true && self.firstShow == false){
                    
                    self.hasTextFields = false;
                    
                }
                    
                self.alertView.frame.origin.y = keyboardY - self.alertView.frame.height - 15
                self.contentView.frame = self.alertView.bounds
                
                
            }, completion: nil)
            
        }
        
    }
    
    /*键盘隐藏*/
    func keyboardWillHide(_ hideNoti:Notification){
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 5.0, options: .curveEaseOut, animations: {
            
            if self.contentViewFrameNormal != nil{
                
                self.alertView.frame = self.contentViewFrameNormal
                
            }
            
            self.alertView.center = self.view.center
            self.contentView.frame = self.alertView.bounds
            
        }, completion: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //收起键盘
        textField.resignFirstResponder()
        return true
    }
    
    /*出现动画*/
     func showAlert(){
        
        if (self.firstShow == true){
            
            self.firstShow = false
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 5.0, options: .curveEaseInOut, animations: {
                
                self.alertView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                self.alertView.alpha = 1
                
            }, completion: nil)
            
        }
    }
    
    /*2S自动消失*/
    private func showAndDismiss(delay:Double){
        
        if (self.firstShow == true){
            
            self.firstShow = false
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 5.0, options: .curveEaseInOut, animations: {
                
                self.alertView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                self.alertView.alpha = 1
                
            }, completion: nil)
            
            UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 1.0, initialSpringVelocity: 15.0, options: .curveEaseInOut, animations: {

                self.alertView.alpha = 0
                self.view.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.0)
                self.dismiss(animated: false, completion: nil)

            }, completion:{ _ in
            
                
                
            })
        }
    }
    
    
    @objc private func dismissAnimation(){
        
//        for index in 0..<self.inputTextFields.count{
//            
//            self.inputTextFields[index].resignFirstResponder()
//            
//        }
        
        for obj in self.inputTextFields{
            
            obj.resignFirstResponder()
            
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 15.0, options: .curveLinear, animations: {
            
            self.alertView.alpha = 0
            self.view.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.0)
            self.dismiss(animated: false, completion: nil)
            
        }, completion: { (isFinished) in
            
            
            
        })
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIColor{
    
    //UIColor转UIImage
    func creatImageWithColor(color:UIColor) -> UIImage{
        
        let rect = CGRect.init(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context?.fill(rect)
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return colorImage!
        
    }
    
    class var bartBlack:UIColor{
        
        return UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
        
    }
    
    class var bartGray:UIColor{
        
        return UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0)
        
    }
    
    class var cartBlue:UIColor{
        
        return UIColor.init(red: 43/255.0, green: 156/255.0, blue: 237/255.0, alpha: 1.0)
        
    }
    
    class var bartGrayBG:UIColor{
        
        return UIColor.init(red: 245/255.0, green: 246/255.0, blue: 247/255.0, alpha: 1.0)
        
    }
}

extension UIColor{
    
    class var bartBlue:UIColor{
        
        return UIColor.init(red: 43/255.0, green: 156/255.0, blue: 237/255.0, alpha: 1.0)
        
    }
    
}
