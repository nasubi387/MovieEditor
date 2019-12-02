//
//  ContentsWireframe.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/11/24.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import Foundation

protocol ContentsWireframeInput {
    static func assembleModule() -> ContentsViewController
    func presentEditorView(with movie: MovieContent?)
}

class ContentsWireframe: ContentsWireframeInput {
    private weak var view: ContentsViewInput!
    
    static func assembleModule() -> ContentsViewController {
        let view = R.storyboard.contentsViewController().instantiateInitialViewController() as! ContentsViewController
        _ = view.view
        
        let usecase = ContentsUseCase()
        let wireframe = ContentsWireframe(view: view)
        
        let viewModelDependency = ContentsViewModel.Dependency(wireframe: wireframe, usecase: usecase)
        let viewModelInput = ContentsViewModel.Input(itemSelected: view.collectionView.rx.itemSelected)
        
        let viewModel = ContentsViewModel(dependency: viewModelDependency, input: viewModelInput)
        
        view.bind(to: viewModel)
        
        return view
    }
    
    init(view: ContentsViewInput) {
        self.view = view
    }
    
    func presentEditorView(with movie: MovieContent?) {
        guard let movie = movie, movie.urlAsset != nil else {
            return
        }
        let movieEvitorView = MovieEditorWireframe.assembleModule(with: movie)
        movieEvitorView.modalPresentationStyle = .fullScreen
        
        view.present(movieEvitorView, animated: true)
    }
}
