import UIKit

/// Extend this protocol from ListCellController subclass and provide the associatedtype to use the delegate pattern.
/// The same delegate passed in from ``ListSection`` will be available to the ListCellController as the `delegate` property.
public protocol ListCellControllerWithDelegate {
  associatedtype DelegateType
  var delegate: DelegateType? { get }
}

extension ListCellControllerWithDelegate where Self: AnyListCellController {

  public var delegate: DelegateType? {
    anyDelegate.object as? DelegateType
  }
}

/// Used to wrap AnyObject with a weak reference.
public final class WeakAnyObject {

  public static var none = WeakAnyObject(object: nil)

  weak var object: AnyObject?

  public init(object: AnyObject?) {
    self.object = object
  }
}

public protocol ListCellControllerViewModelProviding {

  associatedtype ListViewModelType: ListViewModel
}

/// Generic cell controller class.
open class ListCellController<
  ListViewModelType: ListViewModel & Equatable,
  ListViewStateType: ListViewState,
  ListCellType: ListCell
>: AnyListCellController {

  public private(set) var viewModel: ListViewModelType

  public private(set) var viewState: ListViewStateType

  override class var cellType: ListCell.Type {
    ListCellType.self
  }

  private var updatingViewModel = false
  private var didLayoutSubiewsWhenInvalidatingLayout = false

  /// Designated initializer.
  required public init(
    viewModel: ListViewModel,
    delegate: WeakAnyObject,
    context: ListDiffContext
  ) {
    let viewModel = viewModel as! ListViewModelType
    self.viewModel = viewModel
    self.viewState = ListViewStateType.init()
    super.init(viewModel: viewModel, delegate: delegate, context: context)
  }

  /// Used to update ViewState.
  ///
  /// Calling it will trigger ``ListCellController/configureCell(cell:)`` as long as the controller has a mounted cell.
  ///
  public func updateState(_ viewState: ListViewStateType) {
    self.viewState = viewState
    if !updatingViewModel {
      updateCell(shouldInvalidateLayout: true)
    }
  }

  /// Subclassing point. Provide cell size based on the container size (collection view size inset by content edge insets).
  ///
  /// If the collection view can change size, you need to implement proper layout invalidation logic in the flow layout object,
  /// in order to make sure this method is invoked to retrieve the updated cell size.
  ///
  open override func itemSize(containerSize: CGSize) -> CGSize {
    return .zero
  }

  /// Subclassing point. Configure cell based on ViewModel and ViewState.
  ///
  /// It will be invoked when ViewModel or ViewState updates, and when a cell is mounted.
  ///
  open func configureCell(cell: ListCellType) {
  }

  /// Subclassing point. Called when cell appears within collection view's bounds.
  open func didAppear(cell: ListCellType) {
  }

  /// Subclassing point. Called when cell fully disappears from collection view's bounds.
  ///
  /// Cell is optional, since the cell might already be reused.
  ///
  open func willDisappear(cell: ListCellType?) {
  }

  /// Subclassing point. Called when cell fully appears within collection view's bounds.
  open func didFullyAppear(cell: ListCellType) {
  }

  /// Subclassing point. Called when cell partially disappears from collection view's bounds.
  ///
  /// Cell is optional, since the cell might already be reused.
  ///
  open func willPartiallyDisappear(cell: ListCellType?) {
  }

  /// Subclassing point.
  open func didMount(onCell cell: ListCellType) {
  }

  /// Subclassing point.
  open func willUnmount(onCell cell: ListCellType) {
  }

  /// Subclassing point. Invoked when ViewModel updates.
  ///
  /// You may perform logic that updates ViewState here.
  ///
  open func didUpdateViewModel(oldViewModel: ListViewModelType) {
  }

  /// Subclassing point. Update cell layout based on ViewModel and ViewState.
  open func cellDidLayoutSubviews(cell: ListCellType) {
  }

  override func didAppear() {
    didAppear(cell: cell as! ListCellType)
  }

  override func willDisappear() {
    willDisappear(cell: cell as? ListCellType)
  }

  override func didFullyAppear() {
    didFullyAppear(cell: cell as! ListCellType)
  }

  override func willPartiallyDisappear() {
    willPartiallyDisappear(cell: cell as? ListCellType)
  }

  override func viewModelUntyped() -> ListViewModel {
    viewModel
  }

  override func viewStateUntyped() -> ListViewState {
    viewState
  }

  override func didMountInternal(onCell cell: ListCell) {
    let cell = cell as! ListCellType
    updateCell(shouldInvalidateLayout: false)
    didMount(onCell: cell)
  }

  override func willUnmountInternal(onCell cell: ListCell) {
    let cell = cell as! ListCellType
    willUnmount(onCell: cell)
  }

  override func setViewModelInternal(viewModel: ListViewModel) {
    let viewModel = viewModel as! ListViewModelType
    guard viewModel != self.viewModel else {
      return
    }
    let oldViewModel = self.viewModel
    self.viewModel = viewModel
    updatingViewModel = true
    didUpdateViewModel(oldViewModel: oldViewModel)
    updatingViewModel = false
    updateCell(shouldInvalidateLayout: true)
  }

  override func cellDidLayoutSubviews() {
    guard let cell = cell else {
      return
    }
    didLayoutSubiewsWhenInvalidatingLayout = true
    cellDidLayoutSubviews(cell: cell as! ListCellType)
  }

  func updateCell(shouldInvalidateLayout: Bool) {
    guard let cell = cell else {
      return
    }
    didLayoutSubiewsWhenInvalidatingLayout = false
    if shouldInvalidateLayout {
      layoutInvalidateHandler?(cell)
    }
    configureCell(cell: cell as! ListCellType)
    if !didLayoutSubiewsWhenInvalidatingLayout {
      cellDidLayoutSubviews(cell: cell as! ListCellType)
    }
  }
}

extension ListCellController: ListCellControllerViewModelProviding {

  public typealias ListViewModelType = ListViewModelType
}

/// Type-erased base class of ``ListCellController``. Subclass ``ListCellController`` instead.
open class AnyListCellController {

  class var cellType: ListCell.Type {
    fatalError("Must be provided by subclass")
  }

  /// Used for accessing context objects passed in from ``ListDiffDataSource/init(collectionView:applyUpdatesAsync:contextObjects:)``.
  public let context: ListDiffContext

  weak var cell: ListCell? {
    willSet {
      if let cell = cell {
        willUnmountInternal(onCell: cell)
      }
    }
    didSet {
      if let cell = cell {
        didMountInternal(onCell: cell)
      }
    }
  }

  var anyDelegate: WeakAnyObject

  var layoutInvalidateHandler: ((UICollectionViewCell) -> Void)?

  required public init(
    viewModel: ListViewModel,
    delegate: WeakAnyObject,
    context: ListDiffContext
  ) {
    self.anyDelegate = delegate
    self.context = context
  }

  open func itemSize(containerSize: CGSize) -> CGSize {
    fatalError()
  }

  func didAppear() {
    fatalError()
  }

  func willDisappear() {
    fatalError()
  }

  func didFullyAppear() {
    fatalError()
  }

  func willPartiallyDisappear() {
    fatalError()
  }

  func viewModelUntyped() -> ListViewModel {
    fatalError()
  }

  func viewStateUntyped() -> ListViewState {
    fatalError()
  }

  func didMountInternal(onCell cell: ListCell) {
    fatalError()
  }

  func willUnmountInternal(onCell cell: ListCell) {
    fatalError()
  }

  func setViewModelInternal(viewModel: ListViewModel) {
    fatalError()
  }

  func cellDidLayoutSubviews() {
    fatalError()
  }
}
