//
//  Picsum.swift
//  SwiftUIColorsFromImage
//
//  Created by Vinicius Nakamura on 18/08/22.
//

import Foundation
import SwiftUI

enum URLs {
    private static let base = URLComponents(string: "https://picsum.photos")
    
    static func list(page: Int) -> URL? {
        guard var components = base else { return nil }
        components.path = "/v2/list"
        components.queryItems = [URLQueryItem(name: "page", value: String(page))]
        return components.url
    }
    
    static func squareImageByID(_ id: String, size: Int) -> URL? {
        guard var components = base else { return nil }
        components.path = "/id/\(id)/\(size)"
        return components.url
    }
}

struct PictureInfo: Identifiable, Decodable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let url: String
}

enum Status {
    case idle, loading, complete
    case error(message: String)
}

enum PicsumError: Error {
    case urlError, networkError, decodeError
}

extension PicsumError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .urlError:
            return NSLocalizedString("Invalid URL", comment: "PicsumError")
        case .networkError:
            return NSLocalizedString("Could not reach the server", comment: "PicsumError")
        case .decodeError:
            return NSLocalizedString("Invalid response", comment: "PicsumError")
        }
    }
}

enum PicsumService {
    static func fetchList(_ page: Int = 1) async throws -> [PictureInfo] {
        guard let url = URLs.list(page: page)
        else { throw PicsumError.urlError }
        
        guard let (data, _) = try? await URLSession.shared.data(from: url)
        else { throw PicsumError.networkError }
        
        guard let decoded = try? JSONDecoder().decode([PictureInfo].self, from: data)
        else { throw PicsumError.decodeError }
        
        return decoded
    }
    
    private static let imageCache = NSCache<NSURL, UIImage>()
    
    static func fetchImage(_ id: String, size: Int) async throws -> UIImage {
        guard let url = URLs.squareImageByID(id, size: size)
        else { throw PicsumError.urlError }
        
        if let cached = imageCache.object(forKey: url as NSURL) { return cached }
        
        guard let (data, _) = try? await URLSession.shared.data(from: url)
        else { throw PicsumError.networkError }
        
        guard let image = UIImage(data: data)
        else { throw PicsumError.decodeError }
        
        imageCache.setObject(image, forKey: url as NSURL)
        return image
    }
}

@MainActor
class PicsumList: ObservableObject {
    @Published var photos: [PictureInfo] = []
    @Published var status: Status = .idle
    
    @Sendable func loadPage() async {
        let page = Int.random(in: 1 ... 33)
        
        photos = []
        status = .loading
        do {
            photos = try await PicsumService.fetchList(page)
            status = .complete
        } catch {
            status = .error(message: error.localizedDescription)
        }
    }
}

@MainActor
private class ImageLoader: ObservableObject {
    @Published var image: Image?
    @Published var status = Status.idle
    
    func loadImage(_ id: String, size: Int) async {
        status = .loading
        
        do {
            let uiImage = try await PicsumService.fetchImage(id, size: size)
            
            withAnimation {
                image = Image(uiImage: uiImage)
                status = .complete
            }
        } catch {
            status = .error(message: error.localizedDescription)
        }
    }
}

struct PicsumAsyncImage<Content: View, Placeholder: View>: View {
    @StateObject private var loader = ImageLoader()
    
    var id: String
    var content: (Image) -> Content
    var placeholder: () -> Placeholder
    
    var body: some View {
        Group {
            switch loader.status {
            case .idle, .loading:
                placeholder()
                
            case .complete:
                content(loader.image!)
                
            case .error(let message):
                VStack(alignment: .center) {
                    Image(systemName: "x.square.fill").font(.title)
                    Text(message).font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .task {
            await loader.loadImage(id, size: 500)
        }
    }
}
