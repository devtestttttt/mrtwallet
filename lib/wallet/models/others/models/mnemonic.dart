class SelectedMnemonic {
  final int readIndex;
  SelectedMnemonic.notSelected(this.readIndex)
      : word = null,
        index = null;
  SelectedMnemonic.select(
      {required int this.index,
      required String this.word,
      required this.readIndex});

  final String? word;
  final int? index;
  bool get selected => word != null && index != null;

  @override
  bool operator ==(other) {
    if (other is! SelectedMnemonic) {
      return false;
    }
    if (word == null || index == null) {
      return false;
    }
    return word == other.word && index == other.index;
  }

  @override
  int get hashCode => word.hashCode ^ index.hashCode;
}
