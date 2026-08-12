/// `presentation/` should call this.
String formatCategoryLabel(String slug) {
  if (slug.isEmpty) return slug;

  return slug.split('-').map((word) {
    if (word.isEmpty) return word;
    return '${word[0].toUpperCase()}${word.substring(1)}';
  }).join(' ');
}
