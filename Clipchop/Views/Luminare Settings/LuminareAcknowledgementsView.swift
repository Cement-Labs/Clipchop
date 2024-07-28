//
//  LuminareAcknowledgementsView.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/28.
//

import SwiftUI
import Luminare

struct LuminareAcknowledgementsView: View {
    @Environment(\.openURL) private var openURL
    
    @State private var presentedReasonPackage: String?
    
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
        ),
        .init(
            name: "Luminare",
            author: .init(name: "MrKai77 ", slug: "Kai", link: URL(string: "https://github.com/MrKai77")),
            link: URL(string: "https://github.com/MrKai77/Luminare")!
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
        ForEach(LuminareAcknowledgementsView.packages, id: \.name) { package in
            VStack {
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
                                presentedReasonPackage = package.name
                            } label: {
                                Image(systemSymbol: .infoCircleFill)
                            }
                            .aspectRatio(1, contentMode: .fit)
                            .popover(isPresented: .init {
                                presentedReasonPackage == package.name
                            } set: { _ in
                                presentedReasonPackage = nil
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
                .padding(.horizontal, 8)
                .padding(.trailing, 2)
                .frame(minHeight: 42)
            }
        }
    }
}
