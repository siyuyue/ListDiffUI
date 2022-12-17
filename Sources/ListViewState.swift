import Foundation

public protocol ListViewState {

  init()
}

public struct ListViewStateNone: ListViewState {

  public init() {
  }
}
