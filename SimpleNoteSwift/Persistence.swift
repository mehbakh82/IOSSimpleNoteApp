//
//  Persistence.swift
//  SimpleNoteSwift
//
//  Created by Mehran Bakhtiari on 9/13/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // Create sample data for preview
        let sampleUser = UserEntity(context: viewContext)
        sampleUser.id = 1
        sampleUser.username = "preview_user"
        sampleUser.email = "preview@example.com"
        sampleUser.fullName = "Preview User"
        sampleUser.createdAt = Date()
        
        for i in 0..<5 {
            let newNote = NoteEntity(context: viewContext)
            newNote.id = Int32(i + 1)
            newNote.title = "Sample Note \(i + 1)"
            newNote.content = "This is a sample note content for preview purposes. Note number \(i + 1)."
            newNote.createdAt = Date()
            newNote.updatedAt = Date()
            newNote.creatorName = "Preview User"
            newNote.creatorUsername = "preview_user"
            newNote.userId = 1
            newNote.isSynced = true
            newNote.isModified = false
            newNote.lastModifiedLocal = Date()
            newNote.isLocalOnly = false
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SimpleNoteSwift")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
