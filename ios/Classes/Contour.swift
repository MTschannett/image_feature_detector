//
//  Contour.swift
//  image_feature_detector
//
//  Created by Marco Tschannett on 14.04.19.
//

import Foundation

public class Contour {
    var points: Array<Point>;
}

public class Point {
    var x: int;
    var y: int;
    
    init(x: int, y: int) {
        self.x = x;
        self.y = y;
    }
}
