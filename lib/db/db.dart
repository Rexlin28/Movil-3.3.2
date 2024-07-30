import 'package:sqflite/sqflite.dart' as sqlite;
import 'package:path/path.dart';
import 'package:sqlitee/db/resultado.dart';


class DB{
  static Future<sqlite.Database> db() async{
    String ruta = await sqlite.getDatabasesPath();
    return sqlite.openDatabase(join(ruta,"resultadoss.db"),
        version: 1, singleInstance: true, onCreate: (sqlite.Database db, int version) async{
          await create(db);
        }
    );
  }
  DateTime currentPhoneDate = DateTime.now(); //DateTime


  static Future<void> create(sqlite.Database db) async{
    const String sql = """
    CREATE TABLE personas(
    id integer primary key autoincrement not null,
    nombre varchar,
    apellido varchar,
    correo varchar,
    contrasena varchar,
    fecha timestamp not null default CURRENT_TIMESTAMP
    )
    """;
    await db.execute(sql);
  }


  static Future<List<Resultado>> consulta() async {

    final sqlite.Database db = await DB.db();

    final List<Map<String, dynamic>> query = await db.query("personas");

    List<Resultado> ? resultado = query.map((e){
      return Resultado.frontMap(e);
    }).toList();

    return resultado;
  }

  Future<int> insertar(Resultado resultado) async {
    int value = 0;
    final sqlite.Database db = await DB.db();
    value = await db.insert("personas", resultado.mapeador(), conflictAlgorithm: sqlite.ConflictAlgorithm.replace);

    return value;
  }

  Future<int> editar(Resultado resultado) async {
    final sqlite.Database db = await DB.db();
    return await db.update(
      'personas',
      resultado.mapeador(),
      where: 'id = ?',
      whereArgs: [resultado.id],
    );
  }

  Future<int> eliminar(int id) async {
    final sqlite.Database db = await DB.db();
    return await db.delete(
      'personas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

