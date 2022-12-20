import UIKit

public protocol ListCellControllerWithDelegate {
  associatedtype DelegateType
  var delegate: DelegateType? { get }
}

extension ListCellControllerWithDelegate where Self: AnyListCellController {

  public var delegate: DelegateType? {
    anyDelegate.object as? DelegateType
  }
}

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

  public func updateState(_ viewState: ListViewStateType) {
    self.viewState = viewState
    if !updatingViewModel {
      updateCell(shouldInvalidateLayout: true)
    }
  }

  open override func itemSize(containerSize: CGSize) -> CGSize {
    return .zero
  }

  open func configureCell(cell: ListCellType) {
  }

  open func didAppear(cell: ListCellType) {
  }

  // cell is optional in this case since the cell might already be reused.
  open func willDisappear(cell: ListCellType?) {
  }

  open func didFullyAppear(cell: ListCellType) {
  }

  // cell is optional in this case since the cell might already be reused.
  open func willPartiallyDisappear(cell: ListCellType?) {
  }

  open func didMount(onCell cell: ListCellType) {
  }

  open func willUnmount(onCell cell: ListCellType) {
  }

  open func didUpdateViewModel(oldViewModel: ListViewModelType) {
  }

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

open class AnyListCellController {

  class var cellType: ListCell.Type {
    fatalError("Must be provided by subclass")
  }

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
