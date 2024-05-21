//
//  AcknowledgementsView.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/15.
//

import SwiftUI

struct AcknowledgementsView: View {
    @Environment(\.openURL) private var openURL
    
    @State var presentingReasonForPackage: String?
    
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
            link: URL(string: "https://github.com/sindresorhus/Defaults")!,
            reason: "This is a reason."
        ),
        .init(
            name: "FullDiskAccess", 
            author: .init(name: "Mahdi Bchatnia", slug: "inket", link: URL(string: "https://github.com/inket")),
            link: URL(string: "https://github.com/inket/FullDiskAccess")!
        )
    ]
    
    @ViewBuilder
    func name(author: Package.Author) -> some View {
        Text(author.name)
        
        if let slug = author.slug {
            Text(slug)
                .foregroundStyle(.placeholder)
                .monospaced()
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(AcknowledgementsView.packages, id: \.name) { package in
                HStack {
                    @State var isReasonPresented = false
                    
                    VStack {
                        withCaption(spacing: 0) {
                            Text(package.name)
                                .font(.title3)
                        } caption: {
                            if let link = package.author.link {
                                Button {
                                    openURL(link)
                                } label: {
                                    name(author: package.author)
                                    Image(systemSymbol: .arrowUpRight)
                                        .foregroundStyle(.placeholder)
                                }
                                .buttonStyle(.plain)
                            } else {
                                name(author: package.author)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Group {
                        if let reason = package.reason {
                            Button {
                                presentingReasonForPackage = package.name
                            } label: {
                                Image(systemSymbol: .infoCircleFill)
                            }
                            .aspectRatio(1, contentMode: .fit)
                            .popover(isPresented: .init {
                                presentingReasonForPackage == package.name
                            } set: { _ in
                                presentingReasonForPackage = nil
                            }) {
                                Text(reason)
                                    .padding()
                            }
                        }
                        
                        Button {
                            openURL(package.link)
                        } label: {
                            Image(systemSymbol: .safariFill)
                        }
                        .aspectRatio(1, contentMode: .fit)
                    }
                    .imageScale(.large)
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}

#Preview {
    AcknowledgementsView()
}
