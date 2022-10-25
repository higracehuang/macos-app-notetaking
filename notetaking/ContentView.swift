//
//  ContentView.swift
//  notetaking
//
//  Created by Le Huang on 10/24/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \NoteEntry.updatedAt, ascending: true)],
        animation: .default)
    private var noteEntries: FetchedResults<NoteEntry>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(noteEntries) { noteEntry in
                    if let title = noteEntry.title,
                       let content = noteEntry.content,
                       let updatedAt = noteEntry.updatedAt {
                        NavigationLink {
                            /// Display the note content
                            Text(content)
                        } label: {
                            /// Display the title and update timestamp on the left pane
                            Text(title)
                            Text(updatedAt, formatter: itemFormatter)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: addNoteEntry) {
                        Label("Add Note", systemImage: "plus")
                    }
                }
            }
            Text("Select a note")
        }
    }
    
    private func addNoteEntry() {
        withAnimation {
            let newNoteEntry = NoteEntry(context: viewContext)
            newNoteEntry.createdAt = Date()
            newNoteEntry.updatedAt = Date()
            newNoteEntry.title = "Untitled"
            newNoteEntry.content = "TBD"
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
