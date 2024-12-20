//
//  OthersStoreFirebaseService.swift
//  BeAnywhere
//
//  Created by Evelyn Xiao on 11/20/24.
//
import UIKit
import FirebaseAuth

extension SelectItemsViewController {
    func initFoodItems(tripId: String, storeId: String) async {
        if let foodItems = await getFoodItems(tripId: tripId, storeId: storeId) {
            self.items = foodItems
            DispatchQueue.main.async {
                self.storeView.itemsTable.reloadData()
            }
        }
        else {
            print("failed to fetch food items.")
        }
        
        if let storeUsers = await getTripUsers(tripId: tripId) {
            self.users = storeUsers
        }
        
        
        var submitterName: String = ""
        if let store {
            let submitterId = store.submitterId
            submitterName = await getUserName(userId: submitterId) ?? "cannot get submitter name"
            
        }
        
        storeView.msgButton.setTitle("Message \(submitterName)", for: .normal)
        let buttonWidth = self.storeView.msgButton.intrinsicContentSize.width + 20
        let buttonHeight = self.storeView.msgButton.intrinsicContentSize.height + 20
        
        self.storeView.msgButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        self.storeView.msgButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
    }
    
    func getTripUsers(tripId: String) async -> [String:String]? {
        let tripCollectionsRef = database
            .collection(FoodTrip.collectionName)
        
        do {
            let tripDocsRef = try await tripCollectionsRef.getDocuments()
            let tripDocs = try tripDocsRef.documents.map({try $0.data(as: FoodTripFromDoc.self)})
            
            var users: [String:String] = [:]
            for trip in tripDocs {
                if trip.id == tripId {
                    print("found trip")
                    for id in trip.memberIds {
                        users[id] = await getUserName(userId: id)
                    }
                    return users
                }
            }
            
            
        } catch {
            
        }
        return nil
    }
    
    func getChatWithStorePayer(tripId: String, storeId: String) async -> Chat? {
        let chatDocRef = database
            .collection(FoodTrip.collectionName)
            .document(tripId)
            .collection(FoodStore.collectionName)
            .document(storeId)
            .collection(Chat.collectionName)
            .document(firebaseAuth.currentUser!.uid)
        
        do {
            let chat = try await chatDocRef.getDocument(as: ChatFromDoc.self)
            
            let storePayer = await UserFirebaseService().getUser(uid: chat.storePayerId)
            
            if (storePayer == nil) {
                return nil
            }
            
            return Chat(doc: chat, storePayer: storePayer!)
            
        } catch {
            return nil
        }
    }
    
    func getFoodItems(tripId: String, storeId: String) async -> [FoodItemFromDoc]? {
        print("trip: \(tripId), store: \(storeId)")
        let foodItemsCollectionRef = database
            .collection(FoodTrip.collectionName)
            .document(tripId)
            .collection(FoodStore.collectionName)
            .document(storeId)
            .collection(FoodItem.collectionName)
        
        do {
            let foodItemDocsRef = try await
                foodItemsCollectionRef.getDocuments()
            
            let foodItemDocs = try
                foodItemDocsRef.documents.map({try
                    $0.data(as: FoodItemFromDoc.self)
                })
            print("num items: \(foodItemDocs.count)")
            return foodItemDocs
        } catch {
            print("Error fetching food items: \(error)")
            return nil
        }
    }
    
    func getUserName(userId: String) async -> String? {
        let userRef = database
            .collection(FirestoreUser.collectionName).document(userId)
        
        do {
            let userDoc = try await userRef.getDocument()
            let user = try userDoc.data(as: FirestoreUser.self)
            return user.name
        } catch {
            print("Error fetching user name: \(error)")
            return nil
        }
        
    }
    
    func saveFoodItemSelections(selectedItems: [FoodItemFromDoc], tripId: String, storeId: String) async {
        let foodItemsCollectionRef = database
            .collection(FoodTrip.collectionName)
            .document(tripId)
            .collection(FoodStore.collectionName)
            .document(storeId)
            .collection(FoodItem.collectionName)
        
        print("Saving food item selections: \(selectedItems.count)")
        for item in self.items {
            let itemDocRef = foodItemsCollectionRef.document(item.id)
            do {
                // Replace the payerUserIds field with the updated list
                try await itemDocRef.updateData([
                    TableConfigs.payerUserIds: item.payerUserIds
                ])
                print("Updated payerUserIds for item: \(item.name)")
            } catch {
                print("Error updating payerUserIds for item \(item.name): \(error)")
            }
        }
    }
    
}

