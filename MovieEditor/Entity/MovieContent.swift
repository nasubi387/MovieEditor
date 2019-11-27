//
//  MovieContent.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/11/24.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

protocol Content {
    var thumbnail: UIImage { get }
}

struct MovieContent: Content {
    let thumbnail: UIImage
    let asset: PHAsset
    var urlAsset: AVURLAsset? = nil
}
