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

  /// Disallow overriding `prepareForReuse()`.
  ///
  /// For cell reuse logic, it should be handled in ``ListCellController``'s life cycle methods,
  /// e.g., ``ListCellController/didMount(onCell:)``, ``ListCellController/willUnmount(onCell:)``.
  public override func prepareForReuse() {
  }
}
