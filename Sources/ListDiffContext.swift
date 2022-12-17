import Foundation

public final class ListDiffContext {

  private let objects: [ObjectIdentifier: AnyObject]

  public init(objects: [AnyObject]) {
    var objectsDictionary: [ObjectIdentifier: AnyObject] = [:]
    for object in objects {
      let identifier = ObjectIdentifier(type(of: object))
      precondition(objectsDictionary[identifier] == nil)
      objectsDictionary[identifier] = object
    }
    self.objects = objectsDictionary
  }

  public func object<T>(type: T.Type) -> T? {
    return objects[ObjectIdentifier(type)] as? T
  }

  public func object<T>() -> T? {
    return objects[ObjectIdentifier(T.self)] as? T
  }
}
