import Foundation

/// Used for passing in dependencies from ``ListDiffDataSource/init(collectionView:appleUpdatesAsync:contextObjects:)``
/// and available on ``AnyListCellController/context`` property.
///
/// Objects are stored in a dictonary with `ObjectIdentifier(type(of: object))` as its key/
/// Therefore you can not pass in multiple instances of the same class.
///
/// Main use case for context object is to make certain dependencies available in ``ListCellController``,
/// and not having to pass them in with ViewModels.
///
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
