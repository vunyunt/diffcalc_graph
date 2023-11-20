import 'dart:async';

import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/components/edge_display.dart';
import 'package:diffcalc_graph/nodes/ui_node.dart';
import 'package:flutter/cupertino.dart';

class EdgeState {
  final Edge edge;
  final EdgeDisplayState displayState;

  EdgeState({required this.edge, required this.displayState});
}

class PortState {
  GlobalObjectKey? _indicatorKey;
  final Set<Completer<GlobalObjectKey>> _pendingKeyRequests = {};
  final Set<EdgeState> _connectedEdges = {};

  void setIndicatorKey(GlobalObjectKey indicatorKey) {
    _indicatorKey = indicatorKey;
    for (var completer in _pendingKeyRequests) {
      completer.complete(indicatorKey);
      _pendingKeyRequests.remove(completer);
    }
  }

  GlobalObjectKey getIndicatorKey() {
    final indicatorKey = _indicatorKey;

    if (indicatorKey == null) {
      throw Exception("Indicator key is not yet created");
    }
    return indicatorKey;
  }

  void addConnectedEdge(EdgeState connectedEdge) {
    _connectedEdges.add(connectedEdge);
  }

  void removeConnectedEdge(EdgeState connectedEdge) {
    _connectedEdges.remove(connectedEdge);
  }

  void redrawEdge() {
    for (final connectedEdge in _connectedEdges) {
      connectedEdge.displayState.redraw();
    }
  }
}

class NodeState {
  final UiNodeMixin node;
  final Map<String, PortState> _portStates = {};

  NodeState({required this.node}) {
    for (final port in node.inPorts.values) {
      _portStates[port.name] = PortState();
    }
    for (final port in node.outPorts.values) {
      _portStates[port.name] = PortState();
    }
  }

  PortState getPortState(Port port) {
    final portState = _portStates[port.name];
    if (portState == null) {
      throw Exception(
          "Port ${port.name} does not have a ui state created. This could mean the port isn't registered under the current node.");
    }

    return portState;
  }

  void registerPortIndicatorKey(Port port, GlobalObjectKey key) {
    getPortState(port).setIndicatorKey(key);
  }

  GlobalObjectKey getPortIndicatorKey(Port port) {
    return getPortState(port).getIndicatorKey();
  }

  void redrawConnectedEdges() {
    for (final portState in _portStates.values) {
      portState.redrawEdge();
    }
  }
}

class UiStateManager {
  final Map<String, NodeState> _nodeStates = {};

  NodeState getNodeState(UiNodeMixin node) {
    final nodeState = _nodeStates[node.id];
    if (nodeState == null) {
      throw Exception(
          "Node ${node.id} does not have a ui state created under this state manager.");
    }

    return nodeState;
  }

  void registerEdgeState({required EdgeState edgeState}) {
    final fromPort = edgeState.edge.from;
    final toPort = edgeState.edge.to;
    final fromNode = fromPort.node as UiNodeMixin;
    final toNode = toPort.node as UiNodeMixin;

    getNodeState(fromNode).getPortState(fromPort).addConnectedEdge(edgeState);
    getNodeState(toNode).getPortState(toPort).addConnectedEdge(edgeState);
  }

  void unregisterEdgeState({required EdgeState edgeState}) {
    final fromPort = edgeState.edge.from;
    final toPort = edgeState.edge.to;
    final fromNode = fromPort.node as UiNodeMixin;
    final toNode = toPort.node as UiNodeMixin;

    getNodeState(fromNode)
        .getPortState(fromPort)
        .removeConnectedEdge(edgeState);
    getNodeState(toNode).getPortState(toPort).removeConnectedEdge(edgeState);
  }

  void registerNodeState({required NodeState nodeState}) {
    _nodeStates[nodeState.node.id] = nodeState;
  }

  void registerPortIndicatorKey(
      UiNodeMixin node, Port port, GlobalObjectKey key) {
    getNodeState(node).registerPortIndicatorKey(port, key);
  }

  GlobalObjectKey getPortIndicatorKey(UiNodeMixin node, Port port) {
    return getNodeState(node).getPortIndicatorKey(port);
  }
}
