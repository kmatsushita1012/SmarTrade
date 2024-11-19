import 'dart:convert';

import 'package:aidore/others/member.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:collection/collection.dart';

class Group {
  late String name;
  late List<int> generations;
  late List<MemberInfo> members;
  late String color;
  late String _lastUpdated;
  late String? fileName;

  DateTime get lastUpdated {
    return DateTime.parse(_lastUpdated);
  }

  Group(
      {required this.name,
      required this.generations,
      required this.members,
      required this.color,
      required this.fileName,
      required String lastUpdated}) {
    _lastUpdated = lastUpdated;
  }

  factory Group.fromJson(Map<String, dynamic> jsonData,
      {bool isStringValue = true}) {
    List<int> generations;
    List<dynamic> members;
    if (isStringValue) {
      generations = json.decode(jsonData["generations"]).cast<int>();
      members = json.decode(jsonData["members"]);
    } else {
      generations = jsonData["generations"].cast<int>();
      members = jsonData["members"];
    }
    Group group = Group(
      name: jsonData['name'] as String,
      generations: generations,
      members: members
          .map((e) => MemberInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      color: jsonData['color'] as String,
      fileName: jsonData.containsKey('fileName')
          ? jsonData['fileName'] as String
          : null,
      lastUpdated: jsonData['lastUpdated']
    );

    return group;
  }

  Map<String, String?> toJson() => <String, String?>{
        'name': name,
        'generations': json.encode(generations),
        'members': json.encode(
            members.map((member) => member.toJson()).toList()), // JSONで保存
        'color': color,
        'fileName': fileName,
        'lastUpdated': _lastUpdated,
      };

  static Future<Group> loadJsonFile(
      String path, Map<String, String> metadata) async {
    final jsonString = await rootBundle.loadString(path);
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final Group group =
        Group.fromJson({...jsonData, ...metadata}, isStringValue: false);
    return group;
  }

  Future<void> updateFromFile(String path, Map<String, String> metadata) async {
    Group newGroup = await loadJsonFile(path, metadata);
    for (var memberNew in newGroup.members) {
      final memberOld =
          members.firstWhereOrNull((member) => member.name == memberNew.name);
      if (memberOld != null) {
        memberNew.recommend = memberOld.recommend;
      }
    }
    members = newGroup.members;
    generations = newGroup.generations;
    color = newGroup.color;
    _lastUpdated = metadata['lastUpdated']!;
  }
}

class GroupDatabaseHelper {
  static final GroupDatabaseHelper _instance = GroupDatabaseHelper._internal();
  factory GroupDatabaseHelper() => _instance;
  GroupDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'group_database.db');
    return await openDatabase(
      path,
      onCreate: (db, version) {
        // Groupテーブルを作成
        return db.execute('''
          CREATE TABLE GroupTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            generations TEXT,
            members TEXT,
            color TEXT,
            lastUpdated TEXT,
            fileName TEXT,
            UNIQUE(name)
          )
          ''');
      },
      version: 1,
    );
  }
}

class GroupRepository {
  final GroupDatabaseHelper _dbHelper = GroupDatabaseHelper();

  Future<void> insert(Group group) async {
    final db = await _dbHelper.database;
    try {
      await db.insert(
        'GroupTable',
        group.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Group>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('GroupTable');
    return List.generate(maps.length, (i) {
      return Group.fromJson(maps[i]);
    });
  }

  // 名前でGroupを取得する
  Future<Group?> get(String name) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'GroupTable',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return Group.fromJson(maps[0]);
    } else {
      return null;
    }
  }

  Future<Group?> getByFileName(String fileName) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'GroupTable',
      where: 'fileName = ?',
      whereArgs: [fileName],
    );
    if (maps.isNotEmpty) {
      return Group.fromJson(maps[0]);
    } else {
      return null;
    }
  }
}
