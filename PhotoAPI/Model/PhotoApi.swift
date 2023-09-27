//
//  PhotoApi.swift
//  PhotoAPI
//
//  Created by Manish Parihar on 27.09.23.
//

import Foundation

struct PhotoApi: Codable {
    let success:Bool
    let total_photos: Int
    let message: String
    let offset: Int
    let limit: Int
    let photos: [Photo]
}


struct Photo: Codable, Identifiable {
    let description:String?
    let url : String?
    let title:String?
    let id, user: Int?
}
