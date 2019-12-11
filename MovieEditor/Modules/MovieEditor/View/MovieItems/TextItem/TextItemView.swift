//
//  TextItemView.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/12/11.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TextItemView: UIView, NibLoadable {
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var textField: UITextField!
    var panViewGesture: UIPanGestureRecognizer!
    var orgOrigin: CGPoint = .zero
    var orgParentPoint : CGPoint = .zero
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadNib()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
        setup()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
}

extension TextItemView {
    func bind() {
        textField.rx.editingDidEnd
            .drive(onNext:{ [weak self] in
                guard self?.textField.isFirstResponder == true else {
                    return
                }
                self?.textField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        panViewGesture.rx.event.asDriver()
            .drive(onNext: { [weak self] gesture in
                guard let self = self else {
                    return
                }
                switch gesture.state {
                case .began:
                    self.orgOrigin = self.frame.origin
                    self.frame.origin = self.orgOrigin
                case .changed:
                    let newPoint = gesture.translation(in: self)
                    self.frame.origin = self.orgOrigin + newPoint
                default:
                    return
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setup() {
        backgroundColor = UIColor.clear
        
        panViewGesture = UIPanGestureRecognizer(target: nil, action: nil)
        addGestureRecognizer(panViewGesture)
    }
}
