import ListDiff
import UIKit

private let cellAppearanceUpdateInterval: CFTimeInterval = 0.1

/// Data source object to provide data to UICollectionView.
///
/// To use ListDiffUI, create an instance of ListDiffDataSource with the corresponding UICollectionView.
/// ListDiffDataSource will sets itself as both delegate and dataSource of the UICollectionView.
/// Call ``ListDiffDataSource/setRootSection(_:animate:completion:)`` on the data source object to update the view model.
///
public final class ListDiffDataSource: NSObject {

  /// Forwards calls from the delegate of the UICollectionView.
  ///
  /// ListDiffDataSource instance will set itself as the delegate of the collection view.
  /// If you need to be the delegate of the UICollectionView as well, set your instance as the collectionViewDelegate instead.
  ///
  public weak var collectionViewDelegate: UICollectionViewDelegate?

  private let collectionView: UICollectionView
  private let context: ListDiffContext
  private let queue: DispatchQueue
  private let applyUpdatesAsync: Bool

  private var appearedCellIdentifiers = Set<String>()
  private var fullyAppearedCellIdentifiers = Set<String>()
  private var cellControllers: [String: AnyListCellController] = [:]
  private var lastAppearanceUpdateTime: CFTimeInterval = .zero
  private var registeredReuseIdentifiers = Set<String>()
  private var viewDataModels: [ListDiffDataModel] = []
  private var viewDataModelsOnQueue: [ListDiffDataModel] = []

  /// Designated initializer of ListDiffDataSource.
  ///
  /// - Parameters:
  ///   - collectionView: UICollectionView's layout must be an instance of UICollectionFlowLayout (or its subclass), as it implements
  ///     `collectionView(_:layout:sizeForItemAt:)` of UICollectionViewDelegateFlowLayout.
  ///   - applyUpdatesAsync: If true, diffing will be performed asynchronously on a background thread.
  ///   - contextObjects: A list of objects passed in here will be available to use inside ``ListCellController``.
  ///     This is a way to pass in dependencies (e.g. logger) so that you don't have to piggyback them on ViewModels.
  ///
  public init(collectionView: UICollectionView, applyUpdatesAsync: Bool = false, contextObjects: AnyObject...) {
    precondition(collectionView.collectionViewLayout is UICollectionViewFlowLayout)
    self.collectionView = collectionView
    self.applyUpdatesAsync = applyUpdatesAsync
    self.context = ListDiffContext(objects: contextObjects)
    queue = applyUpdatesAsync ? DispatchQueue(label: "ListDiffui.ListDiffdatasource", qos: .default) : .main
    super.init()
    collectionView.dataSource = self
    collectionView.delegate = self
  }

  /// Update view model with Section.
  ///
  /// ``Section`` provides a descriptive interface to describe the structure of the collection that supports heterogenity by design.
  ///
  /// - Parameters:
  ///   - section: Root section that describes the entire collection.
  ///   - animated: Whether diff update (insert/deletion/update) will be animated or not.
  ///   - completion: Completion block that gets called after diff update.
  ///
  public func setRootSection(_ section: Section?, animate: Bool = false, completion: (() -> Void)? = nil) {
    if applyUpdatesAsync {
      queue.async {
        let diff = self.computeDiff(section: section)
        DispatchQueue.main.async {
          self.applyUpdates(diffResult: diff.0, newDataModels: diff.1, animate: animate)
          completion?()
        }
      }
    } else {
      let diff = computeDiff(section: section)
      applyUpdates(diffResult: diff.0, newDataModels: diff.1, animate: animate)
      completion?()
    }
  }

  private func computeDiff(section: Section?) -> (List.Result, [ListDiffDataModel]) {
    dispatchPrecondition(condition: .onQueue(queue))

    let newDataModels = section?.build() ?? []
    let diffResult = List.diffing(
      oldArray: self.viewDataModelsOnQueue,
      newArray: newDataModels)
    self.viewDataModelsOnQueue = newDataModels
    return (diffResult, newDataModels)
  }

  private func applyUpdates(diffResult: List.Result, newDataModels: [ListDiffDataModel], animate: Bool) {
    dispatchPrecondition(condition: .onQueue(.main))

    guard diffResult.changeCount > 0 else {
      return
    }
    // Apply diff updates.
    var identifiersToDelete = Set<String>()
    diffResult.deletes.forEach { i in
      identifiersToDelete.insert(self.viewDataModels[i].identifier)
    }
    diffResult.updates.forEach { index in
      let identifier = self.viewDataModels[index].identifier

      guard let controller = self.cellControllers[identifier],
        let newIndex = diffResult.newIndexFor(identifier: identifier)
      else {
        fatalError()
      }
      controller.setViewModelInternal(viewModel: newDataModels[newIndex].viewModel)
    }
    let batchUpdates = {
      self.collectionView.performBatchUpdates {
        self.viewDataModels = newDataModels
        self.collectionView.deleteItems(
          at: diffResult.deletes.map { IndexPath(item: $0, section: 0) })
        self.collectionView.insertItems(
          at: diffResult.inserts.map { IndexPath(item: $0, section: 0) })
        for move in diffResult.moves {
          self.collectionView.moveItem(
            at: IndexPath(item: move.from, section: 0),
            to: IndexPath(item: move.to, section: 0))
        }
      }
    }
    if animate {
      UIView.performWithoutAnimation(batchUpdates)
    } else {
      batchUpdates()
    }
    identifiersToDelete.forEach { cellControllers[$0] = nil }
    updateCellAppearance()
  }

  private func cellController(_ viewDataModel: ListDiffDataModel)
    -> AnyListCellController
  {
    if let controller = cellControllers[viewDataModel.identifier] {
      return controller
    }
    let controller = viewDataModel.controllerType.init(
      viewModel: viewDataModel.viewModel,
      delegate: viewDataModel.delegate,
      context: context
    )
    controller.layoutInvalidateHandler = { [weak self] cell in
      guard let self = self, let indexPath = self.collectionView.indexPath(for: cell) else {
        return
      }
      let layoutInvalidation = UICollectionViewFlowLayoutInvalidationContext()
      layoutInvalidation.invalidateItems(at: [indexPath])
      self.collectionView.performBatchUpdates {
        self.collectionView.collectionViewLayout.invalidateLayout(with: layoutInvalidation)
      }
      self.updateCellAppearance()
    }
    cellControllers[viewDataModel.identifier] = controller
    return controller
  }

  private func updateCellAppearance() {
    var newAppearedCellIdentifiers = Set<String>()
    var newFullyAppearedCellIdentifiers = Set<String>()
    let contentRect = collectionView.bounds
    guard contentRect.size.width > 0 && contentRect.size.height > 0 else {
      return
    }
    collectionView.visibleCells.forEach { cell in
      guard let index = collectionView.indexPath(for: cell)?.item else {
        return
      }
      if contentRect.intersects(cell.frame) {
        newAppearedCellIdentifiers.insert(self.viewDataModels[index].identifier)
      }
      if contentRect.contains(cell.frame) {
        newFullyAppearedCellIdentifiers.insert(self.viewDataModels[index].identifier)
      }
    }

    for identifier in fullyAppearedCellIdentifiers.subtracting(newFullyAppearedCellIdentifiers) {
      cellControllers[identifier]?.willPartiallyDisappear()
    }
    for identifier in appearedCellIdentifiers.subtracting(newAppearedCellIdentifiers) {
      cellControllers[identifier]?.willDisappear()
    }
    for identifier in newAppearedCellIdentifiers.subtracting(appearedCellIdentifiers) {
      cellControllers[identifier]?.didAppear()
    }
    for identifier in newFullyAppearedCellIdentifiers.subtracting(fullyAppearedCellIdentifiers) {
      cellControllers[identifier]?.didFullyAppear()
    }
    appearedCellIdentifiers = newAppearedCellIdentifiers
    fullyAppearedCellIdentifiers = newFullyAppearedCellIdentifiers
  }
}

extension ListDiffDataSource: UICollectionViewDataSource {

  public func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection ListDiff: Int
  ) -> Int {
    return viewDataModels.count
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let viewDataModel = viewDataModels[indexPath.item]
    let reuseIdentifier = viewDataModel.controllerType.cellType.reuseIdentifier
    if !registeredReuseIdentifiers.contains(reuseIdentifier) {
      registeredReuseIdentifiers.insert(reuseIdentifier)
      collectionView.register(viewDataModel.controllerType.cellType, forCellWithReuseIdentifier: reuseIdentifier)
    }
    let cell =
      collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
      as! ListCell
    let controller = cellController(viewDataModel)
    if cell.controller !== controller {
      cell.controller?.cell = nil
      cell.controller = controller
    }
    if controller.cell !== cell {
      controller.cell?.controller = nil
      controller.cell = cell
    }
    controller.setViewModelInternal(viewModel: viewDataModel.viewModel)
    return cell
  }
}

extension ListDiffDataSource: UICollectionViewDelegate {

  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let time = CACurrentMediaTime()
    if time - lastAppearanceUpdateTime > cellAppearanceUpdateInterval {
      lastAppearanceUpdateTime = time
      updateCellAppearance()
    }
    collectionViewDelegate?.scrollViewDidScroll?(scrollView)
  }

  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    updateCellAppearance()
    collectionViewDelegate?.scrollViewWillBeginDragging?(scrollView)
  }

  public func scrollViewDidEndDragging(
    _ scrollView: UIScrollView,
    willDecelerate decelerate: Bool
  ) {
    updateCellAppearance()
    collectionViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
  }

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    updateCellAppearance()
    collectionViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
  }
}

extension ListDiffDataSource: UICollectionViewDelegateFlowLayout {

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let viewDataModel = viewDataModels[indexPath.item]
    let controller = cellController(viewDataModel)
    return controller.itemSize(
      containerSize: collectionView.frame.inset(
        by: collectionView.adjustedContentInset
      ).size)
  }
}

extension ListDiffDataModel: Equatable {

  static func == (lhs: ListDiffDataModel, rhs: ListDiffDataModel) -> Bool {
    return lhs.diffIdentifier == rhs.diffIdentifier
      && lhs.viewModel.isEqual(to: rhs.viewModel)
  }
}

extension ListDiffDataModel: Diffable {

  var diffIdentifier: AnyHashable {
    identifier
  }
}
