# ListDiffUI
A descriptive, diffable data source for UICollectionView.

The motivation for the ListDiffUI framework is to hide the tedious details of playing with the indexPaths and managing consistence between data and views. Vanilla use of UICollectionView/UICollectionViewDataSource is error prone as developers need to be extra cautious with informing UICollectionView of data source changes, handling indexPaths, managing cell reusal, etc. The complexicity grows exponentially if cells in the UICollectionView can be heterogeneous.

ListDiffUI draws inspirations from SwiftUI, UICollectionViewDiffableDataSource, [IGListKit](https://github.com/instagram/IGListKit) and frameworks from other platforms (e.g. React). It provides developers an paradigm of managing each cell in a MVVMC fashion, and a descriptive interface to declare a potentially heterogeneous data source for UICollectionView.

## Features

### MVVMC Architechture

ListDiffUI employs Model-View-ViewModel-Controller architechture for cells in the list.

- Each type of cell is defined by a ViewModel:

  ```swift
  public protocol ListViewModel: Identifiable
  ```

  ViewModels in ListDiffUI framework are expected to be lightweight (immutable) structs that are derived from the underlying data models. They provide interface for identifing cells and equality check.

  - A ViewState:

  ```swift
  public protocol ListViewState
  ```

  ViewStates in ListDiffUI framework are expected to be lightweight structs as well. ViewState should contain fields that affects the appearance of cells, but are not derived from data models. For example, a flag to represent whether a cell is in expanded or collapsed.

- A Cell:
  ```swift
  open class ListCell: UICollectionViewCell
  ```

  Cell is a subclass of UICollectionViewCell with several additions and overrides to make it work with CellControllers in the framework.

- A CellController:
  ```swift
  open class ListCellController<
    ListViewModelType: ListViewModel & Equatable,
    ListViewStateType: ListViewState,
    ListCellType: ListCell
  >: AnyListCellController
  ```

  CellController is expected to be the place for business logic. At the bare minimum, CellController should provide the size of the cell, and be responsible for configuring the cell based on ViewModel and ViewState. Note that during the lifecycle of a ListDiffDataSource, Cell may be reused just like UICollectionViewCell, but CellControllers are never reused, making it the perfect place to persist ViewState and other data.

### Uni-directional Dataflow

Data flows in one direction in ListDiffUI. Any data mutation logic should update model (not managed by the ListDiffUI framework) first, and then update ViewModel. This greatly reduces potentional data inconsitency (and crashes) between model and view.

![Untitled Diagram](https://user-images.githubusercontent.com/3288416/212487700-7b79cb70-6e78-4f3c-806f-06a7a1e8ff90.png)

The above diagram provides a more comprehensive look at how data flows in ListDiffUI framework.

ListDiffUI works well with any Reactive framework such as Combine or RxSwift, where developers can observe model changes and update ListDiffDataSource.

### Descriptive

Describe the structure of the list, with sections:

```swift
dataSource.setRootSection(
  CompositeSection(
    ListSection<
      Bool, LoadingSpinnerController
    >(isLoading) {
      $0 ? LoadingSpinnerViewModel() : nil
    },
    ListSection<
      ItemViewModel, ItemCellController
    >(items)
  )
)
```

Section provides an intuitive interface for developers to describe how the UICollectionView should look like, that supports heterogeneity by design.

### Diff updates

ListDiffUI internally uses the [ListDiff](https://github.com/lxcid/ListDiff) algorithm to compute diff and perform batch updates on the collection view.

Both identity and equality are provided through ViewModel interface. Identical and equal ViewModel means no update to an existing cell, whereas identical but not equal ViewModel will trigger an update of the existing cell.

## Limitations

- Currently ListDiffUI requires UICollectionView to use UICollectionViewFlowLayout (or its subclasses) as it relies on `collectionView(_:layout:sizeForItemAt:)` method of [UICollectionViewDelegateFlowLayout](https://developer.apple.com/documentation/uikit/uicollectionviewdelegateflowlayout) protocol to provide size of cells.

- Although ListDiffUI's section interface provides a way to declare the structure of the list with potentially multiple sections or even nested sections, it gets mapped to a single UICollectionView section internally. As a result it does not support supplemental views for multiple sections.

- As ListDiffUI framework hides details of managing indexPaths explicitly, it is not as straightforward if one wants to use an indexPath related API on the UICollectionView. For example, `indexPath(for:)`, `cellForItem(at:)`, `scrollToItem(at:at:animated:)`.

## Quick Start Guide

Assuming we are building a ToDo list, to build it with ListDiffUI framework:

1. Build cell with MVVMC architecture
   - Start by defining the ViewModel and ViewState for a ToDo list cell:
    ```swift
    struct ToDoItemViewModel: ListViewModel, Equatable {
      var identifier: String
      var description: String
    }

    struct ToDoItemViewState: ListViewState {
      var completed = false
    }
    ```
    Note that here completed is on ViewState. If it is part of the data model (e.g., it is persisted across sessions), it should be moved to ViewModel instead.

   - Implement cell:
    ```swift
    final class ToDoItemCell: ListCell {

      var descriptionLabel: UILabel
      var completedButton: UIButton

      ...
    }
    ```
    This is usually the same as how one would do it with vanilla UICollectionViewCell.

   - Implement controller logic:
    ```swift
    final class ToDoItemCellController: ListCellController<
      ToDoItemViewModel,
      ToDoItemViewState,
      ToDoItemCell
    > {

      override func itemSize(containerSize: CGSize) -> CGSize {
        return CGSize(width: containerSize.width, height: 40)
      }

      override func configureCell(cell: LabelCell) {
        cell.descriptionLabel.text = viewModel.description
        cell.completedButton.isSelected = viewState.completed
      }

      override func didMount(onCell cell: LabelCell) {
        cell.completedButton.removeTarget(nil, action: nil, for: .touchUpInside)
        cell.completedButton.addTarget(self, action: #selector(didTapComplete), for: .touchUpInside)
      }

      @objc
      private func didTapComplete() {
        var state = viewState
        state.completed = !state.completed
        updateState(state)
      }
    }
    ```
    Note that in didMount we are removing all targets on the button first to account for cell reuse. ListDiffUI framework does not dictate how cell communicates with controller to handle user actions. The above example is one way. One may also use delegate pattern, and set controller to be the delegate of the cell in didMount.

2. Create ListDiffDataSource
    ```swift
    let dataSource = ListDiffDataSource(collectionView: collectionView)
    ```

3. Observe data model updates, and set root section on the ListDiffDataSource
    ```swift
    dataSource.setRootSection(
      ListSection<
        ToDoItem, ToDoItemCellController
      >(items) {
        ToDoItemViewModel(identifier: $0.id, description: $0.description)
      }
    )
    ```

And that's it, ListDiffUI framework will take care of building the root section into an array of view models and updating UI accordingly.

Refer to [the sample apps](https://github.com/siyuyue/ListDiffUI/tree/main/Examples) for some examples, that showcases a few additional features in the ListDiffUI framework, including:
- Heterogeneous cells
- Asynchronous diffing on background thread (This is a configuration on ListDiffDataSource)
- Passing in delegate objects to each controller to handle data mutation
- Using context objects to pass in dependencies (e.g. a logger instance) to each controller

## Installation

### Via Swift Package Manager
https://swiftpackageindex.com/siyuyue/ListDiffUI

### Via bazel
In WORKSPACE file:
```starlark
git_repository(
    name = "ListDiffUI",
    remote = "https://github.com/siyuyue/ListDiffUI.git",
    commit = "2097758b9b0bcedabdc0d7916c4d7613f8f0e2b7",
    shallow_since = "1671574341 -0800",
)

load(
    "@ListDiffUI//:repositories.bzl",
    "listdiffui_dependencies",
)

listdiffui_dependencies()
```

In BUILD file, add `@ListDiffUI//:ListDiffUI` to your library's deps.

### Copy source code over

It's MIT license.

## Comparison with similar frameworks

### SwiftUI

If SwiftUI is an option that works for your case, there's no reason to go back to using UICollectionView or ListDiffUI framework.

### UICollectionViewDiffableDataSource

[UICollectionViewDiffableDataSource](https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/updating_collection_views_using_diffable_data_sources) uses snapshots to represent view model and compute diff. It is relatively new and may evolve into a more powerful framework. As of iOS 16, there are two ways to create a snapshot:

1. Loading the snapshot with identifiers using `appendSections` and `appendItems`

   Compared to ListDiffUI, this method of creating a snapshot does not provide a descriptive interface. The diffing process does not compute item updates either. User is responsible for computing updates to an existing item.

2. Populate snapshot with lightweight data structures

   Compared to ListDiffUI, this method does not track the identity of items.

Neither of the methods offers something like ListDiffUI's Section interface that can easily support heterogeneity.

### IGListKit

ListDiffUI is quite similar to IGListKit, and uses the same ListDiff algorithm for diffing. ListDiffUI additionally offers:

- A descriptive interface to describe the structure of the collection view.
- Strong types thanks to Swift's powerful syntax.


