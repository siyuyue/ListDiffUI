import ListDiffUI
import UIKit

struct TextViewModel: ListViewModel, Equatable {

  var identifier: String
  var text: String
}

final class TextCell: ListCell {

  lazy var label: UILabel = {
    let label = UILabel()
    contentView.addSubview(label)
    label.frame = CGRect(x: 16, y: 0, width: contentView.bounds.width - 32, height: contentView.bounds.height)
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.backgroundColor = .lightGray
    contentView.layer.masksToBounds = true
    contentView.layer.cornerRadius = 8
  }

  required init?(coder: NSCoder) {
    fatalError("Unimplemented")
  }
}

final class TextCellController: ListCellController<
  TextViewModel,
  ListViewStateNone,
  TextCell
>
{

  override func itemSize(containerSize: CGSize) -> CGSize {
    return CGSize(width: containerSize.width, height: 40)
  }

  override func configureCell(cell: TextCell) {
    cell.label.text = viewModel.text
  }
}
