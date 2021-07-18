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
let SCREEN_SIZE: NSRect! = {
    return MAINSCREEN.visibleFrame
} ()

//屏幕宽
let SCREEN_WIDTH: CGFloat! = {
    return SCREEN_SIZE.width
} ()

//屏幕高
let SCREEN_HEIGHT: CGFloat! = {
    return SCREEN_SIZE.height
} ()

//屏幕数量
let SCRREENS: NSArray! = {
    return NSScreen.screens as NSArray
} ()

//渲染视频高宽比
let RENDERRATIO: CGFloat! = 9/16.0
//最大渲染窗口
let RENDER_MAXSIZE: CGSize! = {
    if SCREEN_HEIGHT/SCREEN_WIDTH < RENDERRATIO {
        //如果屏幕高宽比<高宽比，那么以高度为基准
        return CGSize(width: SCREEN_HEIGHT/RENDERRATIO, height: SCREEN_HEIGHT)
    }else {
        //如果屏幕高宽比>高宽比，那么以宽度为基准
        return CGSize(width: SCREEN_WIDTH, height: SCREEN_WIDTH*RENDERRATIO)
    }
} ()

//最小渲染宽度
let RENDER_MINWIDTH: CGFloat! = {
    return 640.0
} ()

//最小渲染高度
let RENDER_MINHEIGHT: CGFloat! = {
    return 480.0
} ()

//最小渲染窗口
let RENDER_MINSIZE: CGSize! = {
 return CGSize(width: RENDER_MINWIDTH, height: RENDER_MINHEIGHT)
}()

//渲染窗口默认大小
let RENDER_DEFAULTSIZE: CGSize! = {
    let defaltWidth = RENDER_MAXSIZE.width * 1/4
    let defaultHeight = RENDER_MAXSIZE.height * 1/4
    return CGSize(width: defaltWidth, height: defaultHeight)
}()

enum InputSourceType: Int {
    case camera = 1
    case screen
    case other
}

