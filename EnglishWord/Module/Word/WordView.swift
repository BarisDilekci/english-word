import SwiftUI
import CoreData

struct WordView: View {
    
    // MARK: - Core Data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \NewWord.eng, ascending: true)],
        animation: .default)
    private var newWords: FetchedResults<NewWord>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - Properties
    @StateObject private var viewModel = WordViewModel()
    @State private var favoriteWords: Set<Int> = Set()
    @State private var filterOption: FilterOption = .all
    @State private var searchText = ""
    @State private var showAddView = false
    
    enum FilterOption {
        case all, favorites, myAdd
    }
    
    // MARK: - LIFECYCLE
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    filterButton(title: "Tümü", option: .all)
                    Spacer()
                    filterButton(title: "Favoriler", option: .favorites)
                    Spacer()
                    filterButton(title: "Benim Eklediklerim", option: .myAdd)
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
                        
                        if filterOption != .myAdd {
                            Button(action: {
                                toggleFavorite(id: Int(word.id ?? UUID().uuidString.hashValue))
                            }) {
                                Image(systemName: favoriteWords.contains(Int(word.id ?? UUID().uuidString.hashValue)) ? "heart.fill" : "heart")
                                    .font(.title3)
                                    .foregroundColor(favoriteWords.contains(Int(word.id ?? UUID().uuidString.hashValue)) ? .red : .gray)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .sheet(isPresented: $showAddView) {
                    AddView()
                        .environment(\.managedObjectContext, viewContext)
                }
                .navigationTitle("Words")
                .navigationBarItems(trailing: addButton)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
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
        case .myAdd:
            let newWordsArray = newWords.map { WordModels(id: Int($0.id?.hashValue ?? 0), categoryId: 3, eng: $0.eng ?? "", tr: $0.tr ?? "") }
            return newWordsArray
        }
    }
    
    private func loadFavorites() {
        favoriteWords = Set(items.filter { $0.isFavorite }.map { Int($0.id) })
    }
    
    // MARK: - Buttons
    private var addButton: some View {
        Button(action: {
            showAddView = true // Show the sheet
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
}

#Preview {
    WordView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

