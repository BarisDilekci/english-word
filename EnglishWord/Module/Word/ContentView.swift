import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = WordViewModel()
    @State private var favoriteWords: Set<Int> = Set()
    @State private var filterOption: FilterOption = .all
    @State private var searchText = ""

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    enum FilterOption {
        case all, favorites
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    filterButton(title: "Tümü", option: .all)
                    Spacer()
                    filterButton(title: "Favoriler", option: .favorites)
                    Spacer()
                    filterButton(title: "Benim Eklediklerim", option: .all)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                List(filteredWords) { word in
                    HStack {
                        Text(word.tr)
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()

                        Text(word.eng)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)

                        Spacer()

                        Button(action: {
                            toggleFavorite(id: word.id)
                        }) {
                            Image(systemName: favoriteWords.contains(word.id) ? "heart.fill" : "heart")
                                .font(.title3)
                                .foregroundColor(favoriteWords.contains(word.id) ? .red : .gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .navigationTitle("Words")
                .navigationBarItems(trailing: addButton)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always)) // Searchable feature added
            }
            .onAppear(perform: loadFavorites)
        }
    }

    private var filteredWords: [WordModels] {
        var words = viewModel.words

        if !searchText.isEmpty {
            words = words.filter { $0.tr.localizedCaseInsensitiveContains(searchText) || $0.eng.localizedCaseInsensitiveContains(searchText) }
        }

        switch filterOption {
        case .all:
            return words
        case .favorites:
            return words.filter { favoriteWords.contains($0.id) }
        }
    }
    
    private var addButton: some View {
        Button(action: {
            print("add clicked")
        }) {
            Image(systemName: "plus")
        }
    }

    private func filterButton(title: String, option: FilterOption) -> some View {
        Button(action: {
            filterOption = option
        }) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(filterOption == option ? .blue : .gray)
                .padding()
                .background(Color.gray.opacity(0.2))
                .frame(minWidth: 20, maxHeight: 30)
                .cornerRadius(18)
        }
        .shadow(radius: filterOption == option ? 3 : 0)
        .animation(.easeInOut, value: filterOption)
    }

    private func toggleFavorite(id: Int) {
        withAnimation {
            if let existingItem = items.first(where: { $0.id == Int16(id) }) {
                existingItem.isFavorite.toggle()
            } else {
                let newItem = Item(context: viewContext)
                newItem.timestamp = Date()
                newItem.id = Int16(id)
                newItem.isFavorite = true
            }
            
            do {
                try viewContext.save()
                loadFavorites()
            } catch {
                let nsError = error as NSError
                fatalError("Çözülemeyen hata: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func loadFavorites() {
        favoriteWords = Set(items.filter { $0.isFavorite }.map { Int($0.id) })
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

