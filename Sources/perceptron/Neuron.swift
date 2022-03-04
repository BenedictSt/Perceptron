//
//  File.swift
//  
//
//  Created by Benedict on 01.03.22.
//

import Foundation

struct InputImage: Codable{
	let rectangle: Bool
	let pixels: [[Float]]
	
	init(rectangle: Bool, width: Int, height: Int){
		self.rectangle = rectangle
		if(rectangle){
			self.pixels = InputImage.generateRectangle(width: width, height: height)
		}else{
			self.pixels = InputImage.generateTriangle(width: width, height: height)
		}
	}
	
	private static func generateRectangle(width: Int, height: Int) -> [[Float]]{
		let x0 = Int.random(in: 0..<width-3)
		let y0 = Int.random(in: 0..<height-3)
		let rectangleWidth = Int.random(in: 2..<width-x0+1)
		let rectangleHeight = Int.random(in: 2..<height-y0+1)
		var tmpPixels: [[Float]] = Array(repeating: Array(repeating: 0, count: width), count: height)
		for x in 0..<rectangleWidth{
			for y in 0..<rectangleHeight{
				tmpPixels[y0 + y][x0 + x] = 1
			}
		}
		return tmpPixels
	}
	
	private static func generateTriangle(width: Int, height: Int) -> [[Float]]{
		let x0 = Int.random(in: 0..<width-3)
		let y0 = Int.random(in: 0..<height-3)
		let rectangleWidth = Int.random(in: 3..<min(width-x0+1, height-y0+1))
		let rectangleHeight = rectangleWidth //Int.random(in: 2..<height-y0+1)
		var tmpPixels: [[Float]] = Array(repeating: Array(repeating: 0, count: width), count: height)
		let m = Float(height) / Float(width)
		let leftRight = Bool.random()
		for x in 0..<rectangleWidth{
			for y in 0..<rectangleHeight{
				if(leftRight){
					if(Float(x) * m < Float(y)){
						tmpPixels[y0 + y][x0 + x] = 1
					}
				}else{
					if(Float(x) * m > Float(y)){
						tmpPixels[y0 + y][x0 + x] = 1
					}
				}
			}
		}
		return tmpPixels
	}
	
	public func getPixel(x: Int, y: Int) -> Float{
		return pixels[y][x]
	}
	
	public func printImage(){
		print("+\(Array(repeating: "-", count: self.pixels[0].count).joined())+")
		for row in pixels{
			print("|\(row.map({$0 > 0.5 ? "#" : " "}).joined())|")
		}
		print("+\(Array(repeating: "-", count: self.pixels[0].count).joined())+")
	}
}


class NeuronalNetwork: Codable{
	var bias: Float
	var weights: [Float]
	var width: Int
	var height: Int
	
	init(width: Int, height: Int){
		if(width < 4 || height < 4){
			fatalError("Dimensions too small")
		}
		self.bias = 1
		self.weights = Array(repeating: 1, count: width * height)
		self.width = width
		self.height = height
	}
	
	///- Returns: whether the input image is a rectangle
	func predict(input: InputImage) -> Bool{
		var sum: Float = 0
		for x in 0..<width{
			for y in 0..<height{
				sum += input.getPixel(x: x, y: y) * weights[x * width + y]
			}
		}
		return sum > bias
	}
	
	func train(input: InputImage){
		if(predict(input: input) != input.rectangle){
			if(input.rectangle){
				for x in 0..<width{
					for y in 0..<height{
						weights[x * width + y] += input.pixels[y][x] / 100
					}
				}
			}else{
				for x in 0..<width{
					for y in 0..<height{
						weights[x * width + y] -= input.pixels[y][x] / 100
					}
				}
			}
		}
//		print(weights.reduce(0, +))
	}
	
	public func printWeights(){
		print("------------------------")
		for x in 0..<width{
			var line = ""
			for y in 0..<height{
				let weight = weights[x * width + y]
				if weight > 0.9 {line += "@"}
				else if weight > 0.8 {line += "%"}
				else if weight > 0.7 {line += "#"}
				else if weight > 0.6 {line += "*"}
				else if weight > 0.5 {line += "+"}
				else if weight > 0.4 {line += "="}
				else if weight > 0.3 {line += "-"}
				else if weight > 0.2 {line += ":"}
				else if weight > 0.1 {line += "."}
				else{
					line += " "
				}
			}
			print(line)
		}
	}
}

class dataModel: Codable{
	let neuralNet: NeuronalNetwork
	let images: [InputImage]
	let testImages: [InputImage]
	
	init(width: Int, height: Int, countImageImages: Int, sharedImages: Bool){
		self.neuralNet = NeuronalNetwork(width: width, height: height)
		var lastWasRectangle = false
		var tmpImages: [InputImage] = []
		for _ in 0..<countImageImages{
			tmpImages.append(InputImage(rectangle: !lastWasRectangle, width: width, height: height))
			lastWasRectangle.toggle()
		}
		images = tmpImages
		//TODO: parameter to define number of testimages
		if(sharedImages){
			testImages = tmpImages
		}else{
			testImages = (0...50).map({_ in InputImage(rectangle: true, width: width, height: height)}) + (0...50).map({_ in InputImage(rectangle: false, width: width, height: height)})
		}
		
	}
	
	public func train(passes: Int){
		for _ in 0..<passes{
			for input in images {
				neuralNet.train(input: input)
			}
		}
	}
	
	public func testError(verbose: Bool) -> Float{
		var fails = 0
		for input in testImages {
			if(neuralNet.predict(input: input) != input.rectangle){
				fails += 1
//				print("[Failed]".colored(.red))
			}else{
//				print("[Success]".colored(.green))
			}
		}
		if(verbose){
			print("Tested \(testImages.count) images")
			print("Failed: \(fails)")
			print("Accuracy: \(Float(testImages.count - fails) / Float(testImages.count) * 100)%")
		}
		return Float(testImages.count - fails) / Float(testImages.count)
	}
}
