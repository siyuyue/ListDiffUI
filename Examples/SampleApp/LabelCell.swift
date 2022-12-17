import ListDiffUI
import UIKit

struct LabelViewModel: ListViewModel, Equatable {
  var identifier: String
  var item: String
  var count: Int
}

struct LabelViewState: ListViewState {
  var expanded = false
}

final class LabelCell: ListCell {

  lazy var label: UILabel = {
    let label = UILabel()
    contentView.addSubview(label)
    contentView.backgroundColor = .lightGray
    return label
  }()

  lazy var expandButton: UIButton = {
    let button = UIButton()
    contentView.addSubview(button)
    button.backgroundColor = .green
    return button
  }()

  lazy var plusButton: UIButton = {
    let button = UIButton()
    contentView.addSubview(button)
    button.backgroundColor = .green
    button.setTitle("+", for: .normal)
    return button
  }()

  lazy var minusButton: UIButton = {
    let button = UIButton()
    contentView.addSubview(button)
    button.backgroundColor = .green
    button.setTitle("-", for: .normal)
    return button
  }()
}

protocol LabelCellControllerDelegate {
  func didTapPlus(viewModel: LabelViewModel)
  func didTapMinus(viewModel: LabelViewModel)
}

final class LabelViewCellController: ListCellController<
  LabelViewModel,
  LabelViewState,
  LabelCell
>, ListCellControllerWithDelegate
{
  typealias DelegateType = LabelCellControllerDelegate

  override func itemSize(containerSize: CGSize) -> CGSize {
    return CGSize(width: containerSize.width, height: viewState.expanded ? 120 : 60)
  }

  override func configureCell(cell: LabelCell) {
    cell.label.text = "\(viewModel.item) x \(viewModel.count)"
    cell.expandButton.setTitle(viewState.expanded ? "Collapse" : "Expand", for: .normal)
    cell.minusButton.isHidden = viewModel.count == 0
  }

  override func cellDidLayoutSubviews(cell: LabelCell) {
    cell.label.frame = CGRect(x: 16, y: cell.contentView.bounds.midY - 10, width: 100, height: 20)
    cell.expandButton.frame = CGRect(
      x: cell.contentView.bounds.maxX - 96, y: cell.label.frame.minY, width: 80, height: 20)
    cell.minusButton.frame = CGRect(
      x: cell.expandButton.frame.minX - 36, y: cell.label.frame.minY, width: 20, height: 20)
    cell.plusButton.frame = CGRect(
      x: cell.minusButton.frame.minX - 36, y: cell.label.frame.minY, width: 20, height: 20)
  }

  override func didMount(onCell cell: LabelCell) {
    cell.expandButton.removeTarget(nil, action: nil, for: .touchUpInside)
    cell.expandButton.addTarget(self, action: #selector(didTapExpand), for: .touchUpInside)

    cell.minusButton.removeTarget(nil, action: nil, for: .touchUpInside)
    cell.minusButton.addTarget(self, action: #selector(didTapMinus), for: .touchUpInside)

    cell.plusButton.removeTarget(nil, action: nil, for: .touchUpInside)
    cell.plusButton.addTarget(self, action: #selector(didTapPlus), for: .touchUpInside)
  }

  override func didAppear() {
    context.object(type: HelloWorldLogger.self)?.log(message: "\(viewModel.identifier) didAppear")
  }

  override func willDisappear() {
    context.object(type: HelloWorldLogger.self)?.log(
      message: "\(viewModel.identifier) willDisappear")
  }

  override func didFullyAppear() {
    context.object(type: HelloWorldLogger.self)?.log(
      message: "\(viewModel.identifier) didFullyAppear")
  }

  override func willPartiallyDisappear() {
    context.object(type: HelloWorldLogger.self)?.log(
      message: "\(viewModel.identifier) willPartiallyDisappear")
  }

  @objc
  private func didTapExpand() {
    var state = viewState
    state.expanded = !state.expanded
    updateState(state)
  }

  @objc
  private func didTapPlus() {
    delegate?.didTapPlus(viewModel: viewModel)
  }

  @objc
  private func didTapMinus() {
    delegate?.didTapMinus(viewModel: viewModel)
  }
}
