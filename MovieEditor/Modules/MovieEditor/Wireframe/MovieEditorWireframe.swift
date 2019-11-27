//
//  MovieEditorWireframe.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/11/25.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import Foundation

protocol MovieEditorWireframeInput {
    static func assembleModule(with movie: MovieContent) -> MovieEditorViewController
}

class MovieEditorWireframe: MovieEditorWireframeInput {
    private weak var view: MovieEditorViewInput!
    
    static func assembleModule(with movie: MovieContent) -> MovieEditorViewController {
        let view = R.storyboard.movieEditorViewController().instantiateInitialViewController() as! MovieEditorViewController
        _ = view.view
        
        let usecase = MovieEditorUseCase()
        let wireframe = MovieEditorWireframe(view: view)
        
        let viewModelDependency = MovieEditorViewModel.Dependency(wireframe: wireframe, usecase: usecase, movieManager: MovieManager(with: movie.urlAsset!))
        let viewModelInput = MovieEditorViewModel.Input()
        
        let viewModel = MovieEditorViewModel(dependency: viewModelDependency, input: viewModelInput, movie: movie)
        
        view.bind(to: viewModel)
        
        return view
    }
    
    init(view: MovieEditorViewInput) {
        self.view = view
    }
}
