//
//  NotesViewModel.swift
//  SimpleNoteSwift
//
//  Created by Mehran Bakhtiari on 9/13/25.
//

import Foundation
import CoreData
import Combine

// MARK: - Notes ViewModel
class NotesViewModel: ObservableObject {
    @Published var notes: [NoteEntity] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: UserEntity?
    
    private let apiService: APIServiceProtocol
    private let coreDataService = CoreDataService.shared
    private let tokenManager = TokenManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    private let pageSize = 20
    
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
        self.currentUser = coreDataService.getCurrentUser()
        
        // Load notes from local storage first
        loadLocalNotes()
        
        // Set up search text observation
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.searchNotes(searchText)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func loadNotes() {
        guard tokenManager.isAuthenticated else {
            loadLocalNotes()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        apiService.getNotes(page: currentPage, search: searchText.isEmpty ? nil : searchText)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                    self?.isLoading = false
                    switch completion {
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        // Fallback to local notes on error
                        self?.loadLocalNotes()
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] (response: PaginatedResponse<APINote>) in
                    self?.handleNotesResponse(response)
                }
            )
            .store(in: &cancellables)
    }
    
    func createNote(title: String, content: String) {
        guard let userId = currentUser?.id else { 
            return 
        }
        
        
        if tokenManager.isAuthenticated {
            createNoteOnServer(title: title, content: content)
        } else {
            createLocalNote(title: title, content: content, userId: Int(userId))
        }
    }
    
    func updateNote(id: Int32, title: String, content: String) {
        coreDataService.updateNote(id: id, title: title, content: content)
        
        if tokenManager.isAuthenticated {
            updateNoteOnServer(id: Int(id), title: title, content: content)
        }
        
        loadLocalNotes()
    }
    
    func deleteNote(id: Int32) {
        coreDataService.deleteNote(id: id)
        
        if tokenManager.isAuthenticated {
            deleteNoteOnServer(id: Int(id))
        } else {
        }
        
        loadLocalNotes()
    }
    
    func refreshNotes() {
        currentPage = 1
        loadNotes()
    }
    
    func loadMoreNotes() {
        guard !isLoading else { return }
        currentPage += 1
        loadNotes()
    }
    
    // MARK: - Private Methods
    private func loadLocalNotes() {
        guard let userId = currentUser?.id else { return }
        notes = coreDataService.getNotes(userId: Int(userId), searchText: searchText.isEmpty ? nil : searchText)
    }
    
    private func searchNotes(_ searchText: String) {
        loadLocalNotes()
        
        if tokenManager.isAuthenticated && !searchText.isEmpty {
            loadNotes()
        }
    }
    
    private func handleNotesResponse(_ response: PaginatedResponse<APINote>) {
        guard let userId = currentUser?.id else { return }
        
        // Save notes to local storage
        for note in response.results {
            coreDataService.saveNote(note, userId: Int(userId))
        }
        
        // Load updated local notes
        loadLocalNotes()
    }
    
    private func createNoteOnServer(title: String, content: String) {
        let request = NoteRequest(title: title, description: content)
        
        apiService.createNote(request: request)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                    switch completion {
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] (note: APINote) in
                    guard let userId = self?.currentUser?.id else { 
                        return 
                    }
                    self?.coreDataService.saveNote(note, userId: Int(userId))
                    self?.loadLocalNotes()
                }
            )
            .store(in: &cancellables)
    }
    
    private func createLocalNote(title: String, content: String, userId: Int) {
        _ = coreDataService.createLocalNote(title: title, content: content, userId: userId)
        loadLocalNotes()
    }
    
    private func updateNoteOnServer(id: Int, title: String, content: String) {
        let request = UpdateNoteRequest(title: title, description: content)
        
        apiService.updateNote(id: id, request: request)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                    switch completion {
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] (note: APINote) in
                    guard let userId = self?.currentUser?.id else { return }
                    self?.coreDataService.saveNote(note, userId: Int(userId))
                    self?.loadLocalNotes()
                }
            )
            .store(in: &cancellables)
    }
    
    private func deleteNoteOnServer(id: Int) {
        apiService.deleteNote(id: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                    switch completion {
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    case .finished:
                        break
                    }
                },
                receiveValue: { _ in
                }
            )
            .store(in: &cancellables)
    }
    
    func logout() {
        TokenManager.shared.clearTokens()
        notes = []
        currentUser = nil
    }
}