//
//  EntryView.swift
//  API List
//
//  Created by Owen Johnson on 2/22/23.
//

import SwiftUI

struct EntryView: View {
    @State private var entries = [Entry]()
    @State private var showingAlert = false
    let category: String
    var body: some View {
        List(entries) { entry in
            VStack(alignment: .leading) {
                Link(destination: URL(string: entry.link)!) {
                    Text(entry.title)
                }
                Text(entry.description)
            }
            .navigationTitle(category)
        }
        .task {
            await getEntries()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Loading Error"),
                  message: Text("There was a problem loading the API entries."),
                  dismissButton: .default(Text("OK")))
        }
    }
    func getEntries() async {
        let category = category.components(separatedBy: " ").first!
        let query = "https://api.publicapis.org/entries?category=\(category)"
        if let url = URL(string: query) {
            if let (data, _) = try? await URLSession.shared.data(from: url) {
                if let decodedResponse = try? JSONDecoder().decode(Entries.self, from: data) {
                    entries = decodedResponse.entries
                    return
                }
            }
        }
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        EntryView(category: "Test")
    }
}

struct Entry: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var link: String
    
    enum CodingKeys : String, CodingKey {
        case title = "API"
        case description = "Description"
        case link = "Link"
    }
}
struct Entries: Codable {
    var entries: [Entry]
}

