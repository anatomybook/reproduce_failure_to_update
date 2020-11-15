// swiftlint:disable all
import Amplify
import Foundation

extension BuyerZ {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case remarks
    case name
    case owner
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let buyerZ = BuyerZ.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "BuyerZS"
    
    model.fields(
      .id(),
      .field(buyerZ.remarks, is: .optional, ofType: .string),
      .field(buyerZ.name, is: .optional, ofType: .string),
      .field(buyerZ.owner, is: .optional, ofType: .string)
    )
    }
}