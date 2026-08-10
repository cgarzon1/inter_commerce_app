// Asistente interactivo de commits (Conventional Commits).
// Uso: dart run bin/cz.dart
import 'dart:io';

class _CommitType {
  final String key;
  final String description;
  const _CommitType(this.key, this.description);
}

const List<_CommitType> _types = [
  _CommitType('feat', 'Nueva funcionalidad para el usuario'),
  _CommitType('fix', 'Corrección de un error o bug'),
  _CommitType(
      'refactor', 'Cambio en el código que no corrige un bug ni añade una feature'),
  _CommitType('docs', 'Cambios únicamente en la documentación'),
  _CommitType(
      'style', 'Cambios de formato, espacios, comas (sin impacto en la lógica)'),
  _CommitType('test', 'Añadir o corregir pruebas'),
  _CommitType('perf', 'Cambio de código orientado a mejorar el rendimiento'),
  _CommitType('chore',
      'Tareas de mantenimiento, actualización de dependencias o configuración'),
];

const int _maxDescriptionLength = 70;

const String _red = '\x1B[31m';
const String _green = '\x1B[32m';
const String _yellow = '\x1B[33m';
const String _cyan = '\x1B[36m';
const String _bold = '\x1B[1m';
const String _reset = '\x1B[0m';

void main(List<String> arguments) {
  stdout.writeln(
      '$_cyan$_bold\n📦  Asistente de Commits — Conventional Commits$_reset');
  stdout.writeln(
      '${_cyan}Responde las preguntas para generar un mensaje de commit estandarizado.$_reset\n');

  final type = _askType();
  final scope = _askScope();
  final description = _askDescription();
  final ticket = _askTicket();

  final message = _buildMessage(
    type: type,
    scope: scope,
    description: description,
    ticket: ticket,
  );

  stdout.writeln('\n${_yellow}Mensaje final:$_reset');
  stdout.writeln('  $_bold$message$_reset\n');

  stdout.write('¿Confirmas el commit? (S/n): ');
  final confirm = stdin.readLineSync()?.trim().toLowerCase() ?? 's';
  if (confirm.isNotEmpty && !['s', 'si', 'sí', 'y', 'yes'].contains(confirm)) {
    stdout.writeln('$_red✖ Commit cancelado.$_reset');
    exit(0);
  }

  _runCommit(message);
}

String _askType() {
  while (true) {
    stdout.writeln('Selecciona el TIPO de commit:');
    for (var i = 0; i < _types.length; i++) {
      final t = _types[i];
      stdout.writeln('  ${i + 1}. ${t.key.padRight(9)} ${t.description}');
    }
    stdout.write('Opción (1-${_types.length}): ');
    final input = stdin.readLineSync()?.trim() ?? '';
    final index = int.tryParse(input);
    if (index != null && index >= 1 && index <= _types.length) {
      return _types[index - 1].key;
    }
    stdout.writeln('${_red}Opción inválida, intenta de nuevo.$_reset\n');
  }
}

String? _askScope() {
  stdout.write('\nScope/alcance (opcional, ej: auth, home, pagos): ');
  final input = stdin.readLineSync()?.trim() ?? '';
  return input.isEmpty ? null : input;
}

String _askDescription() {
  while (true) {
    stdout.write(
        '\nDescripción breve (obligatoria, máx $_maxDescriptionLength caracteres): ');
    final input = stdin.readLineSync()?.trim() ?? '';
    if (input.isEmpty) {
      stdout.writeln('${_red}La descripción es obligatoria.$_reset');
      continue;
    }
    if (input.length > _maxDescriptionLength) {
      stdout.writeln(
          '${_red}La descripción supera los $_maxDescriptionLength caracteres (${input.length}).$_reset');
      continue;
    }
    return input;
  }
}

String? _askTicket() {
  stdout.write(
      '\nID del ticket / User Story de Azure DevOps (opcional, ej: 1234 o #1234): ');
  final raw = stdin.readLineSync()?.trim() ?? '';
  if (raw.isEmpty) return null;
  return raw.startsWith('#') ? raw : '#$raw';
}

String _buildMessage({
  required String type,
  required String? scope,
  required String description,
  required String? ticket,
}) {
  final scopePart = (scope != null && scope.isNotEmpty) ? '($scope)' : '';
  final ticketPart = ticket != null ? ' $ticket' : '';
  return '$type$scopePart: $description$ticketPart';
}

void _runCommit(String message) {
  stdout.writeln('\n${_cyan}Ejecutando: git commit -m "$message"$_reset\n');
  final result = Process.runSync('git', ['commit', '-m', message]);

  final out = result.stdout.toString().trim();
  final err = result.stderr.toString().trim();
  if (out.isNotEmpty) stdout.writeln(out);
  if (err.isNotEmpty) stderr.writeln(err);

  if (result.exitCode == 0) {
    stdout.writeln('\n$_green✔ Commit realizado con éxito.$_reset');
  } else {
    stdout.writeln(
        '\n$_red✖ El commit fue rechazado (código ${result.exitCode}).$_reset');
    exit(result.exitCode);
  }
}
