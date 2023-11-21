import 'package:diffcalc_graph/data/timed.dart';
import 'package:diffcalc_graph/grpc/gen/taiko.pb.dart';

class TaikoDifficultyHitObject extends LinkedTimed<TaikoDifficultyHitObject> {
  final TaikoHitObject hitObject;

  TaikoDifficultyHitObject(this.hitObject, {super.previous});

  @override
  get startTime => hitObject.startTime.toInt();
}
