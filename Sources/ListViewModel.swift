import Foundation

public protocol Identifiable {

  var identifier: String { get }
}

public protocol ListViewModel: Identifiable {

  func isEqual(to: ListViewModel) -> Bool
}

extension ListViewModel where Self: Equatable {

  public func isEqual(to: ListViewModel) -> Bool {
    guard let other = to as? Self else { return false }
    return self == other
  }
}

public struct ListViewModelNone: ListViewModel, Equatable {

  public var identifier: String {
    "ListViewModelNone"
  }

  public static let none = ListViewModelNone()
}

@propertyWrapper public struct EquatableNoop<T>: Equatable {

  public var wrappedValue: T

  public init(wrappedValue: T) {
    self.wrappedValue = wrappedValue
  }

  public static func == (lhs: EquatableNoop<T>, rhs: EquatableNoop<T>) -> Bool {
    return true
  }
}
