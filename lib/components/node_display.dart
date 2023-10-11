import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/components/port_display.dart';
import 'package:diffcalc_graph/components/ui_state_manager.dart';
import 'package:diffcalc_graph/data/nodes/ui_node.dart';
import 'package:diffcalc_graph/data/ui_graph.dart';
import 'package:flutter/material.dart';

final class NodeDisplay extends StatefulWidget {
  final UiStateManager stateManager;
  final UiGraph graph;
  final UiNodeMixin node;
  final Function(GlobalObjectKey) onInPortTapDown;
  final Function(GlobalObjectKey) onOutPortTapDown;

  const NodeDisplay(
      {super.key,
      required this.stateManager,
      required this.graph,
      required this.node,
      required this.onInPortTapDown,
      required this.onOutPortTapDown});

  @override
  State<StatefulWidget> createState() {
    return _NodeDisplayState();
  }
}

class _NodeDisplayState extends State<NodeDisplay> {
  @override
  void initState() {
    super.initState();
    widget.stateManager
        .registerNodeState(nodeState: NodeState(node: widget.node));
  }

  Widget buildBody(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: const BorderRadiusDirectional.only(
            bottomStart: Radius.circular(8), bottomEnd: Radius.circular(8)),
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: widget.node.inPorts.values
                  .cast<InPort<dynamic, UiNodeMixin>>()
                  .map((e) => InPortDisplay(
                        key: Key(e.name),
                        inPort: e,
                        onTapDown: (indicatorKey, inPort) {
                          widget.onInPortTapDown(indicatorKey);
                        },
                        onTapUp: (indicatorKey, inPort) {},
                        onKeyReady: (indicatorKey, inPort) {
                          widget.stateManager.registerPortIndicatorKey(
                              widget.node, inPort, indicatorKey);
                        },
                      ))
                  .toList(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: widget.node.outPorts.values
                  .cast<OutPort<dynamic, UiNodeMixin>>()
                  .map((e) => OutPortDisplay(
                        key: Key(e.name),
                        outPort: e,
                        onTapDown: (indicatorKey, outPort) {
                          widget.onOutPortTapDown(indicatorKey);
                        },
                        onTapUp: (indicatorKey, outPort) {},
                        onKeyReady: (indicatorKey, outPort) {
                          widget.stateManager.registerPortIndicatorKey(
                              widget.node, outPort, indicatorKey);
                        },
                      ))
                  .toList(),
            )
          ]),
    );
  }

  Widget buildTitle(BuildContext context, ColorScheme colorScheme) {
    return GestureDetector(
      onPanUpdate: (e) {
        for (final renderBox in widget.node.updateOnDrag) {
          renderBox.markNeedsPaint();
        }

        widget.stateManager.getNodeState(widget.node).redrawConnectedEdges();
        setState(() {
          widget.node.x += e.delta.dx;
          widget.node.y += e.delta.dy;
        });
      },
      child: Container(
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: const BorderRadiusDirectional.only(
                topStart: Radius.circular(8), topEnd: Radius.circular(8)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(widget.node.id,
              style: TextStyle(color: colorScheme.onPrimaryContainer))),
    );
  }

  Widget buildContent(BuildContext context, ColorScheme colorScheme) {
    // According to flutter's doc, IntrinsicWidth is relatively expensive and
    // should be avoided if possible. If layout performance ever becomes an
    // issue, this is probably worth looking into.
    return IntrinsicWidth(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildTitle(context, colorScheme),
            buildBody(context, colorScheme)
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;

    return Positioned(
        left: widget.node.x,
        top: widget.node.y,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: colorScheme.secondaryContainer,
              boxShadow: [
                BoxShadow(
                    color: colorScheme.shadow, blurRadius: 8, spreadRadius: -4)
              ]),
          child: buildContent(context, colorScheme),
        ));
  }
}
