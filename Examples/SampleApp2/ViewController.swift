import Combine
import ListDiffUI
import UIKit

final class ViewController: UIViewController {

  private lazy var collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .vertical
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    collectionView.contentInset = .init(top: 0, left: 32, bottom: 0, right: 32)
    return collectionView
  }()

  private lazy var dataSource: ListDiffDataSource = {
    let dataSource = ListDiffDataSource(collectionView: collectionView)
    return dataSource
  }()

  private let modelProvider = ModelProvider()
  private var anyCancellable: AnyCancellable?

  override func viewDidLoad() {
    view.backgroundColor = .white

    view.addSubview(collectionView)
    collectionView.frame = view.bounds
    collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    anyCancellable = modelProvider.dataModelPublisher.sink { _ in
    } receiveValue: { [weak self] dataModel in
      guard let self = self else {
        return
      }
      self.dataSource.setRootSection(self.buildSection(dataModel))
    }
  }

  private func buildSection(_ dataModel: DataModel) -> Section {
    return CompositeSection(
      ListRenderSection(dataModel.items) {
        switch $0.item {
        case let .text(text):
          return ListSection<
            TextViewModel,
            TextCellController
          >(TextViewModel(identifier: $0.id, text: text))
        case let .textWithImage(text, image):
          return ListSection<
            TextWithImageViewModel,
            TextWithImageCellController
          >(TextWithImageViewModel(identifier: $0.id, text: text, image: image))
        }
      },
      dataModel.isLoading
        ? ListSection<
          LoadingSpinnerViewModel,
          LoadingSpinnerCellController
        >(LoadingSpinnerViewModel(height: 40)) : nil,
      !dataModel.isLoading && dataModel.hasMore
        ? ListSection<
          EndOfListViewModel,
          EndOfListCellController
        >(EndOfListViewModel(), delegate: .init(object: self)) : nil
    )
  }
}

extension ViewController: EndOfListCellControllerDelegate {

  func didTapLoadMore() {
    modelProvider.loadMore()
  }
}

extension ItemModel: Identifiable {

  var identifier: String {
    id
  }
}
