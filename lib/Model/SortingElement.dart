import 'package:profit_calculator/Model/SortingTypes.dart';

class SortingElement {
  String leadingText;
  String trailingText;
  SortingTypes sortingType;

  SortingElement(this.leadingText, this.trailingText, this.sortingType);

  void sortByLeading() {
    if (sortingType == SortingTypes.leadingAscending) {
      leadingText = '▼';
      trailingText = '   ';
      sortingType = SortingTypes.leadingDescending;
    } else {
      leadingText = '▲';
      trailingText = '   ';
      sortingType = SortingTypes.leadingAscending;
    }
  }

  void sortByTrailing() {
    if (sortingType == SortingTypes.trailingAscending) {
      sortingType = SortingTypes.trailingDescending;
      trailingText = '▼';
      leadingText = '   ';
    } else {
      trailingText = '▲';
      leadingText = '   ';
      sortingType = SortingTypes.trailingAscending;
    }
  }
}
