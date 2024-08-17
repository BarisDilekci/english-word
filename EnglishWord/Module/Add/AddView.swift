//
//  AddView.swift
//  EnglishWord
//
//  Created by Barış Dilekçi on 12.08.2024.
import SwiftUI
import CoreData

struct AddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @State private var eng: String = ""
    @State private var tr: String = ""
    @State private var alertItem: AlertItem?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add New Word").font(.headline)) {
                    TextField("Enter English", text: $eng)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Enter Turkish", text: $tr)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button(action: saveItem) {
                    Text("Save")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .navigationTitle("Add Word")
            .alert(item: $alertItem) { item in
                Alert(
                    title: Text("Result"),
                    message: Text(item.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func saveItem() {
        guard !eng.isEmpty, !tr.isEmpty else {
            alertItem = AlertItem(id: UUID(), message: "Please enter both English and Turkish words.")
            return
        }
        
        let newItem = NewWord(context: viewContext)
        newItem.id = UUID()
        newItem.eng = eng
        newItem.tr = tr
        
        do {
            try viewContext.save()
            alertItem = AlertItem(id: UUID(), message: "Word successfully saved.")
            eng = ""
            tr = ""
            dismiss()
            
        } catch {
            alertItem = AlertItem(id: UUID(), message: "Failed to save item: \(error.localizedDescription)")
        }
    }
    private func deleteNewWord(_ newWord: NewWord) {
          viewContext.delete(newWord)
          do {
              try viewContext.save()
          } catch {
              let nsError = error as NSError
              fatalError("Çözülemeyen hata: \(nsError), \(nsError.userInfo)")
          }
      }
}

struct AlertItem: Identifiable {
    let id: UUID
    let message: String
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(radius: 5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}

#Preview {
    AddView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
