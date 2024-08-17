import SwiftUI
import CoreData

struct WordView: View {
    // MARK: - Core Data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - Properties
    @StateObject private var viewModel = WordViewModel()
    @State private var favoriteWords: Set<Int> = Set()
    @State private var filterOption: FilterOption = .all
    @State private var searchText = ""
    @State private var showAddView = false
    
    enum FilterOption {
        case all, favorites
    }
    
    // MARK: - LIFECYCLE
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(filteredWords) { word in
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
                            
                            if filterOption == .all {
                                Button(action: {
                                    toggleFavorite(id: word.id)
                                }) {
                                    Image(systemName: favoriteWords.contains(word.id) ? "heart.fill" : "heart")
                                        .font(.title3)
                                        .foregroundColor(favoriteWords.contains(word.id) ? .red : .gray)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .sheet(isPresented: $showAddView) {
                    AddView()
                        .environment(\.managedObjectContext, viewContext)
                }
                .navigationTitle("Words")
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            filterOption = filterOption == .all ? .favorites : .all
                        }) {
                            Image(systemName: filterOption == .all ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                                .font(.title3)
                                .foregroundColor(filterOption == .all ? .gray : .yellow)
                        }
                    }
                }
            }
            .onAppear(perform: loadFavorites)
        }
    }
    
    // MARK: - Functions
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
    
    private func loadFavorites() {
        favoriteWords = Set(items.filter { $0.isFavorite }.map { Int($0.id) })
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
}

