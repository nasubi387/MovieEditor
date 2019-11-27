//
//  ContentsUseCase.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/11/24.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import RxSwift
import RxCocoa
import RxOptional
import Photos

protocol ContentsUseCaseInput {
    func fetchContents() -> Observable<[MovieContent]>
    func requestURLAsset(from movie: PHAsset) -> Observable<AVURLAsset>
}

class ContentsUseCase: ContentsUseCaseInput {
    
    func fetchContents() -> Observable<[MovieContent]> {
        return AssetManager.fetch(.video).map { $0 as? [MovieContent] }.filterNil()
    }
    
    func requestURLAsset(from movie: PHAsset) -> Observable<AVURLAsset> {
        guard movie.mediaType == .video else {
            return Observable.empty()
        }
        return AssetManager.requestMovie(from: movie)
    }
}
