//
//  NotesListView.swift
//  SimpleNoteSwift
//
//  Created by Mehran Bakhtiari on 9/13/25.
//

import SwiftUI

struct NotesListView: View {
    @StateObject private var notesViewModel = NotesViewModel()
    @State private var showingAddNote = false
    @State private var selectedNote: NoteEntity?
    @State private var showingDeleteAlert = false
    @State private var noteToDelete: NoteEntity?
    @State private var showingSettings = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Offline Indicator
                    OfflineIndicator()
                        .padding(.top, 8)
                    
                    // Search Bar
                    SearchBar(text: $notesViewModel.searchText)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    
                    // Notes Grid
                    if notesViewModel.notes.isEmpty && !notesViewModel.isLoading {
                        EmptyNotesView {
                            showingAddNote = true
                        }
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(notesViewModel.notes, id: \.id) { note in
                                    NoteCard(
                                        note: note,
                                        onTap: {
                                            selectedNote = note
                                        },
                                        onDelete: {
                                            noteToDelete = note
                                            showingDeleteAlert = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                        }
                    }
                    
                    // Loading Indicator
                    if notesViewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.2)
                            .padding()
                    }
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            showingAddNote = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                        }
                        
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape")
                                .font(.title2)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteView { title, content in
                notesViewModel.createNote(title: title, content: content)
            }
        }
        .sheet(item: $selectedNote) { note in
            EditNoteView(note: note) { title, content in
                notesViewModel.updateNote(id: note.id, title: title, content: content)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .alert("Delete Note", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let note = noteToDelete {
                    notesViewModel.deleteNote(id: note.id)
                }
            }
        } message: {
            Text("Are you sure you want to delete this note? This action cannot be undone.")
        }
        .onAppear {
            notesViewModel.loadNotes()
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search notes...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Note Card
struct NoteCard: View {
    let note: NoteEntity
    let onTap: () -> Void
    let onDelete: () -> Void
    
    private var backgroundColor: Color {
        let colors: [Color] = [
            Color(red: 0.97, green: 0.96, blue: 0.83), // Light yellow
            Color(red: 0.99, green: 0.92, blue: 0.67), // Light orange
            Color(red: 0.97, green: 0.87, blue: 0.89)  // Light pink
        ]
        return colors[abs(Int(note.id)) % colors.count]
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                Text(note.title ?? "")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(note.content ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(8)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                HStack {
                    Text(formatDate(note.updatedAt ?? Date()))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if note.isLocalOnly {
                        Image(systemName: "wifi.slash")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(12)
            .frame(height: 200)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(action: onTap) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
}

// MARK: - Empty Notes View
struct EmptyNotesView: View {
    let onAddNote: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "note.text")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Notes Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Start by creating your first note")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onAddNote) {
                HStack {
                    Image(systemName: "plus")
                    Text("Create Note")
                }
                .foregroundColor(.white)
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(25)
            }
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NotesListView()
}
