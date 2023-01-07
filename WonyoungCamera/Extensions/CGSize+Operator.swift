//
//  CGSize+Operator.swift
//  WonyoungCamera
//
//  Created by 워뇨옹 on 2023/01/07.
//

import Foundation

func += (left: inout CGSize, right: CGFloat) {
    left.width += right
    left.height += right
}

func -= (left: inout CGSize, right: CGFloat) {
    left.width -= right
    left.height -= right
}

func *= (left: inout CGSize, right: CGFloat) {
    left.width *= right
    left.height *= right
}

func /= (left: inout CGSize, right: CGFloat) {
    left.width /= right
    left.height /= right
}

func += (left: CGSize, right: CGFloat) -> CGSize {
    var value = left
    value.width += right
    value.height += right
    return value
}

func -= (left: CGSize, right: CGFloat) -> CGSize {
    var value = left
    value.width -= right
    value.height -= right
    return value
}

func *= (left: CGSize, right: CGFloat) -> CGSize {
    var value = left
    value.width *= right
    value.height *= right
    return value
}

func /= (left: CGSize, right: CGFloat) -> CGSize {
    var value = left
    value.width /= right
    value.height /= right
    return value
}
