
import Foundation
import SwiftUI
import Combine

class CoinImageService {
    @Published var image: UIImage? = nil
    
    private var imageSubscription: AnyCancellable?
    private let coin: Coin
    private let fileManager = LocalFileManager.instance
    private let folderName = "coin_images"
    private let imageName: String
    
    init(coin: Coin) {
        self.coin = coin
        self.imageName = coin.id
        getCoinImage()
    }
    
    private func getCoinImage() {
        // green code image cash
        if let savedImage = fileManager.getImage(imageName: imageName, folderName: folderName) {
            image = savedImage
            //print("Retrieved image from file Manager!")
        } else {
            downloadCoinImage()
            //print("Downloading image now")
        }
    }
    
    private func downloadCoinImage() {
        guard let url = URL(string: coin.image) else { return }
        
        imageSubscription = NetworkingManager.download(url: url)
            .tryMap({ (data) -> UIImage? in
                return UIImage(data: data)
            })
            .receive(on: DispatchQueue.main) // back to main thread before sink
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] (returnedImage) in
                guard let self = self, let downloadedImage = returnedImage else { return }
                self.image = downloadedImage
                self.imageSubscription?.cancel()
                self.fileManager.saveImage(image: downloadedImage, imageName: self.imageName, folderName: self.folderName)
            })
    }
}

/*
class CoinImageService: CoinImageServiceProtocol {
    var networkManager: NetworkProtocol = NetworkingManager()
    var image: UIImage? = nil
    
    private let coin: Coin
    private let fileManager = LocalFileManager.instance
    private let folderName = "coin_images"
    private let imageName: String
    
    init(coin: Coin) async {
        self.coin = coin
        self.imageName = coin.id
        try? await getCoinImage()
    }
    
    func getCoinImage() async throws -> Void {
        // green code image cash
        if let savedImage = fileManager.getImage(imageName: imageName, folderName: folderName) {
            image = savedImage
            //print("Retrieved image from file Manager!")
        } else {
            try await downloadCoinImage()
            //print("Downloading image now")
        }
    }
    
    func downloadCoinImage() async throws -> UIImage? {
        guard let url = URL(string: coin.image) else {
            throw NetworkingManager.NetworkingError.invalidURLString
        }
        return try await getObject(url: url)
    }
    
    func getObject<C>(url: URL) async throws -> C where C : UIImage {
        let data = try await networkManager.download(url: url)
        return UIImage(data: data) as! C
    }
}

protocol CoinImageServiceProtocol {
    func getCoinImage() async throws -> Void
}
*/
