//
//  Theme.swift
//  Radio
//
//  Created by Rodrigo Prestes on 7/8/16.
//
//

import Foundation

private extension Int {
    
    func rgbDivided() -> Float {
        return Float(self) / 256.0
    }
    
}

public typealias RGBValues = (red: Float, green: Float, blue: Float)

public protocol Theme {
    
    var id: Int { get set }
    func setupView()
    
}

public extension Theme {
    
    func radioBlue() -> RGBValues {
        return (red: 72.rgbDivided(), green: 102.rgbDivided(), blue: 126.rgbDivided())
    }
    
    func radioGrey() -> RGBValues {
        let uniqueValue = 120.rgbDivided()
        return (red: uniqueValue, green: uniqueValue, blue: uniqueValue)
    }
    
    func radioLightGrey() -> RGBValues {
        let uniqueValue = 209.rgbDivided()
        return (red: uniqueValue, green: uniqueValue, blue: uniqueValue)
    }
    
    func radioDarkGrey() -> RGBValues {
        let uniqueValue = 27.rgbDivided()
        return (red: uniqueValue, green: uniqueValue, blue: uniqueValue)
    }
    
}
