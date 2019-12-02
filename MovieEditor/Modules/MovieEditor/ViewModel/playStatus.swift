//
//  playStatus.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/12/02.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit

enum PlayStatus {
    case playing
    case paused
}

extension PlayStatus {
    var buttonImage: UIImage? {
        switch self {
        case .playing:
            return R.image.movieEditor_pause()
        case .paused:
            return R.image.movieEditor_play()
        }
    }
}
