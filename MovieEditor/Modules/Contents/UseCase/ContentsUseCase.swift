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

protocol ContentsUseCaseInput {
    func fetchContents() -> Observable<[MovieContent]>
}

class ContentsUseCase: ContentsUseCaseInput {
    
    func fetchContents() -> Observable<[MovieContent]> {
        return AssetManager.fetch(.video).map { $0 as? [MovieContent] }.filterNil()
    }
}
