//
//  MangaView.swift
//  Animang
//
//  Created by Emanuel on 02/08/24.
//

import SwiftUI
import SwiftSoup

struct ChapterCard: View {
    let title: String
    var body: some View {
        Text(title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 11/255, green: 11/255, blue: 15/255))
            .clipShape(RoundedRectangle(cornerRadius: 15.0))
            .tint(.primary)
    }
}

struct MangaView: View {
    let mangaLink: String
    @State var mangaTitle: String = ""
    @State var mangaImage: String = ""
    @State var mangaDescription: String = ""
    @State var mangaChapters: [Chapter] = []
    @State var rotated = false
    
    var body: some View {
        ScrollView {
            VStack {
                Text(mangaTitle)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                AsyncImage(url: URL(string: mangaImage)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                } placeholder: {
                    RoundedRectangle(cornerRadius: 25.0)
                        .fill(Color(red: 31/255, green: 31/255, blue: 36/255))
                        .aspectRatio(425/615, contentMode: .fill)
                        .overlay {
                            ProgressView()
                        }
                }
                VStack {
                    Text(mangaDescription)
                }
                .padding()
                .background(Color(red: 31/255, green: 31/255, blue: 36/255))
                .clipShape(RoundedRectangle(cornerRadius: 25.0))
                
                HStack {
                    Text("ÚLTIMOS CAPÍTULOS LANÇADOS")
                    Image(systemName: "arrow.up.arrow.down")
                        .rotationEffect(.degrees(rotated ? 180 : 0))
                        .onTapGesture {
                            withAnimation(.linear(duration: 0.15)) {
                                rotated.toggle()
                            }
                        }
                }
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 21/255, green: 22/255, blue: 29/255))
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))

                ForEach(mangaChapters, id: \.link) { chapter in
                    NavigationLink {
                        ChapterView(chapterLink: chapter.link)
                    } label: {
                        ChapterCard(title: chapter.title)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            if let url = URL(string: mangaLink) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if error == nil, let data = data, let html = String(data: data, encoding: .utf8) {
                        do {
                            let parse = try SwiftSoup.parse(html)
                            let title = try parse.select("div[class=post-title]").first()?.text() ?? ""
                            let image = try parse.select("div[class=summary_image] a img").first()?.attr("src") ?? ""
                            let description = try parse.select("div[class=manga-excerpt]").first()?.text() ?? ""
                            let elements = try parse.select("li[class=wp-manga-chapter] a")
                            var chapters: [Chapter] = []
                            for element in elements {
                                try chapters.append(Chapter(title: element.text(), link: element.attr("href")))
                            }
                            DispatchQueue.main.async {
                                mangaTitle = title
                                mangaImage = image
                                mangaDescription = description
                                mangaChapters = chapters
                            }
                        } catch {
                            print("ERROR: ", error)
                        }
                    }
                }
                .resume()
            }
        }
    }
}

#Preview {
    NavigationStack {
        MangaView(mangaLink: "https://lermangas.me/manga/o-cacador-de-destinos-rank-f/")        
    }
}
