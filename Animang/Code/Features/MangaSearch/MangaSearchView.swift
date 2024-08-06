//
//  MangaSearchView.swift
//  Animang
//
//  Created by Emanuel on 04/08/24.
//

import SwiftUI
import SwiftSoup

struct MangaSearchView: View {
    @State var mangas: [Manga] = []
    @State var search: String = "jujutsu"
    @EnvironmentObject var mangaHomeVM: MangaHomeViewModel
    
    var body: some View {
        VStack {
            HStack {
                TextField("opa", text: $search)
                Button("search") {
                    searchManga(search: search)
                }
            }
            .padding()
            List {
                ForEach(mangas, id: \.link) { manga in
                    MangaCard(manga: manga)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .leading) {
                            Button("Adicionar", systemImage: "plus.circle.fill") {
                                mangaHomeVM.addManga(link: manga.link)
                            }
                            .tint(.green)
                        }
                }
            }
            .listStyle(.plain)
        }
        .onAppear {
            searchManga(search: search)
        }
    }
    
    func searchManga(search: String) {
        mangas = []
        if let url = URL(string: "https://lermangas.me/?s=\(search.searchFormat)&post_type=wp-manga") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if error == nil, let data = data, let html = String(data: data, encoding: .utf8) {
                    do {
                        let parse = try SwiftSoup.parse(html)
                        let mangas = try parse.select("div[class=row c-tabs-item__content]")
                        for manga in mangas {
                            let links = try manga.select("div div a")
                            let mangaLink = try links.attr("href")
                            let imageLink = try links.select("img").attr("src")
                            let name = try manga.select("div div h3 a").text()
                            let content = try manga.select("div div div[class=post-content] div div")
                            let altName = try content[1].text()
                            let genres = try content[3].text()
                            let status = try content[5].text()
                            let launch = try content[7].text()
                            DispatchQueue.main.async {
                                self.mangas.append(Manga(name: name, altName: altName, imageLink: imageLink, link: mangaLink, genres: genres, status: status, launch: launch, lastChapter: "none", score: "none"))
                            }
                        }
                    } catch {
                        print("ERROR: ", error)
                    }
                }
            }.resume()
        }
    }
}

extension String {
    var searchFormat: String {
        self.replacingOccurrences(of: " ", with: "+")
    }
}

#Preview {
    MangaSearchView()
        .environmentObject(MangaHomeViewModel())
}
