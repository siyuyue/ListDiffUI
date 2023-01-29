import ListDiffUI
import UIKit

struct EndOfListViewModel: ListViewModel & Equatable {

  var identifier: String {
    "EndOfList"
  }
}

final class EndOfListCell: ListCell {

  lazy var button: UIButton = {
    let button = UIButton()
    contentView.addSubview(button)
    button.frame = CGRect(x: contentView.bounds.midX - 80, y: 5, width: 160, height: 30)
    button.backgroundColor = .blue
    button.setTitle("Load More", for: .normal)
    return button
  }()
}

protocol EndOfListCellControllerDelegate {
  func didTapLoadMore()
}

final class EndOfListCellController: ListCellController<
  EndOfListViewModel,
  ListViewStateNone,
  EndOfListCell
>, ListCellControllerWithDelegate
{

  typealias DelegateType = EndOfListCellControllerDelegate

  override func itemSize(containerSize: CGSize) -> CGSize {
    return CGSize(width: containerSize.width, height: 40)
  }

  override func didMount(onCell cell: EndOfListCell) {
    cell.button.removeTarget(nil, action: nil, for: .allEvents)
    cell.button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
  }

  @objc
  private func didTap() {
    delegate?.didTapLoadMore()
  }
}
