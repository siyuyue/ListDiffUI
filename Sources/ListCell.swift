import UIKit

/// Cell class that extends from UICollectionViewCell.
///
open class ListCell: UICollectionViewCell {

  class var reuseIdentifier: String {
    String(describing: self)
  }

  weak var controller: AnyListCellController?

  open override func layoutSubviews() {
    super.layoutSubviews()
    controller?.cellDidLayoutSubviews()
  }

  /// It is a deliberate choice to disallow overriding `prepareForReuse()`
  public override func prepareForReuse() {
  }
}
