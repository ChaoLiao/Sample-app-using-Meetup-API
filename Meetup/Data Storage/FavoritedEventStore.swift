//
//  FavoritedEventStore.swift
//  Meetup
//
//  Created by YIN CHAO LIAO on 1/20/19.
//  Copyright © 2019 CHAO LIAO. All rights reserved.
//

import Foundation

protocol KeyValueStoreProtocol {
    func dictionary(forKey key: String) -> [String: Any]?
    func set(_ value: Any?, forKey key: String)
}

extension UserDefaults: KeyValueStoreProtocol {}

class FavoritedEventStore {
    
    static let shared = FavoritedEventStore()
    
    let storeKey = "favoritedEventIds"
    let store: KeyValueStoreProtocol
    
    // This initializer should only be used for testing. If it's not test, use the .shared singleton instead.
    init(backingStore: KeyValueStoreProtocol = UserDefaults.standard) {
        store = backingStore
    }
    
    func favoritedEventIds() -> [String: Bool] {
        guard let favoritedIds = store.dictionary(forKey: storeKey) as? [String: Bool] else {
            return [:]
        }
        return favoritedIds
    }
    
    func favoriteEvent(for id: String) {
        if var favoritedIds = store.dictionary(forKey: storeKey) as? [String: Bool] {
            favoritedIds[id] = true
            store.set(favoritedIds, forKey: storeKey)
        } else {
            store.set([id: true], forKey: storeKey)
        }
    }
    
    func unfavoriteEvent(for id: String) {
        guard var favoritedIds = store.dictionary(forKey: storeKey) as? [String: Bool], let _ = favoritedIds[id] else {
            return
        }
        favoritedIds[id] = nil
        store.set(favoritedIds, forKey: storeKey)
    }
}

