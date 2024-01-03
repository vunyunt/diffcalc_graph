import 'package:diffcalc_graph/app_state.dart';
import 'package:diffcalc_graph/components/graph/graph_editor.dart';
import 'package:diffcalc_graph/components/graph/main_editing_area.dart';
import 'package:diffcalc_graph/components/graph/node_selector/node_selector.dart';
import 'package:diffcalc_graph/components/pages/graph_selection_page.dart';
import 'package:diffcalc_graph/nodes/create_node_directory.dart';
import 'package:diffcalc_graph/nodes/node_directory.dart';
import 'package:diffcalc_graph/ui_graph.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const DiffcalcGraphApp());
}

class DiffcalcGraphApp extends StatefulWidget {
  const DiffcalcGraphApp({super.key});

  @override
  State<DiffcalcGraphApp> createState() => _DiffcalcGraphAppState();
}

class _DiffcalcGraphAppState extends State<DiffcalcGraphApp> {
  AppState appState = AppState();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      builder: (context, child) => MaterialApp(
        title: 'Diffcalc Graph',
        theme: ThemeData(
          colorScheme: ColorScheme.dark(
              primaryContainer: Colors.grey[800],
              onPrimaryContainer: Colors.white,
              secondaryContainer: Colors.grey[900]),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final NodeDirectory nodeDirectory;

  _MyHomePageState() {
    nodeDirectory = createNodeDirectory();
  }

  @override
  Widget build(BuildContext context) {
    final graph = context.select<AppState, UiGraph?>(
      (value) => value.workingGraph,
    );

    return Scaffold(
        body: graph == null
            ? GraphSelectionPage()
            : GraphEditor(
                graph: graph,
                nodeDirectory: nodeDirectory,
              ));
  }
}
