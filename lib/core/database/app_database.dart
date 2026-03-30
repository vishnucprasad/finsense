import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finsense_ai.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const numType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE accounts (
        id $idType,
        name $textType,
        type $textType,
        balance $numType,
        colorHex $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType,
        type $textType,
        iconName $textType,
        colorHex $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        accountId $textType,
        categoryId $textType,
        amount $numType,
        date $textType,
        note TEXT,
        type $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id $idType,
        name $textType,
        targetAmount $numType,
        currentSaved $numType,
        targetDate $textType,
        aiGeneratedPlan TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE cache (
        id $idType,
        value $textType
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
