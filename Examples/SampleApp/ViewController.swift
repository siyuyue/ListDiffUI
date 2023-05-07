import ListDiffUI
import UIKit

final class ViewController: UIViewController {

  private lazy var collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .vertical
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    return collectionView
  }()

  private lazy var dataSource: ListDiffDataSource = {
    let dataSource = ListDiffDataSource(
      collectionView: collectionView, applyUpdatesAsync: true, contextObjects: logger)
    return dataSource
  }()

  private struct ItemWithCount {
    var id: String
    var item: String
    var count: Int
  }

  private var items: [ItemWithCount] = [] {
    didSet {
      updateSectionDataSource()
    }
  }

  private let logger = HelloWorldLogger()

  override func viewDidLoad() {
    view.backgroundColor = .white

    view.addSubview(collectionView)
    collectionView.frame = view.bounds
    collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    items = []
  }

  private func updateSectionDataSource() {
    dataSource.setRootSection(
      CompositeSection(
        ListSection<
          ItemWithCount, LabelViewCellController
        >(items, delegate: .init(object: self)) {
          LabelViewModel(identifier: $0.id, item: $0.item, count: $0.count)
        },
        ListSection<
          ButtonViewModel, ButtonCellController
        >(
          ButtonViewModel(
            title: "Add More",
            didTap: { [weak self] in
              guard let self = self else { return }
              self.addMore()
            })
        ),
        ListSection<
          ButtonViewModel, ButtonCellController
        >(
          ButtonViewModel(
            title: "Double All",
            didTap: { [weak self] in
              guard let self = self else { return }
              self.items = self.items.map {
                ItemWithCount(id: $0.id, item: $0.item, count: $0.count * 2)
              }
            })
        )
      ))
  }

  private func addMore() {
    items.append(ItemWithCount(id: "\(items.count)", item: "Item \(items.count)", count: 1))
  }
}

extension ViewController: LabelCellControllerDelegate {

  func didTapPlus(viewModel: LabelViewModel) {
    items = items.map({ item in
      if item.id == viewModel.identifier {
        return ItemWithCount(id: item.id, item: item.item, count: item.count + 1)
      }
      return item
    })
  }

  func didTapMinus(viewModel: LabelViewModel) {
    items = items.map({ item in
      if item.id == viewModel.identifier {
        return ItemWithCount(id: item.id, item: item.item, count: item.count - 1)
      }
      return item
    })
  }
}

final class HelloWorldLogger {

  func log(message: String) {
    NSLog(message)
  }
}
