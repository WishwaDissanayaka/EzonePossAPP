import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ezoneapp/functions/database/datatable.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  // Get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize the database if not yet initialized
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database and define the path
  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'my_database.db');

    // Open the database, or create it if it doesn’t exist
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create tables when initializing the database
  Future<void> _onCreate(Database db, int version) async {
    // Call the createDataTables function from DataTables
    final dataTables = DataTables();
    await dataTables.createDataTables(db);
  }

  // Close the database when it's no longer needed
  Future<void> close() async {
    final db = await _database;
    if (db != null) {
      await db.close();
    }
  }

}
