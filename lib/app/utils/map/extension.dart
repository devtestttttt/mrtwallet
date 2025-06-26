extension QuickImutableMap<K, V> on Map<K, V> {
  Map<K, V> get imutable => Map<K, V>.unmodifiable(this);
  Map<K, V>? get imutableAndNullOnEmpty =>
      isEmpty ? null : Map<K, V>.unmodifiable(this);
  Map<K, V> get withOutNullValue => {
        for (final i in entries)
          if (i.value != null) i.key: i.value
      };
}
