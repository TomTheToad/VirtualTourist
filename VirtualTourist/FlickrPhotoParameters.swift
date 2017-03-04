//
//  FlickrPhotoParameters.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 2/28/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation

struct FlickrPhotoParameters {
    var id: String = ""
    var title: String = ""
    var url: String?
    
    init(id: String, title: String, url: String?) {
        self.id = id
        self.title = title
        if let url = url {
            self.url = url
        }
    }
}
