//
//  MovieEditorWireframe.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/11/25.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol MovieEditorWireframeInput {
    static func assembleModule(with movie: MovieContent) -> UINavigationController
    func dismissMovieEditor()
}

class MovieEditorWireframe: MovieEditorWireframeInput {
    private weak var view: MovieEditorViewInput!
    
    static func assembleModule(with movie: MovieContent) -> UINavigationController {
        let navigationController = R.storyboard.movieEditorViewController().instantiateInitialViewController() as! UINavigationController
        let view = navigationController.viewControllers.first as! MovieEditorViewController
        _ = view.view
        
        let usecase = MovieEditorUseCase()
        let wireframe = MovieEditorWireframe(view: view)
        
        let viewModelDependency = MovieEditorViewModel.Dependency(wireframe: wireframe, usecase: usecase, movieManager: MovieManager(with: movie.urlAsset!))
        let viewModelInput = MovieEditorViewModel.Input(didTapCloseButton: view.closeButton.rx.tap,
                                                        didTapPlayerView: view.tapPlayerViewGesture.rx.event,
                                                        didScrollFrameImage: view.rx.didScrollFrameImage,
                                                        didTapAddTextItemButton: view.addButton.rx.tap)
        
        let viewModel = MovieEditorViewModel(dependency: viewModelDependency, input: viewModelInput, movie: movie)
        
        view.bind(to: viewModel)
        
        return navigationController
    }
    
    init(view: MovieEditorViewInput) {
        self.view = view
    }
    
    func dismissMovieEditor() {
        view.dismiss(animated: true)
    }
}
