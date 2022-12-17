import Foundation

struct ListDiffDataModel {
  var identifier: String
  var viewModel: ListViewModel
  var delegate: WeakAnyObject
  var controllerType: AnyListCellController.Type
}

/// Base class and available for subclassing.
open class Section {

  var identifier: String {
    String(describing: self)
  }

  func build() -> [ListDiffDataModel] {
    fatalError("Subclass must provide its own implementation")
  }
}

/// Supports composing multiple Sections.
public final class CompositeSection: Section {

  private let s: [Section?]

  public init(_ s: Section?...) {
    self.s = s
  }

  override func build() -> [ListDiffDataModel] {
    return s.enumerated().flatMap { (index, section) -> [ListDiffDataModel] in
      guard let section = section else {
        return []
      }
      return section.build().map { v in
        var viewDataModel = v
        viewDataModel.identifier = [section.identifier, String(index), v.identifier].joined(
          separator: "~")
        return viewDataModel
      }
    }
  }
}

/// Supports building a list of homogeneous cells.
public final class ListSection<
  T,
  ListCellControllerType: AnyListCellController & ListCellControllerViewModelProviding
>: Section {

  private let models: [T]
  private let transform: (T) -> ListCellControllerType.ListViewModelType?
  private let delegate: WeakAnyObject

  public init(
    _ models: [T], delegate: WeakAnyObject = .none,
    transform: @escaping (T) -> ListCellControllerType.ListViewModelType?
  ) {
    self.models = models
    self.delegate = delegate
    self.transform = transform
  }

  override func build() -> [ListDiffDataModel] {
    return models.compactMap { transform($0) }.map {
      ListDiffDataModel(
        identifier: $0.identifier,
        viewModel: $0,
        delegate: delegate,
        controllerType: ListCellControllerType.self
      )
    }
  }
}

/// Convenience init for building a single cell.
extension ListSection {

  public convenience init(
    _ model: T, delegate: WeakAnyObject = .none,
    transform: @escaping (T) -> ListCellControllerType.ListViewModelType?
  ) {
    self.init([model], delegate: delegate, transform: transform)
  }
}

/// Convenience init for when input type is ListViewModelType.
extension ListSection where T == ListCellControllerType.ListViewModelType {

  public convenience init(_ model: T, delegate: WeakAnyObject = .none) {
    self.init([model], delegate: delegate) { $0 }
  }

  public convenience init(_ models: [T], delegate: WeakAnyObject = .none) {
    self.init(models, delegate: delegate) { $0 }
  }
}

/// Supports building a list of heterogeneous cells.
public final class ListRenderSection<T: Identifiable>: Section {

  private let models: [T]
  private let transform: (T) -> Section?

  public init(_ models: [T], transform: @escaping (T) -> Section?) {
    self.models = models
    self.transform = transform
  }

  override func build() -> [ListDiffDataModel] {
    return models.flatMap { model -> [ListDiffDataModel] in
      guard let section = transform(model) else {
        return []
      }
      return section.build().map {
        ListDiffDataModel(
          identifier: [model.identifier, $0.identifier].joined(separator: "~"),
          viewModel: $0.viewModel,
          delegate: $0.delegate,
          controllerType: $0.controllerType
        )
      }
    }
  }
}
