//
//  DragManager.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/23.
//

import Foundation
import UniformTypeIdentifiers

func dragManager(for content: ClipboardContent) -> NSItemProvider? {
    guard let data = content.value as? NSSecureCoding else {
        log( "Value is not NSSecureCoding compliant")
        return nil
    }

    switch content.type {
    case
        UTType.plainText.identifier, UTType.text.identifier, UTType.utf8PlainText.identifier, UTType.utf16PlainText.identifier,
        UTType.emailMessage.identifier,
        UTType.utf16ExternalPlainText.identifier,UTType.utf8TabSeparatedText.identifier, UTType.url.identifier:
        
        guard 
            let string = String(data: data as! Data, encoding: .utf8),
            let nsData = string.data(using: .utf8) 
        else {
            log("Failed to convert data to string with UTF-8 encoding.")
            return nil
        }
        
        return NSItemProvider(item: nsData as NSSecureCoding, typeIdentifier: content.type)
        
    case 
        UTType.html.identifier:
        
            guard let data = data as? Data else {
                log("Data is not of type Data.")
                return nil
            }
            
            guard let htmlString = String(data: data, encoding: .utf8) else {
                log("Failed to convert HTML data to string with UTF-8 encoding.")
                return nil
            }
            
            guard let htmlData = htmlString.data(using: .utf8) else {
                log("Failed to convert HTML string back to data with UTF-8 encoding.")
                return nil
            }
            
            return NSItemProvider(item: htmlData as NSSecureCoding, typeIdentifier: UTType.html.identifier)
    
    case
        UTType.fileURL.identifier,UTType.folder.identifier, UTType.package.identifier, UTType.zip.identifier,
        
        UTType.jpeg.identifier, UTType.png.identifier, UTType.gif.identifier, UTType.tiff.identifier, 
        UTType.heic.identifier, UTType.aiff.identifier, UTType.heif.identifier, UTType.rawImage.identifier,
        UTType.icns.identifier, UTType.ico.identifier,
        
        UTType.pdf.identifier, UTType.mpeg4Movie.identifier,UTType.quickTimeMovie.identifier, UTType.mpeg.identifier, UTType.video.identifier,
        UTType.avi.identifier, UTType.mp3.identifier, UTType.audio.identifier, UTType.wav.identifier, UTType.mpeg4Audio.identifier,
        UTType.mpeg2Video.identifier, UTType.appleProtectedMPEG4Audio.identifier, UTType.appleProtectedMPEG4Video.identifier,
        UTType.application.identifier, UTType.calendarEvent.identifier, UTType.bookmark.identifier,
        
        UTType.rtf.identifier, UTType.json.identifier, UTType.content.identifier, UTType.contact.identifier,
        
        UTType.usd.identifier, UTType.usdz.identifier:
        
        log("type is \(String(describing: content.type))")
        return NSItemProvider(item: data, typeIdentifier: content.type)

    default:
        log("Unsupported content type for dragging: \(String(describing: content.type))")
        return NSItemProvider(item: data, typeIdentifier: UTType.data.identifier)
    }
}
