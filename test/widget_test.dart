import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';
import 'package:nexasoft_incidencias/services/gestor_incidencias.dart';

Incidencia caso(String id, String titulo, String descripcion, String estado,
    String prioridad) {
  return Incidencia(
    id: id,
    titulo: titulo,
    descripcion: descripcion,
    cliente: 'Cliente ficticio',
    categoria: 'Software',
    estado: estado,
    fecha: '2026-10-19',
    prioridad: prioridad,
  );
}

void main() {
  test('Una incidencia antigua puede convertirse desde JSON', () {
    final registro = Incidencia.desdeJson({
      'id': 'INC-DEMO',
      'titulo': 'Prueba',
      'descripcion': 'Caso de ejemplo',
      'cliente': 'Cliente ficticio',
      'categoria': 'Redes',
      'estado': 'Pendiente',
      'fecha': '2026-10-12',
    });
    expect(registro.id, 'INC-DEMO');
    expect(registro.toJson()['estado'], 'Pendiente');
  });

  test('FEAT-001: incidencia antigua sin prioridad usa Media', () {
    final r = Incidencia.desdeJson({'id': 'INC-OLD', 'estado': 'Pendiente'});
    expect(r.prioridad, 'Media');
  });

  test('FEAT-001: prioridad no aprobada se reemplaza por Media', () {
    final r = Incidencia.desdeJson({'id': 'INC-X', 'prioridad': 'Urgente'});
    expect(r.prioridad, 'Media');
  });

  test('FEAT-001: prioridad valida se conserva y se guarda en JSON', () {
    final r = Incidencia.desdeJson({'id': 'INC-Y', 'prioridad': 'Alta'});
    expect(r.prioridad, 'Alta');
    expect(r.toJson()['prioridad'], 'Alta');
  });

  group('FEAT-002: filtros combinables', () {
    final lista = [
      caso('A', 'WiFi lento', 'Red inalambrica', 'Pendiente', 'Alta'),
      caso('B', 'Impresora', 'No imprime por wifi', 'Pendiente', 'Baja'),
      caso('C', 'Correo', 'No llegan mensajes', 'Resuelta', 'Alta'),
      caso('D', 'VPN', 'Sin tunel seguro', 'En proceso', 'Media'),
    ];

    test('sin filtros devuelve todos los registros', () {
      expect(GestorIncidencias.aplicarFiltros(lista).length, 4);
    });

    test('texto, estado y prioridad se aplican juntos', () {
      final r = GestorIncidencias.aplicarFiltros(lista,
          texto: '  WIFI ', estado: 'Pendiente', prioridad: 'Alta');
      expect(r.map((x) => x.id), ['A']);
    });

    test('solo estado o solo prioridad', () {
      expect(GestorIncidencias.aplicarFiltros(lista, estado: 'Pendiente').length, 2);
      expect(GestorIncidencias.aplicarFiltros(lista, prioridad: 'Alta').length, 2);
    });

    test('combinacion sin coincidencias devuelve lista vacia', () {
      final r = GestorIncidencias.aplicarFiltros(lista,
          texto: 'wifi', estado: 'Resuelta');
      expect(r, isEmpty);
    });
  });
}