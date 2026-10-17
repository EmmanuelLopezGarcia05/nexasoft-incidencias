import 'package:flutter_test/flutter_test.dart';
import 'package:nexasoft_incidencias/model/incidencia.dart';

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
}