//
//  String+Extensions.swift
//  PeshkarikiTest
//
//  Created by Игорь on 13.05.2022.
//

import Foundation

extension String {
    var trimmedTrailingWhitespace: Self {
        var result = self

        while result.last?.isWhitespace == true {
            result = String(result.dropLast())
        }

        return result
    }
}
