import 'dart:io';

import 'package:diffcalc_graph/data/nodes/grpc/gen/taiko.pbgrpc.dart';
import 'package:grpc/grpc.dart';

final grpcChannel =
    ClientChannel(InternetAddress("", type: InternetAddressType.unix));

class CsharpBeatmapInputNode {
  TaikoClient client = TaikoClient(grpcChannel);

}
