//
//  OutputColors.swift
//  
//
//  Created by Benedict on 08.02.22.
//

import Foundation

//MIT - Copyright (c) 2013 Diego Freniche
//https://github.com/dfreniche/SwiftANSIColors
enum ANSIColors: String {
	case black = "\u{001B}[30m"
	case red = "\u{001B}[31m"
	case green = "\u{001B}[32m"
	case yellow = "\u{001B}[33m"
	case blue = "\u{001B}[34m"
	case magenta = "\u{001B}[35m"
	case cyan = "\u{001B}[36m"
	case white = "\u{001B}[37m"
	case `default` = "\u{001B}[0;0m"
}

fileprivate func + (left: ANSIColors, right: String) -> String {
	return left.rawValue + right
}

///Prints colored string to the command line
///- Parameter str: message
///- Parameter color: color to display the message in
func printInColor(_ str: String, color: ANSIColors){
	print(color.rawValue + str + ANSIColors.default.rawValue)
}

extension String: LocalizedError {
	public var errorDescription: String? { return self }
}

extension String{
	func colored(_ color: ANSIColors) -> String{
		return color.rawValue + self + ANSIColors.default.rawValue
	}
}
