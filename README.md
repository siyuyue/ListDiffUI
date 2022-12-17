# ListDiffUI
A descriptive, diffable data source for UICollectionView.

## Features

### MVVMC Architechture

ListDiffUI employs Model-View-ViewModel-Controller architechture for each cell in the list.

### Uni-directional Dataflow

Data flows in one direction in ListDiffUI. Each data mutation should update Model first, and then update ViewModel. This greatly reduces potentional data inconsitency (and crashes) between model and view.

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

### Diff updates

ListDiffUI internally uses the [ListDiff](https://github.com/lxcid/ListDiff) algorithm to compute diff and perform batch updates on the collection view.
