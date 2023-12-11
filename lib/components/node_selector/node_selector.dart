import 'dart:math';

import 'package:diffcalc_graph/nodes/node_directory.dart';
import 'package:flutter/material.dart';

class NodeSelector extends StatefulWidget {
  static const nodeFactoryPrefix = "NodeFactories/";

  final NodeDirectory directory;

  const NodeSelector({super.key, required this.directory});

  @override
  State<StatefulWidget> createState() {
    return _NodeSelectorState();
  }
}

class _NodeSelectorState extends State<NodeSelector> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            boxShadow: [
              BoxShadow(color: Theme.of(context).shadowColor, blurRadius: 8)
            ],
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: _CategoryDisplay(category: widget.directory.rootCategory),
            ),
          )),
    );
  }
}

class _CategoryDisplay extends StatefulWidget {
  final CategoryContent category;

  const _CategoryDisplay({super.key, required this.category});

  @override
  State<StatefulWidget> createState() {
    return _CategoryDisplayState();
  }
}

class _CategoryDisplayState extends State<_CategoryDisplay> {
  bool expanded = false;
  bool hover = false;

  Widget buildTitle(BuildContext context) {
    return Text(widget.category.qualifiedName);
  }

  Widget buildSubCategories(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.category.subcategories.values
            .map((value) => _CategoryDisplay(category: value))
            .toList(growable: false));
  }

  Widget buildNodeDraggable(BuildContext context, String qualifiedName) {
    return Draggable(
      // TODO: Better dragging feedback
      feedback: const Icon(Icons.web),
      data: NodeSelector.nodeFactoryPrefix + qualifiedName,
      child: Text(qualifiedName.split(".").last, textAlign: TextAlign.left),
    );
  }

  Widget buildNodes(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 26),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.category.nodes
              .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: buildNodeDraggable(context, e)))
              .toList(growable: false)),
    );
  }

  Widget buildContent(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [buildSubCategories(context), buildNodes(context)]);
  }

  @override
  Widget build(BuildContext context) {
    var title = widget.category.qualifiedName;
    if (title.isEmpty) {
      title = "All Nodes";
    }

    return Container(
        decoration: BoxDecoration(
            color: hover
                ? Theme.of(context).colorScheme.tertiaryContainer
                : Colors.transparent),
        padding: EdgeInsets.only(left: widget.category.level * 20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    expanded = !expanded;
                  });
                },
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      expanded ? '▼ $title' : '▶ $title',
                      textAlign: TextAlign.left,
                    )),
              ),
              if (expanded) buildContent(context)
            ]));
  }
}
