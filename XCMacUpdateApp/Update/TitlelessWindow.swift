//
//  TitlelessWindow.swift
//  XCMacUpdateApp
//
//  Created by yuan on 2020/06/29.
//  Copyright © 2020 xccn. All rights reserved.
//

import Foundation
import Cocoa

class TitlelessWindow: NSWindow {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.styleMask = [NSWindow.StyleMask.fullSizeContentView, .closable, .miniaturizable, .titled]
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
    }
    
}
