////
////  DebuggingSceneDelegate.swift
////  EssentialApp
////
////  Created by Srinivasan Rajendran on 2021-04-05.
////
//
//#if DEBUG
//
//import UIKit
//import EssentialFeed
//
//class DebuggingSceneDelegate: SceneDelegate {
//
//    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//
//        guard let _ = (scene as? UIWindowScene) else { return }
//
//        if CommandLine.arguments.contains("-reset") {
//            try? FileManager.default.removeItem(at: localStoreURL)
//        }
//
//        super.scene(scene, willConnectTo: session, options: connectionOptions)
//    }
//
//    override func makeRemoteClient() -> HTTPClient {
//        if let connectivity = UserDefaults.standard.string(forKey: "connectivity") {
//            return DebuggingHTTPClient(connectivity: connectivity)
//        }
//        return super.makeRemoteClient()
//    }
//}
//
//private class DebuggingHTTPClient:  HTTPClient {
//    private class Task: HTTPClientTask {
//        func cancel() { }
//    }
//
//    private let connectivity: String
//
//    init(connectivity: String) {
//        self.connectivity = connectivity
//    }
//
//    func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) -> HTTPClientTask {
//        switch connectivity {
//        case "online":
//            let (data, response) = makeSuccessfulResponse(for: url)
//            completion(.success(data, response))
//
//        default:
//            completion(.failure(NSError(domain: "offline", code: 0)))
//        }
//        return Task()
//    }
//
//    private func makeSuccessfulResponse(for url: URL) -> (Data, HTTPURLResponse) {
//        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
//        return (makeData(for: url), response)
//    }
//
//    private func makeData(for url: URL) -> Data {
//        switch url.absoluteString {
//        case "http://image.com":
//            return makeImageData()
//
//        default:
//            return makeFeedData()
//        }
//    }
//
//    private func makeImageData() -> Data {
//        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
//        UIGraphicsBeginImageContext(rect.size)
//        let context = UIGraphicsGetCurrentContext()!
//        context.setFillColor(UIColor.red.cgColor)
//        context.fill(rect)
//        let img = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return img!.pngData()!
//    }
//
//    private func makeFeedData() -> Data {
//        return try! JSONSerialization.data(withJSONObject: ["items": [
//            ["id": UUID().uuidString, "image": "http://image.com"],
//            ["id": UUID().uuidString, "image": "http://image.com"]
//        ]])
//    }
//}
//
//#endif
