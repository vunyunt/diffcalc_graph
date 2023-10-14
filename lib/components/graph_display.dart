import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/components/edge_display.dart';
import 'package:diffcalc_graph/components/node_display.dart';
import 'package:diffcalc_graph/components/ui_state_manager.dart';
import 'package:diffcalc_graph/data/nodes/ui_node.dart';
import 'package:diffcalc_graph/data/ui_graph.dart';
import 'package:flutter/material.dart';

class GraphDisplay extends StatefulWidget {
  final UiGraph graph;

  const GraphDisplay({Key? key, required this.graph}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GraphDisplayState();
  }
}

class _GraphDisplayState extends State<GraphDisplay> {
  RenderBox? currentDraggingRenderBox;
  late GlobalObjectKey containerKey;
  Offset cursorPosition = Offset.zero;
  UiStateManager stateManager = UiStateManager();
  Port? currentDraggingPort;

  Map<Edge, Widget> edgeWidgets = {};

  final draggingPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.red
    ..strokeWidth = 3.0
    ..strokeCap = StrokeCap.round;

  final edgePaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.lightBlue
    ..strokeWidth = 3.0
    ..strokeCap = StrokeCap.round;

  @override
  void initState() {
    super.initState();

    containerKey = GlobalObjectKey(widget.graph);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      createEdgeDisplays(widget.graph);
    });

    widget.graph.onEdgeDisconnected.listen((edge) {
      setState(() {
        edgeWidgets.remove(edge);
      });
    });
  }

  Widget buildDraggingEdge(BuildContext context) {
    RenderBox containerRenderBox = context.findRenderObject() as RenderBox;

    return BezierEdgeDisplay(
      startPosition: containerRenderBox.globalToLocal(currentDraggingRenderBox!
          .localToGlobal(Offset(currentDraggingRenderBox!.size.width,
              currentDraggingRenderBox!.size.height / 2))),
      endPosition: cursorPosition,
      paint: draggingPaint,
    );
  }

  Iterable<NodeDisplay> createNodeDisplays(UiGraph graph) {
    return graph.nodes.values.map((node) {
      return NodeDisplay(
        stateManager: stateManager,
        graph: widget.graph,
        node: node,
        onPortDragStarted: (indicatorKey, port) {
          setState(() {
            currentDraggingPort = port;
            currentDraggingRenderBox =
                indicatorKey.currentContext!.findRenderObject() as RenderBox;
          });
        },
        onPortDragUpdate: (e) {
          final containerRenderBox =
              containerKey.currentContext!.findRenderObject() as RenderBox;

          setState(() {
            cursorPosition = containerRenderBox.globalToLocal(e.globalPosition);
          });
        },
        onPortDragEnd: (indicatorKey, port) {
          setState(() {
            currentDraggingPort = null;
            currentDraggingRenderBox = null;
          });
        },
        onPortDragAccepted: (edge) {
          setState(() {
            edgeWidgets[edge] = createEdgeDisplay(graph, edge);
          });
        },
      );
    });
  }

  Widget createEdgeDisplay(UiGraph graph, Edge edge) {
    final fromIndicator = stateManager.getPortIndicatorKey(
        edge.from.node as UiNodeMixin, edge.from);
    final toIndicator =
        stateManager.getPortIndicatorKey(edge.to.node as UiNodeMixin, edge.to);

    return EdgeDisplay(
        key: ObjectKey(edge),
        stateManager: stateManager,
        edge: edge,
        containerKey: containerKey,
        fromPortKey: fromIndicator,
        toPortKey: toIndicator,
        paint: edgePaint);
  }

  void createEdgeDisplays(UiGraph graph) {
    final nodes = widget.graph.nodes.values;

    for (final toNode in nodes) {
      for (final inPort in toNode.inPorts.values) {
        if (inPort.connected) {
          setState(() {
            edgeWidgets[inPort.edge!] = createEdgeDisplay(graph, inPort.edge!);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];

    widgets.addAll(createNodeDisplays(widget.graph));

    if (currentDraggingRenderBox != null) {
      widgets.add(buildDraggingEdge(context));
    }

    return Stack(
        key: containerKey, children: [...widgets, ...edgeWidgets.values]);
  }
}
