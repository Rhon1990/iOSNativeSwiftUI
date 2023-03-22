//
//  ContentView.swift
//  Zara
//
//  Created by Rhonal Delgado on 27/02/23.
//

import SwiftUI

import SwiftUI

struct Character: Codable, Identifiable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let image: String
}

class CharactersViewModel: ObservableObject {
    @Published var characters = [Character]()
   
    func fetchCharacters() {
        guard let url = URL(string: "https://rickandmortyapi.com/api/character") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)
                DispatchQueue.main.async {
                    self.characters = response.results
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
}

struct ContentView: View {
    @StateObject var viewModel = CharactersViewModel()
   
    var body: some View {
        NavigationView {
            List(viewModel.characters) { character in
                NavigationLink(destination: CharacterDetailView(character: character)) {
                    HStack {
                        Image(uiImage: character.image.load())
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text(character.name)
                    }
                }
            }
            .navigationTitle("Caracteristicas")
            .onAppear {
                viewModel.fetchCharacters()
            }
        }
    }
}

struct CharacterDetailView: View {
    let character: Character
   
    var body: some View {
        VStack {
            Image(uiImage: character.image.load())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            Text(character.name)
                .font(.title)
                .padding()
            Text("Status: \(character.status)")
            Text("Species: \(character.species)")
        }
    }
}

struct Response: Codable {
    let results: [Character]
}

extension String {
    func load() -> UIImage {
        do {
            guard let url = URL(string: self) else { return UIImage() }
            let data: Data = try Data(contentsOf: url)
            return UIImage(data: data) ?? UIImage()
        } catch {
            return UIImage()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
