import 'package:diffcalc_graph/nodes/create_node_directory.dart';
import 'package:diffcalc_graph/nodes/node_directory.dart';
import 'package:diffcalc_graph/ui_graph.dart';
import 'package:flutter/material.dart';

/// The global state of the application
///
/// Properties should only be changed inside a [setState] call to ensure that
/// the UI is updated
class AppState extends ChangeNotifier {
  NodeDirectory nodeDirectory = createNodeDirectory();

  UiGraph? workingGraph;

  /// Should be used similarly to [setState]
  setState(void Function() changes) {
    changes.call();
    notifyListeners();
  }
}
