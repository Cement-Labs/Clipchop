//
//  getCursorPosition.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/19.
//

import Foundation
import ApplicationServices
import Accessibility
import Carbon
import AppKit

func getFrontmostAppPID() -> pid_t? {
    guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
        return nil
    }
    return frontmostApp.processIdentifier
}

func getIMECursorPosition() -> CGPoint? {
    guard let frontmostAppPID = getFrontmostAppPID() else {
        print("Failed to get frontmost app PID")
        return nil
    }
    
    let app = AXUIElementCreateApplication(frontmostAppPID)
    var focusedElement: CFTypeRef?
    let result = AXUIElementCopyAttributeValue(app, kAXFocusedUIElementAttribute as CFString, &focusedElement)
    
    if result != .success {
        print("Failed to get focused element, result: \(result)")
        return nil
    }
    
    guard let focusedElement = focusedElement else {
        print("Focused element is nil")
        return nil
    }
    
    var rangeValue: CFTypeRef?
    let rangeResult = AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXSelectedTextRangeAttribute as CFString, &rangeValue)
    
    if rangeResult != .success {
        print("Failed to get selected text range, result: \(rangeResult)")
        return nil
    }
    
    guard let rangeValue = rangeValue else {
        print("Selected text range is nil")
        return nil
    }
    
    var range = CFRange()
    if !AXValueGetValue(rangeValue as! AXValue, .cfRange, &range) {
        print("Failed to convert AXValue to CFRange")
        return nil
    }
    
    var boundsValue: CFTypeRef?
    let boundsResult = AXUIElementCopyParameterizedAttributeValue(focusedElement as! AXUIElement, kAXBoundsForRangeParameterizedAttribute as CFString, rangeValue, &boundsValue)
    
    if boundsResult != .success {
        print("Failed to get bounds for range, result: \(boundsResult)")
        return nil
    }
    
    guard let boundsValue = boundsValue else {
        print("Bounds value is nil")
        return nil
    }
    
    var rect = CGRect()
    if !AXValueGetValue(boundsValue as! AXValue, .cgRect, &rect) {
        print("Failed to convert AXValue to CGRect")
        return nil
    }
    
    return rect.origin
}

func convertScreenToGlobalCoordinates(screenPoint: CGPoint) -> CGPoint {
    let screenHeight = NSScreen.main?.frame.height ?? 0
    let convertedY = screenHeight - screenPoint.y
    return CGPoint(x: screenPoint.x, y: convertedY)
}

func getGlobalCursorPosition() -> CGPoint {
    if let screenCursorPosition = getIMECursorPosition() {
        return convertScreenToGlobalCoordinates(screenPoint: screenCursorPosition)
    } else {
        return NSEvent.mouseLocation
    }
}
