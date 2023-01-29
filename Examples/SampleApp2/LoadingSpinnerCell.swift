import ListDiffUI
import UIKit

struct LoadingSpinnerViewModel: ListViewModel, Equatable {

  var identifier: String {
    "loadingSpinner"
  }

  var height: CGFloat
}

final class LoadingSpinnerCell: ListCell {

  lazy var loadingSpinner: UIActivityIndicatorView = {
    var loadingSpinner = UIActivityIndicatorView()
    contentView.addSubview(loadingSpinner)
    return loadingSpinner
  }()
}

final class LoadingSpinnerCellController: ListCellController<
  LoadingSpinnerViewModel,
  ListViewStateNone,
  LoadingSpinnerCell
>
{

  override func itemSize(containerSize: CGSize) -> CGSize {
    return CGSize(width: containerSize.width, height: viewModel.height)
  }

  override func cellDidLayoutSubviews(cell: LoadingSpinnerCell) {
    cell.loadingSpinner.frame = cell.contentView.bounds
  }

  override func didAppear(cell: LoadingSpinnerCell) {
    cell.loadingSpinner.startAnimating()
  }

  override func willDisappear(cell: LoadingSpinnerCell?) {
    cell?.loadingSpinner.stopAnimating()
  }
}
