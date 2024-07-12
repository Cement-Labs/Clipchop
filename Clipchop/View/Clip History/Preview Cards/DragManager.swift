//
//  DragManager.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/5/23.
//

import Foundation
import Defaults
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
            print("Failed to convert data to string with UTF-8 encoding.")
            return nil
        }
        print("type is \(String(describing: content.type))")
        return NSItemProvider(item: nsData as NSSecureCoding, typeIdentifier: content.type)
        
    case
        UTType.html.identifier:
        guard let data = data as? Data else {
            print("Data is not of type Data.")
            return nil
        }
        
        guard let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) else {
            print("Failed to convert HTML to NSAttributedString.")
            return nil
        }
        
        let plainText = attributedString.string
        guard let plainTextData = plainText.data(using: .utf8) else {
            print("Failed to convert plain text to data.")
            return nil
        }
        
        if Defaults[.removeFormatting] {
            print("type is \(String(describing: content.type))")
            return NSItemProvider(item: plainTextData as NSSecureCoding, typeIdentifier: UTType.text.identifier)
        } else {
            let itemProvider = NSItemProvider()
            itemProvider.registerDataRepresentation(forTypeIdentifier: UTType.html.identifier, visibility: .all) { completion in
                completion(data, nil)
                return nil
            }
            itemProvider.registerDataRepresentation(forTypeIdentifier: UTType.plainText.identifier, visibility: .all) { completion in
                completion(plainTextData, nil)
                return nil
            }
            print("type is \(String(describing: content.type))")
            return itemProvider
        }
        
    case
        UTType.rtf.identifier:
        guard let data = data as? Data else {
            print("Data is not of type Data.")
            return nil
        }
        
        guard let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil) else {
            print("Failed to convert RTF to NSAttributedString.")
            return nil
        }
        
        let plainText = attributedString.string
        guard let plainTextData = plainText.data(using: .utf8) else {
            print("Failed to convert plain text to data.")
            return nil
        }
        
        if Defaults[.removeFormatting] {
            print("type is \(String(describing: content.type))")
            return NSItemProvider(item: plainTextData as NSSecureCoding, typeIdentifier: UTType.text.identifier)
        } else {
            let itemProvider = NSItemProvider()
            itemProvider.registerDataRepresentation(forTypeIdentifier: UTType.rtf.identifier, visibility: .all) { completion in
                completion(data, nil)
                return nil
            }
            itemProvider.registerDataRepresentation(forTypeIdentifier: UTType.plainText.identifier, visibility: .all) { completion in
                completion(plainTextData, nil)
                return nil
            }
            print("type is \(String(describing: content.type))")
            return itemProvider
        }
        
    case
        UTType.fileURL.identifier,UTType.folder.identifier, UTType.package.identifier, UTType.zip.identifier,
        
        UTType.jpeg.identifier, UTType.png.identifier, UTType.gif.identifier, UTType.tiff.identifier,
        UTType.heic.identifier, UTType.aiff.identifier, UTType.heif.identifier, UTType.rawImage.identifier,
        UTType.icns.identifier, UTType.ico.identifier,
        
        UTType.pdf.identifier, UTType.mpeg4Movie.identifier,UTType.quickTimeMovie.identifier, UTType.mpeg.identifier, UTType.video.identifier,
        UTType.avi.identifier, UTType.mp3.identifier, UTType.audio.identifier, UTType.wav.identifier, UTType.mpeg4Audio.identifier,
        UTType.mpeg2Video.identifier, UTType.appleProtectedMPEG4Audio.identifier, UTType.appleProtectedMPEG4Video.identifier,
        UTType.application.identifier, UTType.calendarEvent.identifier, UTType.bookmark.identifier,
        
        UTType.json.identifier, UTType.content.identifier, UTType.contact.identifier,
        
        UTType.usd.identifier, UTType.usdz.identifier:
        
        print("type is \(String(describing: content.type))")
        return NSItemProvider(item: data, typeIdentifier: content.type)
        
    default:
        print("Unsupported content type for dragging: \(String(describing: content.type))")
        return NSItemProvider(item: data, typeIdentifier: UTType.data.identifier)
    }
}
