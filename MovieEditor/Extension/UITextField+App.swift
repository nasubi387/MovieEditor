//
//  UITextField+App.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/12/11.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UITextField {
    var editingDidBegin: Driver<Void> {
        return base.rx.controlEvent(.editingDidBegin).asDriver()
    }
    
    var editingDidEnd: Driver<Void> {
        return base.rx.controlEvent(.editingDidEnd).asDriver()
    }
}
