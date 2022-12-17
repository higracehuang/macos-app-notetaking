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
    sortDescriptors: [NSSortDescriptor(keyPath: \NoteEntry.createdAt, ascending: true)],
    animation: .default)
  private var noteEntries: FetchedResults<NoteEntry>
  
  var body: some View {
    NavigationView {
      List {
        ForEach(noteEntries) { noteEntry in
          NoteEntryView(noteEntry: noteEntry)
        }
      }
      .toolbar {
        ToolbarItem {
          Button(action: PersistenceController.shared.addNoteEntry) {
            Label("Add Note", systemImage: "plus")
          }
        }
      }
      Text("Select a note")
    }
  }
}

struct NoteEntryView: View {
  @ObservedObject var noteEntry: NoteEntry
  
  @State private var titleInput: String = ""
  @State private var contentInput: String = ""
  
  @State private var shouldShowDeleteButton: Bool = false
  @State private var shouldPresentConfirm: Bool = false
  
  var body: some View {
    if let title = noteEntry.title,
       let updatedAt = noteEntry.updatedAt,
       let content = noteEntry.content {
      NavigationLink {
        VStack {
          TextField("Title", text: $titleInput)
            .onAppear() {
              self.titleInput = title
            }
            .onChange(of: titleInput) { newTitle in
              PersistenceController.shared.updateNoteEntry(
                noteEntry: noteEntry,
                title: newTitle,
                content: contentInput)
            }
          
          TextEditor(text: $contentInput)
            .onAppear() {
              self.contentInput = content
            }
            .onChange(of: contentInput) { newContent in
              PersistenceController.shared.updateNoteEntry(
                noteEntry: noteEntry,
                title: titleInput,
                content: newContent)
            }
        }
        
      } label: {
        HStack {
          Text(title)
          Text(updatedAt, formatter: itemFormatter)
          Spacer()
          if shouldShowDeleteButton || shouldPresentConfirm {
            Button {
              shouldPresentConfirm = true
            } label: {
              Image(systemName: "minus.circle")
            }.buttonStyle(.plain)
              .confirmationDialog("delete_question",
                                  isPresented: $shouldPresentConfirm) {
                Button("delete_confirm", role: .destructive) {
                  PersistenceController.shared.deleteNoteEntry(
                    noteEntry: noteEntry)
                }
              }
          }
        }.onHover { isHover in
          shouldShowDeleteButton = isHover
        }
        
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
    ContentView().environment(
      \.managedObjectContext,
       PersistenceController.preview.container.viewContext)
  }
}
