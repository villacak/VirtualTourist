//
//  ImageCache.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/30/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//


import Foundation
import UIKit

class ImageCache {
    
    fileprivate var inMemoryCache = NSCache()
    
    // MARK: - Retreiving images
    
    func imageWithIdentifier(_ identifier: String?) -> UIImage? {
        if identifier == nil || identifier! == VTConstants.EMPTY_STRING {
            return nil
        }
        let path = pathForIdentifier(identifier!)
        //        var data: NSData?
        
        if let image = inMemoryCache.object(forKey: path) as? UIImage {
            return image
        }
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    // MARK: - Saving images
    
    func storeImage(_ image: UIImage?, withIdentifier identifier: String) {
        let path: String = pathForIdentifier(identifier)
        print("store cache : \(path)")
        
        // If the image is nil, remove images from the cache
        if image == nil {
            inMemoryCache.removeObject(forKey: path)
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch let error as NSError {
                print("Error : \(error.localizedDescription)")
            }
            return
        }
        
        // Otherwise, keep the image in memory
        inMemoryCache.setObject(image!, forKey: path)
        
        // And in documents directory
        let data = UIImagePNGRepresentation(image!)
        try? data!.write(to: URL(fileURLWithPath: path), options: [.atomic])
    }
    
    // MARK: - Helper
    
    func pathForIdentifier(_ identifier: String) -> String {
        let documentsDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        let fullURL = documentsDirectoryURL.appendingPathComponent(identifier)
        
        return fullURL.path
    }
}
