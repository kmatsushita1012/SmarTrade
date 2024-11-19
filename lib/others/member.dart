import 'package:aidore/others/tools.dart';

class MemberInfo {
  late String name;
  late int generation;
  late bool recommend;

  MemberInfo(this.name, this.generation, this.recommend);

  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
      json['name'] as String,
      json['generation'].toInt(),
      json.containsKey('recommend') ? json['recommend'] as bool : false,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'generation': generation,
        'recommend': recommend,
      };
}

class MemberData extends MemberInfo {
  late Map<Pose, int> stock;

  int get count {
    return stock.values.fold(0, (sum, element) => sum + element);
  }

  MemberData(super.name, super.generation, super.recommend, this.stock);

  factory MemberData.createFromInfo(MemberInfo memberInfo, List<Pose> poses) {
    return MemberData(
        memberInfo.name,
        memberInfo.generation,
        memberInfo.recommend,
        { for (var pose in poses) pose : 0 });
  }

  bool get hasAnyShortage {
    switch (recommend) {
      case false:
        return false;
      case true:
        return stock.values.any((pose) => pose == 0);
    }
  }

  bool get isCompleted {
    switch (recommend) {
      case false:
        return false;
      case true:
        return stock.values.every((pose) => pose >= 1);
    }
  }

  bool hasAnyStock({bool isLeftComplete = true}) {
    if (isLeftComplete) {
      switch (recommend) {
        case false:
          return stock.values.any((pose) => pose >= 1);
        case true:
          return stock.values.any((pose) => pose >= 2);
      }
    } else {
      return stock.values.any((pose) => pose >= 1);
    }
  }

  bool hasShortage(Pose pose) {
    switch (recommend) {
      case false:
        return false;
      case true:
        return (stock[pose] ?? 0) == 0;
    }
  }

  bool hasStock(Pose pose, {bool isLeftComplete = true}) {
    if (isLeftComplete) {
      switch (recommend) {
        case false:
          return ((stock[pose] ?? 0) >= 1);
        case true:
          return ((stock[pose] ?? 0) >= 2);
      }
    } else {
      return ((stock[pose] ?? 0) >= 1);
    }
  }

  factory MemberData.fromJson(Map<String, dynamic> json) {
    return MemberData(
      json['name'] as String,
      (json['generation'] as num).toInt(),
      json['recommend'] as bool,
      (json['stock'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(Pose.fromJson(k), (e as num).toInt()),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'generation': generation,
        'recommend': recommend,
        'stock': stock.map((k, e) => MapEntry(k.toJson(), e)),
      };
}
