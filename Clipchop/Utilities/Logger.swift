//
//  Logger.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/25.
//

func log<Subject>(
    _ subject: Subject? = nil,
    _ items: Any..., separator: String = " ", terminator: String = "\n"
) {
    if let subject {
        print(String(describing: type(of: subject)), terminator: " - ")
    }
    print(items, separator: separator, terminator: terminator)
}
