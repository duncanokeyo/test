class Utils {
  String getMaxDisplayContent(String? content) {
    if (content == null) {
      return "";
    }

    if (content.length <= 100) {
      return content;
    }
    var sub = content.substring(0, content.length);
    return "{$sub}...";
  }
}

