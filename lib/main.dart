import 'package:diffcalc_graph/components/graph/graph_display.dart';
import 'package:diffcalc_graph/components/graph/node_selector/node_selector.dart';
import 'package:diffcalc_graph/nodes/create_node_directory.dart';
import 'package:diffcalc_graph/nodes/node_directory.dart';
import 'package:diffcalc_graph/ui_graph.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diffcalc Graph',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.dark(
            primaryContainer: Colors.grey[800],
            onPrimaryContainer: Colors.white,
            secondaryContainer: Colors.grey[900]),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final UiGraph _graph = UiGraph();

  late final NodeDirectory nodeDirectory;

  _MyHomePageState() {
    nodeDirectory = createNodeDirectory();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Row(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        children: [
          NodeSelector(directory: nodeDirectory),
          Expanded(
              child: GraphDisplay(graph: _graph, nodeDirectory: nodeDirectory))
        ],
      ),
    );
  }
}
