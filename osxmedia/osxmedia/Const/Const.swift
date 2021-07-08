//
//  Const.swift
//  osxmedia
//
//  Created by black2w on 2021/7/8.
//

import Foundation
import Cocoa

//主屏幕对象
let MAINSCREEN: NSScreen! = {
    return NSScreen.main
} ()

//主屏幕大小
let SCREN_SIZE: NSRect! = {
    return MAINSCREEN.visibleFrame
} ()

//屏幕宽
let SCREN_WIDTH: CGFloat! = {
    return SCREN_SIZE.width
} ()

//屏幕高
let SCREN_HEIGHT: CGFloat! = {
    return SCREN_SIZE.height
} ()

//渲染视频高宽比
let PREVIEWSCALE: CGFloat! = 9/16.0
//最大渲染窗口
let PREVIEW_MAXSIZE: CGSize! = {
    if SCREN_HEIGHT/SCREN_WIDTH < PREVIEWSCALE {
        //如果屏幕高宽比<高宽比，那么以高度为基准
        return CGSize(width: SCREN_HEIGHT/PREVIEWSCALE, height: SCREN_HEIGHT)
    }else {
        //如果屏幕高宽比>高宽比，那么以宽度为基准
        return CGSize(width: SCREN_WIDTH, height: SCREN_WIDTH*PREVIEWSCALE)
    }
} ()

//最小渲染宽度
let PREVIEW_MINWIDTH: CGFloat! = {
    return 640.0
} ()

//最小渲染高度
let PREVIEW_MINHEIGHT: CGFloat! = {
    return 480.0
} ()

//最小渲染窗口
let PREVIEW_MINSIZE: CGSize! = {
 return CGSize(width: PREVIEW_MINWIDTH, height: PREVIEW_MINHEIGHT)
}()

//渲染窗口默认大小
let PREVIEW_DEFAULTSIZE: CGSize! = {
    let defaltWidth = PREVIEW_MAXSIZE.width * 1/4
    let defaultHeight = PREVIEW_MAXSIZE.height * 1/4
    return CGSize(width: defaltWidth, height: defaultHeight)
}()
