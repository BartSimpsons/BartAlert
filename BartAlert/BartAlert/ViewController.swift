//
//  ViewController.swift
//  BartAlert
//
//  Created by simpsons on 2017/4/18.
//  Copyright © 2017年 simpsons. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let but = UIButton.init(frame: CGRect.init(x: 40, y: 100, width: 100, height: 40))
        but.backgroundColor = UIColor.black
        but.addTarget(self, action: #selector(ShowAlert), for: .touchUpInside)
        but.setBackgroundImage(UIColor().creatImageWithColor(color: UIColor.orange), for: .selected)
        self.view.addSubview(but)
        
        let but2 = UIButton.init(frame: CGRect.init(x: 160, y: 100, width: 100, height: 40))
        but2.backgroundColor = UIColor.bartBlue
        but2.addTarget(self, action: #selector(ShowMyAlertController), for: .touchUpInside)
        self.view.addSubview(but2)
        
        let but3 = UIButton.init(frame: CGRect.init(x: 40, y: 180, width: 100, height: 40))
        but3.backgroundColor = UIColor.bartBlack
        but3.addTarget(self, action: #selector(ShowMyAlertController3), for: .touchUpInside)
        self.view.addSubview(but3)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func ShowAlert(){
        
        let al = BartAlertController.init(title: "提示", message: "拉拉爱啦啦啦阿拉啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦阿拉蕾")
        let act = BartAction.init(title: "test", style: .blueStyle) { (action:BartAction) in
            
            print("=====test====")
            
        }
        
        let act1 = BartAction.init(title: "试试", color: UIColor.orange, titleColor: UIColor.bartGray) { (BartAction) in
            
        }
        
        al.addAction(action: act)
        al.show(self)
        
    }
    
    
    func ShowMyAlertController(){
        
        let al = BartAlertController.init(title: "再次提示用个长一点的标题好了！！！！", message: "一个比较简单的一句话测试！")
        
        let test = UITextField()
        test.placeholder = "test"
        al.addTextField(textfield: test)
        
        let act = BartAction.init(title: "false", style: .grayStyle) { (action:BartAction) in
            
            
        }
        
        let act3 = BartAction.init(title: "true", style: .blueStyle) { (action:BartAction) in
            
            
        }
        
        
        
        al.addAction(action: act)
        al.addAction(action: act3)
        al.show(self)
        
    }
    
    func ShowMyAlertController3(){
        
        let al = BartAlertController.init(title: "性别", message: "")
        
        
        
        let act = BartAction.init(title: "男") { (action:BartAction) in
            
            print("男")
            
        }
        
        
        let act2 = BartAction.init(title: "女") { (action:BartAction) in
            
            print("女")
        }
        
        let act3 = BartAction.init(title: "取消", style: .grayStyle) { (action:BartAction) in
            
            
        }
        
        al.addAction(action: act)
        al.addAction(action: act2)
        al.addAction(action: act3)
        al.show(self)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

