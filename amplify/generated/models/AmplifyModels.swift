// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "16cbb30c5cbd19e5aa535d9c6c01e134"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: BuyerZ.self)
  }
}