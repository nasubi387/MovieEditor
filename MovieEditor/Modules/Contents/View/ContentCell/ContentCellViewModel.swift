//
//  ContentCellViewModel.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/11/24.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ContentCellViewModel {
    
    struct Output {
        let thumbnailImage: Observable<UIImage>
        let durationText: Observable<String?>
    }
    
    struct State {
        let content: Content
    }
    var currentState: State {
        return State(content: _content.value)
    }
    
    let output: Output
    
    private let disposeBag = DisposeBag()
    
    private let _content: BehaviorRelay<Content>
    
    init(content: Content) {
        
        _content = BehaviorRelay<Content>(value: content)
        
        let thumbnailImage = _content.map { $0.thumbnail }
        
        let durationText = _content.map { content -> String? in
            guard let duration = (content as? MovieContent)?.asset.duration else {
                return nil
            }
            let min = Int(duration / 60)
            let sec = Int(duration) % 60
            return String(format:"%02d:%02d", min, sec)
        }
        
        let output = Output(thumbnailImage: thumbnailImage,
                            durationText: durationText)
        self.output = output
    }
}
