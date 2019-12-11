//
//  CGPoint+App.swift
//  MovieEditor
//
//  Created by Ishida Naoya on 2019/12/11.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit

func -(_ left:CGPoint, _ right:CGPoint)->CGPoint{
    return CGPoint(x:left.x - right.x, y:left.y - right.y)
}

func +(_ left:CGPoint, _ right:CGPoint)->CGPoint{
    return CGPoint(x:left.x + right.x, y:left.y + right.y)
}
