import UIKit

open class ListCell: UICollectionViewCell {

  class var reuseIdentifier: String {
    String(describing: self)
  }

  weak var controller: AnyListCellController?

  open override func layoutSubviews() {
    super.layoutSubviews()
    controller?.cellDidLayoutSubviews()
  }

  public override func prepareForReuse() {
  }
}
