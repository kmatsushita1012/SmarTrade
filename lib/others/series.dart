import 'dart:convert';
import 'package:aidore/others/constants.dart';
import 'package:aidore/others/member.dart';
import 'package:aidore/others/tools.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Series {
  late String name;
  late String group;
  late String color;
  late List<Pose> poses;
  late List<MemberData> members;
  late int capacity;

  int get count {
    return members.fold(0, (sum, element) => sum + element.count);
  }

  Series({
    required this.name,
    required this.group,
    required this.color,
    required this.poses,
    required this.members,
    required this.capacity,
  });

  factory Series.fromJson(Map<String, dynamic> jsonData) {
    List<dynamic> members = json.decode(jsonData["members"]);
    List<dynamic> poses = jsonDecode(jsonData['poses']);

    return Series(
      name: jsonData['name'].toString(),
      group: jsonData['group_name'].toString(),
      color: jsonData['color'].toString(),
      poses: poses.map((e) => Pose.fromJson(e)).toList(),
      members: members
          .map((e) => MemberData.fromJson(e as Map<String, dynamic>))
          .toList(),
      capacity: jsonData['capacity'] as int,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'group_name': group,
        'color': color,
        'poses': json.encode(poses.map((e) => e.toJson()).toList()),
        'members': json.encode(members.map((e) => e.toJson())),
        'capacity': capacity,
      };
      
  bool isPurchaseNeeded() {
    return count > capacity;
  }

  void addCapacity() {
    capacity += SERIES_CAPACITY_STEP;
  }
}

class SeriesDatabaseHelper {
  static final SeriesDatabaseHelper _instance =
      SeriesDatabaseHelper._internal();
  factory SeriesDatabaseHelper() => _instance;
  SeriesDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'series_database.db');
    return await openDatabase(
      path,
      onCreate: (db, version) {
        // テーブルを作成
        return db.execute('''
          CREATE TABLE SeriesTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            group_name TEXT,
            color TEXT,
            poses TEXT,
            members TEXT, 
            capacity INTEGER,
            UNIQUE(name, group_name)
          )
          ''');
      },
      version: 1,
    );
  }
}

class SeriesRepository {
  final SeriesDatabaseHelper _dbHelper = SeriesDatabaseHelper();

  Future<void> insertSeries(Series series) async {
    final db = await _dbHelper.database;
    try {
      await db.insert(
        'SeriesTable',
        {
          'name': series.name,
          'group_name': series.group,
          'color': series.color,
          'poses':
              jsonEncode(series.poses.map((pose) => pose.toJson()).toList()),
          'members': jsonEncode(
              series.members.map((member) => member.toJson()).toList()),
          'capacity': series.capacity
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Series>> getAllSeries() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('SeriesTable');
    List<Series> seriesList = List.generate(maps.length, (i) {
      Series series = Series.fromJson(maps[i]);
      return series;
    });
    return seriesList;
  }

  // 新しいメソッドを追加して、nameとgroup_nameでSeriesを取得する
  Future<Series?> getSeries(String name, String group) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'SeriesTable',
      where: 'name = ? AND group_name = ?',
      whereArgs: [name, group],
    );

    if (maps.isNotEmpty) {
      return Series.fromJson(maps[0]);
    } else {
      return null; // 該当するシリーズが見つからない場合
    }
  }

  Future<void> removeSeries(String name, String group) async {
    final db = await _dbHelper.database;
    try {
      final int count = await db.delete(
        'SeriesTable',
        where: 'name = ? AND group_name = ?',
        whereArgs: [name, group],
      );
      if (count == 0) {
        throw Exception('Series with name $name not found');
      }
    } catch (e) {
      rethrow;
    }
  }
}
