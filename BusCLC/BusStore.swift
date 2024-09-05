//
//  BusStore.swift
//  BusCLC
//
//  Created by Brennan Reinhard on 8/20/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

let db = Firestore.firestore()

func testCommitToDB() async {
    do {
        try await db.enableNetwork()
    } catch {
        print("i hate firestore")
    }
    
    let docRef = db.collection("test").document("tmp")

    do {
      let document = try await docRef.getDocument()
      if document.exists {
        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
        print("Document data: \(dataDescription)")
      } else {
        print("Document does not exist")
      }
    } catch {
      print("Error getting document: \(error)")
    }

}
