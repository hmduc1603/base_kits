class DurationUtil {
  static String formatVideoDuration(Duration duration) {
    final hours = (duration.inHours);
    final minutes = (duration.inMinutes % 60);
    final ss = (duration.inSeconds % 60).toString().padLeft(2, '0');

    if (hours > 9) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:$ss';
    } else if (hours > 0) {
      return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}:$ss';
    } else if (minutes > 9) {
      return '${minutes.toString().padLeft(2, '0')}:$ss';
    } else {
      return '${minutes.toString().padLeft(1, '0')}:$ss';
    }
  }
}
