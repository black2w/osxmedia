//
//  TestViewController.swift
//  osxmedia
//
//  Created by black2w on 2021/8/7.
//

import Cocoa

class TestViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.view.wantsLayer  = true
        self.view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    
}
