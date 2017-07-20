//
//  DataCounter.swift
//  The Big Seaweed Search
//
//  Created by Chase Scott-Pearson on 20/07/2017.
//  Copyright © 2017 Chase Scott-Pearson. All rights reserved.
//

import Foundation

class DataCounter {
    
    private var _count: Int!
    private var _isPostType: Bool!
    
    var count: Int {
        get {
            return _count
        }
        set {
            _count = newValue
        }
    }
    
    var isPostType: Bool {
        get {
            return _isPostType
        } set {
            _isPostType = newValue
        }
    }
    
    init(count: Int, isPostType: Bool) {
        self._count = count
        self._isPostType = isPostType
    }
    
}
