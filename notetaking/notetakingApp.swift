//
//  notetakingApp.swift
//  notetaking
//
//  Created by Le Huang on 10/24/22.
//

import SwiftUI

@main
struct notetakingApp: App {
  let persistenceController = PersistenceController.shared
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
