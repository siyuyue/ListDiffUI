import Foundation

struct ListDiffDataModel {
  var identifier: String
  var viewModel: ListViewModel
  var delegate: WeakAnyObject
  var controllerType: AnyListCellController.Type
}

/// Base class and available for subclassing.
///
/// Section provides an intuitive interface for developers to describe how the UICollectionView should look like, that supports heterogeneity by design.
///
/// For example:
///
/// ```swift
/// CompositeSection(
///   ListSection<
///     Bool, LoadingSpinnerController
///   >(isLoading) {
///     $0 ? LoadingSpinnerViewModel() : nil
///   },
///   ListSection<
///     ItemViewModel, ItemCellController
///   >(items)
/// )
/// ```
///
/// descibes an optional loading spinner cell, and a list of items.
///
/// For its concrete implementations, ``CompositeSection`` is used for composing multiple child sections.
/// ``ListSection`` is used for declaring a list of homogeneous cells.
/// ``ListRenderSection`` is used for declaring a list of heterogenous cells.
/// It is also available for subclassing.
///
/// Note that it's ``Section/build()`` function will be called off main thread if asynchronous diffing is enabled for ``ListSectionDataSource``.
///
open class Section {

  var identifier: String {
    String(describing: self)
  }

  func build() -> [ListDiffDataModel] {
    fatalError("Subclass must provide its own implementation")
  }
}

/// Supports composing multiple Sections.
///
/// Example:
/// ```swift
/// CompositeSection(
///   ListSection<
///     Bool, LoadingSpinnerController
///   >(isLoading) {
///     $0 ? LoadingSpinnerViewModel() : nil
///   },
///   ListSection<
///     ItemViewModel, ItemCellController
///   >(items)
/// )
/// ```
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

  /// Initialize from a generic array of models.
  ///
  /// - Parameters:
  ///   - models: Generic model array.
  ///   - delegate: Delegate object for ``ListCellController``.
  ///   - transform: A transform function that transforms from model type T to ListViewModel
  ///     may run on background thread if asynchronous diffing is enabled for ``ListSectionDataSource``.
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

extension ListSection {

  /// Convenience init for building a single cell.
  public convenience init(
    _ model: T, delegate: WeakAnyObject = .none,
    transform: @escaping (T) -> ListCellControllerType.ListViewModelType?
  ) {
    self.init([model], delegate: delegate, transform: transform)
  }
}

extension ListSection where T == ListCellControllerType.ListViewModelType {

  /// Convenience init for when input type is ListViewModelType, where transform function is omitted.
  public convenience init(_ model: T, delegate: WeakAnyObject = .none) {
    self.init([model], delegate: delegate) { $0 }
  }

  /// Convenience init for building a single cell, when input type is ListViewModelType.
  public convenience init(_ models: [T], delegate: WeakAnyObject = .none) {
    self.init(models, delegate: delegate) { $0 }
  }
}

/// Supports building a list of heterogeneous cells.
public final class ListRenderSection<T: Identifiable>: Section {

  private let models: [T]
  private let transform: (T) -> Section?

  /// Initialize from a generic array of models.
  ///
  /// - Parameters:
  ///   - models: Generic model array. T must conform to ``Identifiable``.
  ///   - transform: A transform function that transforms from model type T to Section.
  ///     may run on background thread if asynchronous diffing is enabled for ``ListSectionDataSource``.
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
