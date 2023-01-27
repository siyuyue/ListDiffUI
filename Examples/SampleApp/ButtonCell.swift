import ListDiffUI
import UIKit

struct ButtonViewModel: ListViewModel & Equatable {

  var identifier: String {
    title
  }

  var title: String

  @EquatableNoop
  var didTap: (() -> Void)?
}

final class ButtonCell: ListCell {

  lazy var button: UIButton = {
    let button = UIButton()
    contentView.addSubview(button)
    button.frame = contentView.bounds
    button.backgroundColor = .blue
    return button
  }()
}

final class ButtonCellController: ListCellController<
  ButtonViewModel,
  ListViewStateNone,
  ButtonCell
>
{

  override func itemSize(containerSize: CGSize) -> CGSize {
    return CGSize(width: 120, height: 30)
  }

  override func configureCell(cell: ButtonCell) {
    cell.button.setTitle(viewModel.title, for: .normal)
  }

  override func didMount(onCell cell: ButtonCell) {
    cell.button.removeTarget(nil, action: nil, for: .allEvents)
    cell.button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
  }

  @objc
  private func didTap() {
    context.object(type: HelloWorldLogger.self)?.log(message: "Button Tapped")
    viewModel.didTap?()
  }
}
