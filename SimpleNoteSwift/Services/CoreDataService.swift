//
//  CoreDataService.swift
//  SimpleNoteSwift
//
//  Created by Mehran Bakhtiari on 9/13/25.
//

import Foundation
import CoreData
import Combine

// MARK: - Core Data Service
class CoreDataService: ObservableObject {
    static let shared = CoreDataService()
    
    private let persistenceController = PersistenceController.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Note Operations
    func saveNote(_ note: APINote, userId: Int, isSynced: Bool = true) {
        let context = persistenceController.container.viewContext
        
        // Check if note already exists
        let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", note.id)
        
        do {
            let existingNotes = try context.fetch(fetchRequest)
            let noteEntity: NoteEntity
            
            if let existingNote = existingNotes.first {
                noteEntity = existingNote
            } else {
                noteEntity = NoteEntity(context: context)
                noteEntity.id = Int32(note.id)
            }
            
            noteEntity.title = note.title
            noteEntity.content = note.description
            noteEntity.createdAt = parseDate(note.createdAt)
            noteEntity.updatedAt = parseDate(note.updatedAt)
            noteEntity.creatorName = note.creatorName
            noteEntity.creatorUsername = note.creatorUsername
            noteEntity.userId = Int32(userId)
            noteEntity.isSynced = isSynced
            noteEntity.isModified = false
            noteEntity.lastModifiedLocal = Date()
            noteEntity.isLocalOnly = false
            
            try context.save()
        } catch {
        }
    }
    
    func createLocalNote(title: String, content: String, userId: Int) -> NoteEntity {
        let context = persistenceController.container.viewContext
        let noteEntity = NoteEntity(context: context)
        
        noteEntity.id = Int32.random(in: 1000000...9999999) // Temporary local ID
        noteEntity.title = title
        noteEntity.content = content
        noteEntity.createdAt = Date()
        noteEntity.updatedAt = Date()
        noteEntity.creatorName = "Local User"
        noteEntity.creatorUsername = "local"
        noteEntity.userId = Int32(userId)
        noteEntity.isSynced = false
        noteEntity.isModified = true
        noteEntity.lastModifiedLocal = Date()
        noteEntity.isLocalOnly = true
        
        do {
            try context.save()
        } catch {
        }
        
        return noteEntity
    }
    
    func updateNote(id: Int32, title: String, content: String) {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let notes = try context.fetch(fetchRequest)
            if let note = notes.first {
                note.title = title
                note.content = content
                note.updatedAt = Date()
                note.isModified = true
                note.lastModifiedLocal = Date()
                
                try context.save()
            }
        } catch {
        }
    }
    
    func deleteNote(id: Int32) {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let notes = try context.fetch(fetchRequest)
            if let note = notes.first {
                context.delete(note)
                try context.save()
            }
        } catch {
        }
    }
    
    func getNotes(userId: Int, searchText: String? = nil) -> [NoteEntity] {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        
        var predicates = [NSPredicate(format: "userId == %d", userId)]
        
        if let searchText = searchText, !searchText.isEmpty {
            let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@ OR content CONTAINS[cd] %@", searchText, searchText)
            predicates.append(searchPredicate)
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \NoteEntity.updatedAt, ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    func getUnsyncedNotes() -> [NoteEntity] {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isSynced == NO OR isModified == YES")
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    func markNoteAsSynced(id: Int32) {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let notes = try context.fetch(fetchRequest)
            if let note = notes.first {
                note.isSynced = true
                note.isModified = false
                try context.save()
            }
        } catch {
        }
    }
    
    // MARK: - User Operations
    func saveUser(_ user: APIUser) {
        let context = persistenceController.container.viewContext
        
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", user.id)
        
        do {
            let existingUsers = try context.fetch(fetchRequest)
            let userEntity: UserEntity
            
            if let existingUser = existingUsers.first {
                userEntity = existingUser
            } else {
                userEntity = UserEntity(context: context)
                userEntity.id = Int32(user.id)
            }
            
            userEntity.username = user.username
            userEntity.email = user.email
            userEntity.fullName = user.fullName
            userEntity.createdAt = Date() // API doesn't return created_at for user
            
            try context.save()
        } catch {
        }
    }
    
    func getCurrentUser() -> UserEntity? {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            return nil
        }
    }
    
    // MARK: - Helper Methods
    private func parseDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        // Fallback format
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter.date(from: dateString) ?? Date()
    }
}