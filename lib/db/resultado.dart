

class Resultado{
  int? id;
  String? nombre;
  String? apellido;
  String? correo;
  String? contrasena;
  String? fecha;


  Resultado({this.id, this.nombre, this.apellido, this.correo, this.contrasena, this.fecha});


  Resultado.frontMap(Map<String, dynamic> mapa){
    id = mapa["id"];
    nombre = mapa["nombre"];
    apellido = mapa["apellido"];
    correo = mapa["correo"];
    contrasena = mapa["contrasena"];
    fecha = mapa["fecha"];
  }

  Map<String, dynamic> mapeador(){
    return{
      "id": id,
      "nombre": nombre,
      "apellido": apellido,
      "correo": correo,
      "contrasena": contrasena,
      "fecha": fecha
    };
  }
}