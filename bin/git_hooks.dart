// Hook `commit-msg` que valida el estándar Conventional Commits.
// Se ejecuta automáticamente por git en cada commit (terminal, GitHub Desktop,
// VS Code, Android Studio, Sourcetree, etc.) una vez instalado con:
//   dart run git_hooks:git_hooks create bin/git_hooks.dart
// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:git_hooks/git_hooks.dart';

const Map<String, String> _typeDescriptions = {
  'feat': 'Nueva funcionalidad para el usuario',
  'fix': 'Corrección de un error o bug',
  'refactor': 'Cambio en el código que no corrige un bug ni añade una feature',
  'docs': 'Cambios únicamente en la documentación',
  'style': 'Cambios de formato, espacios, comas (sin impacto en la lógica)',
  'test': 'Añadir o corregir pruebas',
  'perf': 'Cambio de código orientado a mejorar el rendimiento',
  'chore': 'Tareas de mantenimiento, dependencias o configuración',
};

/// tipo(scope): descripción   |   tipo: descripción
final RegExp _conventionalCommitRegex = RegExp(
  '^(${_typeDescriptions.keys.join('|')})(\\([^()]+\\))?: .+\$',
);

/// Mensajes generados por git (merge, revert, autosquash) que no deben
/// pasar por la validación de Conventional Commits.
final RegExp _skipRegex = RegExp(
  r'^(Merge branch|Merge remote-tracking branch|Merge pull request|Merged PR|Revert "|fixup!|squash!)',
);

const String _red = '\x1B[31m';
const String _green = '\x1B[32m';
const String _yellow = '\x1B[33m';
const String _bold = '\x1B[1m';
const String _reset = '\x1B[0m';

void main(List<dynamic> arguments) {
  final Map<Git, UserBackFun> params = {
    Git.commitMsg: _validateCommitMsg,
  };
  GitHooks.call(arguments, params);
}

Future<bool> _validateCommitMsg() async {
  final rawMessage = Utils.getCommitEditMsg();
  final firstLine = _firstMeaningfulLine(rawMessage);

  if (firstLine.isEmpty) {
    _printError('El mensaje de commit está vacío.', firstLine);
    return false;
  }

  if (_skipRegex.hasMatch(firstLine)) {
    // Merges, reverts y autosquash no se validan.
    return true;
  }

  if (_conventionalCommitRegex.hasMatch(firstLine)) {
    stdout.writeln('$_green✔ Commit válido (Conventional Commits).$_reset');
    return true;
  }

  _printError('El mensaje de commit no cumple con Conventional Commits.', firstLine);
  return false;
}

String _firstMeaningfulLine(String rawMessage) {
  return rawMessage.split('\n').map((line) => line.trimRight()).firstWhere(
        (line) => line.trim().isNotEmpty && !line.trim().startsWith('#'),
        orElse: () => '',
      );
}

void _printError(String reason, String offendingLine) {
  stdout.writeln('');
  stdout.writeln('$_red$_bold✖  COMMIT RECHAZADO$_reset');
  stdout.writeln('$_red$reason$_reset');
  if (offendingLine.isNotEmpty) {
    stdout.writeln('$_red  "$offendingLine"$_reset');
  }
  stdout.writeln('');
  stdout.writeln('${_yellow}Formato esperado:$_reset');
  stdout.writeln('  tipo(scope): descripción #ticket');
  stdout.writeln('  tipo: descripción #ticket');
  stdout.writeln('');
  stdout.writeln('${_yellow}Tipos permitidos:$_reset');
  _typeDescriptions.forEach((type, description) {
    stdout.writeln('  - $type: $description');
  });
  stdout.writeln('');
  stdout.writeln('${_yellow}Ejemplos válidos:$_reset');
  stdout.writeln('  feat(auth): agregar login biometrico #1234');
  stdout.writeln('  fix(login): corregir crash al iniciar sesion #102');
  stdout.writeln('  chore: actualizar dependencias');
  stdout.writeln('');
  stdout.writeln(
      '${_yellow}Tip:$_reset usa "fvm dart run bin/cz.dart" para generar el mensaje automáticamente.');
  stdout.writeln('');
}
