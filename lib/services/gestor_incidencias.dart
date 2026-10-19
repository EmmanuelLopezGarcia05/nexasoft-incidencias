import '../data/almacen_local.dart';
import '../model/incidencia.dart';

class GestorIncidencias {
  static const String todos = 'Todos';
  static const String todas = 'Todas';
  static const List<String> estados = ['Pendiente', 'En proceso', 'Resuelta'];

  final AlmacenLocal datos = AlmacenLocal();
  List<Incidencia> incidencias = [];

  Future<void> iniciar() async {
    incidencias = await datos.leer();
  }

  static List<Incidencia> aplicarFiltros(List<Incidencia> lista,
      {String texto = '', String estado = todos, String prioridad = todas}) {
    final consulta = texto.trim().toLowerCase();
    return lista.where((x) {
      final coincideTexto = consulta.isEmpty ||
          x.titulo.toLowerCase().contains(consulta) ||
          x.descripcion.toLowerCase().contains(consulta);
      final coincideEstado = estado == todos || x.estado == estado;
      final coincidePrioridad = prioridad == todas || x.prioridad == prioridad;
      return coincideTexto && coincideEstado && coincidePrioridad;
    }).toList();
  }

  List<Incidencia> filtrar(
      {String texto = '', String estado = todos, String prioridad = todas}) {
    return aplicarFiltros(incidencias,
        texto: texto, estado: estado, prioridad: prioridad);
  }

  List<Incidencia> buscar(String texto) => filtrar(texto: texto);

  Incidencia? porId(String id) {
    for (var x in incidencias) {
      if (x.id == id) return x;
    }
    return null;
  }

  int contar(String estado) {
    return incidencias.where((x) => x.estado == estado).length;
  }

  Future<void> cambiarEstado(String id, String estado) async {
    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        incidencias[i].estado = estado;
        await datos.guardar(incidencias);
        break;
      }
    }
  }

  Future<void> cambiarPrioridad(String id, String prioridad) async {
    if (!Incidencia.prioridades.contains(prioridad)) {
      throw ArgumentError('Prioridad no válida: $prioridad');
    }
    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        incidencias[i].prioridad = prioridad;
        await datos.guardar(incidencias);
        break;
      }
    }
  }

  Future<void> crear(String titulo, String descripcion, String cliente,
      String categoria,
      {String prioridad = Incidencia.prioridadPorDefecto}) async {
    final nuevo = Incidencia(
      id: 'INC-${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo,
      descripcion: descripcion,
      cliente: cliente,
      categoria: categoria,
      estado: 'Pendiente',
      fecha: DateTime.now().toIso8601String().split('T').first,
      prioridad: Incidencia.normalizarPrioridad(prioridad),
    );
    incidencias.insert(0, nuevo);
    await datos.guardar(incidencias);
  }

  Future<void> reiniciarDemo() async {
    await datos.restaurarDatosDeEjemplo();
    await iniciar();
  }
}