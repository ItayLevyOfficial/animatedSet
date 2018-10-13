//
//  Card.swift
//  graphicalSet
//
//  Created by Apple Macbook on 29/03/2018.
//  Copyright © 2018 Apple Macbook. All rights reserved.
//

import Foundation

struct SetCard: Equatable {
    static func ==(lhs: SetCard, rhs: SetCard) -> Bool {
        if lhs.color == rhs.color, lhs.shade == rhs.shade, lhs.shape == rhs.shape, lhs.color == rhs.color {
            return true
        } else {
            return false
        }
    }
    
    
    
    private(set) var number: Number
    private(set) var shape: Shape
    private(set) var shade: Shade
    private(set) var color: Color
    
    static var allCards: [SetCard] {
        var ret = [SetCard]()
        for num in Number.allValues {
            for shade in Shade.allValues {
                for shape in Shape.allValues {
                    for color in Color.allValues {
                        ret += [SetCard(shape: shape, shade: shade, number: num, color: color)]
                    }
                }
            }
        }
        return ret
    }
    
    private init(shape: Shape, shade: Shade, number: Number, color: Color) {
        self.shade = shade
        self.number = number
        self.shape = shape
        self.color = color
    }
}
enum Number{
    case one, two, three
    
    static var allValues: [Number] {
        return [Number.one, .two, .three]
    }
}
enum Shape {
    case shape1, shape2, shape3
    
    static var allValues: [Shape] {
        return [Shape.shape1, .shape2, .shape3]
    }
}
enum Shade {
    case solid, striped, open
    
    static var allValues: [Shade] {
        return [Shade.open, .solid, .striped]
    }
}
enum Color{
    case color1, color2, color3
    
    static var allValues: [Color] {
        return [Color.color1, .color2, .color3]
    }
}
