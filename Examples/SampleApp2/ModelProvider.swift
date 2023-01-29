import Combine
import UIKit

struct ItemModel {

  enum Item {
    case text(String)
    case textWithImage(String, UIImage)
  }

  var id: String
  var item: Item
}

struct DataModel {
  var isLoading: Bool
  var hasMore: Bool
  var items: [ItemModel]
}

final class ModelProvider {

  private var isLoading = false
  private var hasMore = true
  private var items: [ItemModel] = []

  let dataModelPublisher: AnyPublisher<DataModel, Error>
  private let dataModelSubject: CurrentValueSubject<DataModel, Error>

  init() {
    dataModelSubject = CurrentValueSubject(DataModel(isLoading: isLoading, hasMore: hasMore, items: items))
    dataModelPublisher = dataModelSubject.eraseToAnyPublisher()
  }

  func loadMore() {
    guard !isLoading else {
      return
    }
    isLoading = true
    publishDataModel()

    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
      guard let self = self else {
        return
      }
      self.isLoading = false
      for _ in 0..<3 {
        switch Int.random(in: 0...1) {
        case 0:
          self.items.append(ItemModel(id: "\(self.items.count)", item: .text("Text")))
        case 1:
          self.items.append(
            ItemModel(id: "\(self.items.count)", item: .textWithImage("Text with image", randomImage())))
        default:
          assertionFailure("Should not get here.")
        }

      }
      self.publishDataModel()
    }
  }

  private func publishDataModel() {
    dataModelSubject.send(DataModel(isLoading: isLoading, hasMore: hasMore, items: items))
  }
}

private func randomImage() -> UIImage {
  let colors: [UIColor] = [.red, .blue, .cyan, .green, .purple]
  let color = colors.randomElement()!
  let size = CGSize(width: 40, height: 40)
  return UIGraphicsImageRenderer(size: size).image { rendererContext in
    color.setFill()
    rendererContext.fill(CGRect(origin: .zero, size: size))
  }
}
