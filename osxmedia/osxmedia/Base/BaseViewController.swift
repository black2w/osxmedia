//
//  BaseViewController.swift
//  osxmedia
//
//  Created by black2w on 2021/7/6.
//

import Cocoa

class BaseViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.configVC()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
    }
    
    func configVC() -> Void {
        
    }
    
}
