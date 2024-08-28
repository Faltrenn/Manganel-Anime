//
//  SearchMediaView.swift
//  Animang
//
//  Created by Emanuel on 20/08/24.
//

import SwiftUI
import SwiftSoup

struct Media {
    let link: String
    let title: String
    let imageLink: String
}

struct MediaSearchSelector {
    let elements: String
    let title: String
    let link: String
    let imageLink: String
}

struct MediaCard<VM: ViewModel>: View {
    @EnvironmentObject var vm: VM
    let media: Media
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: media.imageLink)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            Text(media.title)
        }
        .overlay {
            Button("Adicionar") {
                vm.addMedia(media: media)
            }
        }
    }
}

protocol ViewModel: ObservableObject {
    func addMedia(media: Media)
    func removeMedia(media: Media)
}

struct SearchMediaView<VM: ViewModel>: View {
    @State var search = "a"
    @State var medias: [Media] = []
    let selector: MediaSearchSelector
    @EnvironmentObject var vm: VM
    
    var body: some View {
        VStack {
            HStack {
                TextField("Pesquise pelo nome", text: $search)
                Button("Pesquisar") {
                    searchMedia(search: search)
                }
            }
            ScrollView {
                ForEach(medias, id: \.link) { media in
                    MediaCard<VM>(media: media)
                }
            }
        }
    }
    
    func searchMedia(search: String) {
        medias = []
        if let url = URL(string: "https://leitordemanga.com/?s=\(search.searchFormat)&post_type=wp-manga") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if error == nil, let data = data, let html = String(data: data, encoding: .utf8) {
                    do {
                        let parse = try SwiftSoup.parse(html)
                        let elements = try parse.select(selector.elements)
                        for element in elements {
                            let link = try element.select(selector.link).attr("href")
                            let imageLink = try element.select(selector.imageLink).attr("src")
                            let title = try element.select(selector.title).text()
                            DispatchQueue.main.async {
                                self.medias.append(Media(link: link, title: title, imageLink: imageLink))
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

#Preview {
    SearchMediaView<MangaHomeViewModel>(selector: MediaSearchSelector(elements: "div[class=post bar hentry]", title: "h2[class=post-title entry-title]", link: "a", imageLink: "img"))
        .environmentObject(MangaHomeViewModel())
        .padding()
}
