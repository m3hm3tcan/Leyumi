String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);

  if (h > 0) return "${h}h ${m}m ${s}s";
  if (m > 0) return "${m}m ${s}s";
  return "${s}s";
}

String formatDate(DateTime dt) {
  return "${dt.day}.${dt.month}.${dt.year} "
      "${dt.hour.toString().padLeft(2, '0')}:"
      "${dt.minute.toString().padLeft(2, '0')}";
}