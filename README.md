# ListDiffUI
A descriptive, diffable data source for UICollectionView.

The motivation for the ListDiffUI framework is to hide the tedious details of playing with the indexPaths and managing consistence between data and views. Vanilla use of UICollectionView/UICollectionViewDataSource is error prone as developers need to be extra cautious with informing UICollectionView of data source changes, handling indexPaths, managing cell reusal, etc. The complexicity grows exponentially if cells in the UICollectionView can be heterogeneous.

ListDiffUI draws inspirations from SwiftUI, UICollectionViewDiffableDataSource, [IGListKit](https://github.com/instagram/IGListKit) and frameworks from other platforms (e.g. React). It provides developers an paradigm of managing each cell in a MVVMC fashion, and a descriptive interface to declare a potentially heterogeneous data source for UICollectionView.

## Features

### MVVMC Architechture

ListDiffUI employs Model-View-ViewModel-Controller architechture for cells in the list.

- Each type of cell is defined by a ViewModel:

```
public protocol ListViewModel: Identifiable
```

ViewModels in ListDiffUI framework are expected to be lightweight (immutable) structs that are derived from the underlying data models. They provide interface for identifing cells and equality check.

- A ViewState:

```
public protocol ListViewState
```

ViewStates in ListDiffUI framework are expected to be lightweight structs as well. ViewState should contain fields that affects the appearance of cells, but are not derived from data models. For example, a flag to represent whether a cell is in expanded or collapsed.

- A Cell:
```
open class ListCell: UICollectionViewCell
```

Cell is a subclass of UICollectionViewCell with several additions and overrides to make it work with CellControllers in the framework.

- A CellController:
```
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

```
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

- Although ListDiffUI's section notion provides a way to declare the structure of the list with potentially multiple sections or even nested sections, it gets mapped to a single UICollectionView section internally. As a result it does not support supplemental views for multiple sections.

- As ListDiffUI framework hides details of managing indexPaths explicitly, it is not as straightforward if one wants to use an indexPath related API on the UICollectionView. For example, `indexPath(for:)`, `cellForItem(at:)`, `scrollToItem(at:at:animated:)`.

## Quick Start Guide

Assuming we are building a ToDo list, to build it with ListDiffUI framework:

1. Start by defining the ViewModel and ViewState for a ToDo list cell:
```
struct ToDoItemViewModel: ListViewModel, Equatable {
  var identifier: String
  var description: String
}

struct ToDoItemViewState: ListViewState {
  var completed = false
}
```
Note that here completed is on ViewState. If it is part of the data model (e.g., it is persisted across sessions), it should be moved to ViewModel instead.

2. Implement cell:
```
final class ToDoItemCell: ListCell {

  var descriptionLabel: UILabel
  var completedButtom: UIButton
  
  ...
}
```

## Installation

## Comparison with similar frameworks
