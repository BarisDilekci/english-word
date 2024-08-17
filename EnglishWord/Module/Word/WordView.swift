import SwiftUI

struct WordView: View {
    // MARK: - Properties
    @StateObject private var viewModel: WordViewModel


    @State private var showAddView = false
    
    init(coreDataManager: WordManaging = WordDataManager.shared) {
            _viewModel = StateObject(wrappedValue: WordViewModel(coreDataManager: coreDataManager))
        }
    
    // MARK: - LIFECYCLE
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.filteredWords) { word in
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
                            
                            if viewModel.filterOption == .all {
                                Button(action: {
                                    viewModel.toggleFavorite(id: word.id)
                                }) {
                                    Image(systemName: viewModel.favoriteWords.contains(word.id) ? "heart.fill" : "heart")
                                        .font(.title3)
                                        .foregroundColor(viewModel.favoriteWords.contains(word.id) ? .red : .gray)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .navigationTitle("Words")
                .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewModel.filterOption = viewModel.filterOption == .all ? .favorites : .all
                        }) {
                            Image(systemName: viewModel.filterOption == .all ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                                .font(.title3)
                                .foregroundColor(viewModel.filterOption == .all ? .gray : .yellow)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.loadWords()
                viewModel.loadFavoriteWords()
            }
        }
    }
}

