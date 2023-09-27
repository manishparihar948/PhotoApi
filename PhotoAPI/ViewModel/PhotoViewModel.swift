//
//  PhotoViewModel.swift
//  PhotoAPI
//
//  Created by Manish Parihar on 27.09.23.
//

import Foundation
import Combine




@MainActor
final class PhotoViewModel: ObservableObject {
    
    @Published var photoApi: PhotoApi
    var cancellables = Set<AnyCancellable>()
    
    var offset = 0
    let batchSize = 10
    
    init(){
        self.photoApi = PhotoApi(success: false, total_photos: 0, message: "", offset: 0, limit: 0, photos: [])

        getPhotos(limit: 10)
    }
    
    func getPhotos(limit:Int) {
        print("Getting photos...")
        
        //guard let url = URL(string: "https://api.slingacademy.com/v1/sample-data/photos")
        guard let url = URL(string: "https://api.slingacademy.com/v1/sample-data/photos?offset=5&limit=20")
        else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap(handleOutput)
            .decode(type: PhotoApi.self, decoder: JSONDecoder())
            //.replaceError(with:nil)
            .mapError {
                error -> Never in
                        fatalError("Unhandled error: \(error)")
            }
            .sink( receiveValue: {[weak self](returnedPhotos) in
                self?.photoApi = returnedPhotos
                
                // Increment the offset for the next batch
                self?.offset += self?.batchSize ?? 0
            })
            .store(in: &cancellables)
    }
    
    func handleOutput(output:URLSession.DataTaskPublisher.Output) throws -> Data {
        guard
            let response = output.response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
            throw URLError(.badServerResponse)
        }
        return output.data
    }
    
    
}
