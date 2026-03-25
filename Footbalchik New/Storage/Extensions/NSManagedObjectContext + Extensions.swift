//
//  NSManagedObjectContext+Extensions.swift
//  Footbalchik
//

import CoreData

extension NSManagedObjectContext {
    func saveIfNeeded() {
        if hasChanges {
            do {
                try save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    func performAndSave(_ block: @escaping (NSManagedObjectContext) -> Void) {
        perform {
            block(self)
            self.saveIfNeeded()
        }
    }
}