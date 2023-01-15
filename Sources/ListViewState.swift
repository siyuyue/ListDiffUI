import Foundation

/// ViewState protocol.
///
public protocol ListViewState {

  init()
}

/// A predefined concrete ViewState struct to represent an empty ViewState.
///
public struct ListViewStateNone: ListViewState {

  public init() {
  }
}
