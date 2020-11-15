// swiftlint:disable all
import Amplify
import Foundation

public struct BuyerZ: Model {
  public let id: String
  public var remarks: String?
  public var name: String?
  public var owner: String?
  
  public init(id: String = UUID().uuidString,
      remarks: String? = nil,
      name: String? = nil,
      owner: String? = nil) {
      self.id = id
      self.remarks = remarks
      self.name = name
      self.owner = owner
  }
}