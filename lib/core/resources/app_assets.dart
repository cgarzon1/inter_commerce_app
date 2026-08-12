/// Centralized references to every image/icon asset the app ships with.
///
/// Same rule as `AppLocalizations`: nothing outside `presentation/`
/// should build an `assets/...` path by hand — add the physical file
/// under `assets/images/` or `assets/icons/` (already registered in
/// `pubspec.yaml`), add its constant here, and every widget reads that
/// constant instead of a raw string.
///
/// Empty for now — no image/icon assets exist yet. Gets populated
/// together with the design system integration (last step of the build).
library;

class AppImages {
  AppImages._();

  // static const String productPlaceholder = 'assets/images/product_placeholder.png';
}

class AppIcons {
  AppIcons._();

  // static const String cart = 'assets/icons/cart.svg';
}
