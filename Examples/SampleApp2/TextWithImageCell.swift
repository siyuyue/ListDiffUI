import ListDiffUI
import UIKit

struct TextWithImageViewModel: ListViewModel, Equatable {

  var identifier: String
  var text: String
  var image: UIImage
}

final class TextWithImageCell: ListCell {

  lazy var label: UILabel = {
    let label = UILabel()
    contentView.addSubview(label)
    label.frame = CGRect(x: 16, y: 80, width: contentView.bounds.width - 32, height: 40)
    return label
  }()

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    contentView.addSubview(imageView)
    imageView.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: 80)
    return imageView
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

final class TextWithImageCellController: ListCellController<
  TextWithImageViewModel,
  ListViewStateNone,
  TextWithImageCell
>
{

  override func itemSize(containerSize: CGSize) -> CGSize {
    return CGSize(width: containerSize.width, height: 120)
  }

  override func configureCell(cell: TextWithImageCell) {
    cell.label.text = viewModel.text
    cell.imageView.image = viewModel.image
  }
}
