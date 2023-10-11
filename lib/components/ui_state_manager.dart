import 'dart:async';

import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/data/nodes/ui_node.dart';
import 'package:flutter/cupertino.dart';

class EdgeState {
  final RenderBox renderBox;

  EdgeState({required this.renderBox});
}

class PortState {
  GlobalObjectKey? _indicatorKey;
  final Set<Completer<GlobalObjectKey>> _pendingKeyRequests = {};
  EdgeState? _connectedEdge;

  void setIndicatorKey(GlobalObjectKey indicatorKey) {
    _indicatorKey = indicatorKey;
    for (var completer in _pendingKeyRequests) {
      completer.complete(indicatorKey);
      _pendingKeyRequests.remove(completer);
    }
  }

  Future<GlobalObjectKey> getIndicatorKey() async {
    if (_indicatorKey != null) {
      return _indicatorKey!;
    }

    Completer<GlobalObjectKey> completer = Completer();
    _pendingKeyRequests.add(completer);
    return completer.future;
  }

  void setConnectedEdge(EdgeState? connectedEdge) {
    _connectedEdge = connectedEdge;
  }

  void redrawEdge() {
    if (_connectedEdge == null) {
      return;
    }
    _connectedEdge!.renderBox.markNeedsPaint();
  }
}

class NodeState {
  final Map<String, PortState> portStates = {};

  NodeState({required UiNodeMixin node}) {
    for (final port in node.inPorts.values) {
      portStates[port.name] = PortState();
    }
    for (final port in node.outPorts.values) {
      portStates[port.name] = PortState();
    }
  }

  void registerPortIndicatorKey(Port port, GlobalObjectKey key) {
    if (!portStates.containsKey(port.name)) {
      throw Exception(
          "Port ${port.name} does not have a ui state created. This could mean the port isn't registered under the current node.");
    }

    portStates[port.name]!.setIndicatorKey(key);
  }

  Future<GlobalObjectKey> getPortIndicatorKey(Port port) async {
    if (!portStates.containsKey(port.name)) {
      throw Exception(
          "Port ${port.name} does not have a ui state created. This could mean the port isn't registered under the current node.");
    }

    return portStates[port.name]!.getIndicatorKey();
  }
}

class UiStateManager {
  final Map<String, NodeState> nodeStates = {};

  void registerNodeState({required UiNodeMixin node}) {
    nodeStates[node.id] = NodeState(node: node);
  }

  void registerPortIndicatorKey(
      UiNodeMixin node, Port port, GlobalObjectKey key) {
    if (!nodeStates.containsKey(node.id)) {
      throw Exception("Node ${node.id} does not have a ui state created.");
    }

    nodeStates[node.id]!.registerPortIndicatorKey(port, key);
  }

  Future<GlobalObjectKey> getPortIndicatorKey(
      UiNodeMixin node, Port port) async {
    if (!nodeStates.containsKey(node.id)) {
      throw Exception("Node ${node.id} does not have a ui state created.");
    }

    return await nodeStates[node.id]!.getPortIndicatorKey(port);
  }
}
