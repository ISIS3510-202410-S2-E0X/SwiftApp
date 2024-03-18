//
//  SpotsDAOFirebase.swift
//  FoodBookApp
//
//  Created by Maria Castro on 3/4/24.
//

import Foundation
import FirebaseFirestore

class SpotDAOFirebase: SpotDAO {
    static var shared: SpotDAO = SpotDAOFirebase()
    private var client: FirebaseClient = FirebaseClient.shared
    private var collection: CollectionReference
    
    private init () {
        self.collection = client.db.collection("spots")
    }
    
    func getSpotById(documentId: String) async throws -> Spot {
        let snapshot = try await collection.document(documentId).getDocument()
        let spot = try snapshot.data(as: SpotDTO.self)
        var reviews = [Review]()

        for reviewRef in spot.reviewData.userReviews {
            let review = try await self.getReview(ref: reviewRef)
            reviews.append(review)
        }
           
        print("FIREBASE: Completed spot fetch \(documentId)")
        return Spot(categories: spot.categories, location: spot.location, name: spot.name, price: spot.price, waitTime: spot.waitTime, reviewData: ReviewData(stats: spot.reviewData.stats, userReviews: reviews), imageLinks: spot.imageLinks)
    }
    
    func getReview(ref: DocumentReference) async throws -> Review {
        let snapshot = try await ref.getDocument()
        return try snapshot.data(as: Review.self)
    }
    
    func getSpots() async throws -> [Spot] {
        let snapshot = try await collection.getDocuments()
        var spots = [Spot]()

        for document in snapshot.documents {
            print("FIREBASE: Trying to fetch document \(document.documentID)")
            let spotDTO = try document.data(as: SpotDTO.self)

            let spot = Spot(
                categories: spotDTO.categories,
                location: spotDTO.location,
                name: spotDTO.name,
                price: spotDTO.price,
                waitTime: spotDTO.waitTime,
                reviewData: ReviewData(
                    stats: spotDTO.reviewData.stats,
                    userReviews: []
                ),
                imageLinks: spotDTO.imageLinks
            )
            spots.append(spot)
        }
        return spots
    }
}
