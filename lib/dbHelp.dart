// ignore: file_names
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'project_uas.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');
        //CEREATE TABLE SERVIS
        await db.execute('''
          CREATE TABLE servis(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama TEXT NOT NULL,
          no_hp TEXT,
          model TEXT NOT NULL,
          kategori TEXT NOT NULL,
          keluhan TEXT NOT NULL,
          diagnosa TEXT,
          biaya INTEGER DEFAULT 0,
          status TEXT DEFAULT 'Undone',
          tanggal_masuk TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Returns true jika berhasil register
  Future<bool> register(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }

    final result = await (await db).insert('user', {
      'username': username,
      'password': password,
    });

    return result > 0;
  }

  // Returns Map user jika login berhasil, null jika gagal
  Future<Map<String, dynamic>?> login(String username, String password) async {
    var dbClient = await db;
    var res = await dbClient.query(
      'user',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return res.isNotEmpty ? res.first : null;
  }

  //READ TABEL SERVIS
  Future<List<Map<String, dynamic>>> getServis() async {
    var dbClient = await db;
    return await dbClient.query('servis', orderBy: 'id ASC');
  }

  // INSERT TABEL SERVIS
  Future<int> tambahServis(Map<String, dynamic> data) async {
    var dbClient = await db;
    return await dbClient.insert('servis', data);
  }

  // UPDATE TABEL SERVIS
  Future<int> updateServis(int id, Map<String, dynamic> data) async {
    var dbClient = await db;

    return await dbClient.update(
      'servis',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //DELETE TABEL SERVIS
  Future<int> deleteServis(int id) async {
    var dbClient = await db;

    return await dbClient.delete('servis', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> searchData(String keyword) async {
    var dbClient = await db;

    return await dbClient.rawQuery(
      '''
    SELECT * FROM servis
    WHERE LOWER(nama) LIKE LOWER(?)
    ''',
      ['%$keyword%'],
    );
  }
}
