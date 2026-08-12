/// launch time via `--dart-define=FLAVOR=dev` (or `qa`); defaults to
enum AppFlavor {
  dev,
  qa;

  static AppFlavor fromString(String value) {
    return AppFlavor.values.firstWhere(
      (flavor) => flavor.name == value.trim().toLowerCase(),
      orElse: () => AppFlavor.dev,
    );
  }
}
