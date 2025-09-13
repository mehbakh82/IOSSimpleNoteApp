//
//  EditNoteView.swift
//  SimpleNoteSwift
//
//  Created by Mehran Bakhtiari on 9/13/25.
//

import SwiftUI

struct EditNoteView: View {
    let note: NoteEntity
    @State private var title: String
    @State private var content: String
    @Environment(\.dismiss) private var dismiss
    
    let onSave: (String, String) -> Void
    
    init(note: NoteEntity, onSave: @escaping (String, String) -> Void) {
        self.note = note
        self._title = State(initialValue: note.title ?? "")
        self._content = State(initialValue: note.content ?? "")
        self.onSave = onSave
    }
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (title != (note.title ?? "") || content != (note.content ?? ""))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("Edit Note")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Update your note content")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                // Form
                VStack(spacing: 20) {
                    // Title Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter note title", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                    
                    // Content Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                .frame(minHeight: 200)
                            
                            TextEditor(text: $content)
                                .padding(8)
                                .frame(minHeight: 200)
                                .background(Color.clear)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(trimmedTitle, trimmedContent)
                        dismiss()
                    }
                    .disabled(!isFormValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    // Preview with a mock Core Data note
    Text("Edit Note Preview")
}
