//
//  AcknowledgementsView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/15.
//

import SwiftUI

struct AcknowledgementsView: View {
    @Environment(\.openURL) private var openURL
    
    struct Package {
        var name: String
        var author: Author
        var link: URL
        var reason: String?
        
        struct Author {
            var name: String
            var slug: String?
            var link: URL?
        }
    }
    
    // TODO: Complete this
    static let packages: [Package] = [
        .init(
            name: "Defaults",
            author: .init(name: "Sindre Sorhus", slug: "sindresorhus", link: URL(string: "https://sindresorhus.com/apps")),
            link: URL(string: "https://github.com/sindresorhus/Defaults")!
        ),
        .init(
            name: "FilePreviews", 
            author: .init(name: "Neetesh Gupta", slug: "ntsh", link: URL(string: "https://github.com/ntsh")),
            link: URL(string: "https://github.com/ntsh/FilePreviews")!
        ),
        .init(
            name: "FullDiskAccess", 
            author: .init(name: "Mahdi Bchatnia", slug: "inket", link: URL(string: "https://github.com/inket")),
            link: URL(string: "https://github.com/inket/FullDiskAccess")!
        )
    ]
    
    var body: some View {
        VStack {
            ForEach(AcknowledgementsView.packages, id: \.name) { package in
                HStack(alignment: .center) {
                    @State var isReasonPresented = false
                    
                    VStack {
                        withCaption {
                            Text(package.name)
                                .font(.title3)
                        } caption: {
                            Text(package.author.name)
                        }
                    }
                    
                    if let reason = package.reason {
                        Button {
                            isReasonPresented = true
                        } label: {
                            Image(systemSymbol: .infoCircleFill)
                        }
                        .buttonBorderShape(.circle)
                        .foregroundStyle(.secondary)
                        .aspectRatio(1, contentMode: .fit)
                        .popover(isPresented: $isReasonPresented) {
                            Text(reason)
                                .padding()
                        }
                    }
                    
                    Button {
                        openURL(package.link)
                    } label: {
                        Image(systemSymbol: .safariFill)
                    }
                    .buttonBorderShape(.circle)
                    .foregroundStyle(.secondary)
                    .aspectRatio(1, contentMode: .fit)
                }
                .padding()
            }
        }
    }
}

#Preview {
    AcknowledgementsView()
}
