//
//  Cache.swift
//  ToolsHomeWork
//
//  Created by Igor Kupreev on 9/30/18.
//  Copyright © 2018 Igor Kupreev. All rights reserved.
//

import Foundation
import  UIKit

class MemoryCache {
    
    private static let _shared = MemoryCache()
    
    var images = [String:UIImage]()
    
    static var shared: MemoryCache {
        return _shared
    }
}

extension MemoryCache {
    
    func size() -> Int {
        return images.count
    }
    
    func clear() {
        images.removeAll()
    }
    
    func set(_ image: UIImage, forKey key: String) {
        images[key] = image
    }
    
    func image(forKey key: String) -> UIImage? {
        return images[key]
    }
}
