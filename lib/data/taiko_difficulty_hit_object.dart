import 'package:diffcalc_graph/data/timed.dart';
import 'package:diffcalc_graph/grpc/gen/taiko.pb.dart';

class TaikoDifficultyHitObject with Timed {
  final TaikoHitObject hitObject;

  TaikoDifficultyHitObject(this.hitObject);

  @override
  get startTime => hitObject.startTime.toInt();
}
