import 'dart:collection';

import 'package:computational_graph/computational_graph.dart';

/// Data structure to organize nodes into categories, and arbitrary levels of
/// subcategories. Note that everything should be indexed by qualified name.
class CategoryContent {
  final int level;

  /// The name of this category, including parent categories separated by the
  /// dot (.) character
  final String qualifiedName;

  /// Available sub-categories. Keys should be their corresponding qualified
  /// names
  final Map<String, CategoryContent> subcategories = {};

  /// Available node types under this categories
  /// These should be the qualified name of the nodes. The actual factories
  /// should be accessed through the [NodeFactoryRegistry.getFactoryFor] method
  final Set<String> nodes = {};

  CategoryContent({required this.qualifiedName, required this.level});

  /// Create a sub-category by name.
  _getOrCreateSubCategory(String subCategoryQualifiedName) {
    if (!subcategories.containsKey(subCategoryQualifiedName)) {
      subcategories[subCategoryQualifiedName] = CategoryContent(
          qualifiedName: subCategoryQualifiedName, level: level + 1);
    }

    return subcategories[subCategoryQualifiedName]!;
  }
}

/// A directory of [UiNode]s to list in the gui
class NodeDirectory extends NodeFactoryRegistry {
  final CategoryContent rootCategory =
      CategoryContent(qualifiedName: '', level: 0);

  /// The dot (.) character in [nodeType] will be used as a separator to
  /// categorize nodes in gui. Do note that the corresponding [Node.typeName]
  /// must match this value.
  @override
  void registerFactoryFor(String nodeType, NodeFactory factory) {
    final categories = _getOrCreatePrecedingCategories(nodeType);
    final currentCategory = categories.isEmpty ? rootCategory : categories.last;
    currentCategory.nodes.add(nodeType);

    super.registerFactoryFor(nodeType, factory);
  }

  List<CategoryContent> _getOrCreatePrecedingCategories(String qualifiedName) {
    CategoryContent currentCategory = rootCategory;
    final parsedCategories = Queue<String>.from(qualifiedName.split('.'));

    // Remove the last element as it is the name of the category/node
    parsedCategories.removeLast();

    final List<CategoryContent> result = [];

    while (parsedCategories.isNotEmpty) {
      currentCategory = currentCategory._getOrCreateSubCategory(
          "${currentCategory.qualifiedName}.${parsedCategories.removeFirst()}");
      result.add(currentCategory);
    }

    return result;
  }
}
