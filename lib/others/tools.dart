import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Pose {
  // ignore: constant_identifier_names
  HIKI(0),
  // ignore: constant_identifier_names
  CHU(1),
  // ignore: constant_identifier_names
  YORI(2),
  // ignore: constant_identifier_names
  SUWARI(3),
  // ignore: constant_identifier_names
  SUWARIHIKI(4),
  // ignore: constant_identifier_names
  SUWARIYORI(5),
  // ignore: constant_identifier_names
  KABE(6),
  // ignore: constant_identifier_names
  TYPED(7),
  // ignore: constant_identifier_names
  TYPEC(8),
  // ignore: constant_identifier_names
  TYPEB(9),
  // ignore: constant_identifier_names
  TYPEA(10);

  final int value;

  String get text {
    switch (this) {
      case Pose.HIKI:
        return "ヒキ";
      case Pose.CHU:
        return "チュウ";
      case Pose.YORI:
        return "ヨリ";
      case Pose.SUWARI:
        return "座";
      case Pose.SUWARIHIKI:
        return "座ヒキ";
      case Pose.SUWARIYORI:
        return "座ヨリ";
      case Pose.KABE:
        return "カベ";
      case Pose.TYPEA:
        return "A";
      case Pose.TYPEB:
        return "B";
      case Pose.TYPEC:
        return "C";
      case Pose.TYPED:
        return "D";
      default:
        return "";
    }
  }

  const Pose(this.value);

  String toJson() {
    return toString().split('.').last;
  }

  static Pose fromJson(String json) {
    return Pose.values.firstWhere((e) => e.toString().split('.').last == json);
  }
}

enum PoseList {
  // ignore: constant_identifier_names
  NORMAL3,
  // ignore: constant_identifier_names
  SUWARI5,
  // ignore: constant_identifier_names
  SUWARI4,
  // ignore: constant_identifier_names
  KABE5,
  // ignore: constant_identifier_names
  CD;

  List<Pose> get array {
    switch (this) {
      case PoseList.NORMAL3:
        return [Pose.YORI, Pose.CHU, Pose.HIKI];
      case PoseList.SUWARI5:
        return [
          Pose.SUWARIYORI,
          Pose.SUWARIHIKI,
          Pose.YORI,
          Pose.CHU,
          Pose.HIKI
        ];
      case PoseList.SUWARI4:
        return [Pose.SUWARI, Pose.YORI, Pose.CHU, Pose.HIKI];
      case PoseList.KABE5:
        return [Pose.KABE, Pose.SUWARI, Pose.YORI, Pose.CHU, Pose.HIKI];
      case PoseList.CD:
        return [Pose.TYPEA, Pose.TYPEB, Pose.TYPEC, Pose.TYPED];
      default:
        return [];
    }
  }

  String get text {
    switch (this) {
      case PoseList.NORMAL3:
        return "3種 ヨリ/チュウ/ヒキ";
      case PoseList.SUWARI5:
        return "5種 座ヨリ/座ヒキ/ヨリ/チュウ/ヒキ ";
      case PoseList.SUWARI4:
        return "4種 座/ヨリ/チュウ/ヒキ";
      case PoseList.KABE5:
        return "5種 壁/座/ヨリ/チュウ/ヒキ";
      case PoseList.CD:
        return "CD A/B/C/D";
      default:
        return "";
    }
  }
}

class Picture {
  final String name;
  final Pose pose;

  Picture(this.name, this.pose);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Picture &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          pose == other.pose;

  @override
  int get hashCode => name.hashCode ^ pose.hashCode;
}

class AppColorSchemes {
  static ColorScheme wantColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Colors.red,
      onPrimary: Colors.white,
      secondary: Colors.red[300]!,
      onSecondary: Colors.white,
      error: Colors.black,
      onError: Colors.white,
      surface: Colors.red[100]!,
      onSurface: Colors.black);

  static ColorScheme offerColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Colors.blue,
      onPrimary: Colors.white,
      secondary: Colors.blue[300]!,
      onSecondary: Colors.white,
      error: Colors.black,
      onError: Colors.white,
      surface: Colors.blue[100]!,
      onSurface: Colors.black);

  static ColorScheme getColorScheme(String? color) {
    late MaterialColor materialColor;
    switch (color) {
      case "deepPurple":
        materialColor = Colors.deepPurple;
      case "purple":
        materialColor = Colors.purple;
      case "blue":
        materialColor = Colors.blue;
      case "green":
        materialColor = Colors.green;
      case "yellow":
        materialColor = Colors.yellow;
      case "orange":
        materialColor = Colors.orange;
      case "red":
        materialColor = Colors.red;
      case "pink":
        materialColor = Colors.pink;
      case "lightBlue":
        materialColor = Colors.lightBlue;
      default:
        materialColor = Colors.grey;
    }
    return ColorScheme(
        brightness: Brightness.light,
        primary: materialColor,
        onPrimary: Colors.white,
        secondary: materialColor[300]!,
        onSecondary: Colors.white,
        error: Colors.black,
        onError: Colors.white,
        surface: materialColor[50]!,
        onSurface: Colors.black);
  }
}

class SettingItem {
  String name;
  dynamic value;
  List<dynamic> options;
  void Function(dynamic) onChanged;

  SettingItem(
      {required this.name,
      required this.value,
      required this.options,
      required this.onChanged});
}

extension CustomDateTime on DateTime {
  static DateTime parse(String dateTimeString) {
    final regex = RegExp(r'(\d{4})-(\d{2})-(\d{2})');
    final match = regex.firstMatch(dateTimeString);

    if (match != null) {
      int year = int.parse(match.group(1)!);
      int month = int.parse(match.group(2)!);
      int day = int.parse(match.group(3)!);
      return DateTime(year, month, day, 0, 0, 0, 0);
    } else {
      throw const FormatException('Invalid date format');
    }
  }

  String format() {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(this);
  }
}

enum PopupResult { canceled, deleted, purchased }
