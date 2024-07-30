import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../db/db.dart';
import '../db/resultado.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Resultado> historial = [];

  @override
  void initState() {
    super.initState();
    cargarHistorial();
  }

  void cargarHistorial() async {
    List<Resultado> datos = await DB.consulta();
    setState(() {
      historial = datos;
    });
  }

  void actualizarResultado(Resultado resultado) async {
    DB db = DB();
    await db.editar(resultado);
    cargarHistorial();
    debugPrint('Registro actualizado: $resultado');
  }

  void borrarResultado(int id) async {
    DB db = DB();
    await db.eliminar(id);
    cargarHistorial();
    debugPrint('Registro con ID $id eliminado');
  }

  Future<void> mostrarDialogoResultado(
      BuildContext context, {Resultado? resultado}) async {
    TextEditingController nombreController =
    TextEditingController(text: resultado?.nombre ?? "");
    TextEditingController apellidoController =
    TextEditingController(text: resultado?.apellido ?? "");
    TextEditingController correoController =
    TextEditingController(text: resultado?.correo ?? "");
    TextEditingController contrasenaController =
    TextEditingController(text: resultado?.contrasena ?? "");

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(resultado == null ? "Agregar Resultado" : "Editar Resultado"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: InputDecoration(labelText: "Nombre"),
              ),
              TextField(
                controller: apellidoController,
                decoration: InputDecoration(labelText: "Apellido"),
              ),
              TextField(
                controller: correoController,
                decoration: InputDecoration(labelText: "Correo"),
              ),
              TextField(
                controller: contrasenaController,
                decoration: InputDecoration(labelText: "Contraseña"),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                String nombre = nombreController.text;
                String apellido = apellidoController.text;
                String correo = correoController.text;
                String contrasena = contrasenaController.text;

                if (nombre.isNotEmpty && apellido.isNotEmpty && correo.isNotEmpty && contrasena.isNotEmpty) {
                  if (resultado == null) {
                    Resultado nuevoResultado = Resultado(
                      nombre: nombre,
                      apellido: apellido,
                      correo: correo,
                      contrasena: contrasena,
                      fecha: DateTime.now().toIso8601String(),
                    );

                    DB db = DB();
                    await db.insertar(nuevoResultado);
                    debugPrint('Nuevo registro agregado: $nuevoResultado');
                  } else {
                    resultado.nombre = nombre;
                    resultado.apellido = apellido;
                    resultado.correo = correo;
                    resultado.contrasena = contrasena;
                    resultado.fecha = DateTime.now().toIso8601String();

                    actualizarResultado(resultado);
                  }

                  cargarHistorial();
                  Navigator.of(context).pop();
                }
              },
              child: Text(resultado == null ? "Agregar" : "Actualizar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Wrap(
          children: [
            Text("Historial      "),
            Icon(Icons.history),
          ],
        ),
      ),
      body: Builder(
        builder: (context) {
          if (historial.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.blueGrey,
                  ),
                  SizedBox(height: 20),
                  Text("Aun sin datos"),
                ],
              ),
            );
          } else {
            return Material(
              child: ListView.builder(
                itemCount: historial.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person_pin),
                      title: Text("#${historial[index].id}"),
                      subtitle: Text(
                          "-Nombre: ${historial[index].nombre} ${historial[index].apellido} \n- Correo: ${historial[index].correo} \n- Contraseña: ${historial[index].contrasena} \n- Hora y Fecha: ${historial[index].fecha}"),
                      tileColor: Color(
                          (math.Random().nextDouble() * 0xFFFFFF).toInt())
                          .withOpacity(1.0),
                      trailing: Wrap(
                        spacing: 12,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              mostrarDialogoResultado(context, resultado: historial[index]);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              borrarResultado(historial[index].id!);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mostrarDialogoResultado(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
