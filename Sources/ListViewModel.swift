import Foundation

public protocol Identifiable {

  var identifier: String { get }
}

/// ViewModel protocol that defines interface for identity and equality check.
///
/// Identifiable protocol is used to uniquely identify ViewModels in the same ``ListSection``.
/// Items in different sections are not required to have unique identifiers.
///
/// You don't have to implement its ``isEqual(to:)`` function directly as long as the view model conforms to Equatable protocol.
/// The ``EquatableNoop`` annotation is also provided to ignore a certain property from equality check.
///
public protocol ListViewModel: Identifiable {

  func isEqual(to: ListViewModel) -> Bool
}

extension ListViewModel where Self: Equatable {

  public func isEqual(to: ListViewModel) -> Bool {
    guard let other = to as? Self else { return false }
    return self == other
  }
}

/// A predefined concrete ViewModel struct to represent an empty ViewModel.
///
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
