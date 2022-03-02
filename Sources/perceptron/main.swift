import Foundation
import ArgumentParser
import Progress

struct Perceptron: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "Perceptron",
        abstract: "Simple Version of a neural network",
        subcommands: [Test.self, Generate.self, Train.self])
}

struct Test: ParsableCommand {
    func run() {
        let data = dataModel(width: 10, height: 10, countImageImages: 20)
        data.testError()
    }
}

struct Generate: ParsableCommand {
    @Argument(help: "literal")
    private var count: Int
    func run() {
        for _ in 0...10{
            let image = InputImage(rectangle: false, width: 10, height: 10)
            image.printImage()
        }
    }
}

struct Train: ParsableCommand {
    @Argument(help: "number of passes")
    private var passes: Int
	
	@Flag(name: [.long, .short],help: "verbose")
	private var verbose: Bool = false
	
    func run() {
        let data = dataModel(width: 10, height: 10, countImageImages: 1000)
        print("before:")
        data.testError()
		if(verbose){
			for _ in (0..<passes){
				data.train(passes: 1)
				data.testError()
				data.neuralNet.printWeights()
			}
		}else{
			for _ in Progress(0..<passes){
				data.train(passes: 1)
			}
		}
        print("after:")
        data.testError()
    }
}

Perceptron.main()
