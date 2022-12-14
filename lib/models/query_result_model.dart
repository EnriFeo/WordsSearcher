class QueryResultModel {
  String titleValue;
  String url;

  QueryResultModel({required this.titleValue, required this.url});

  @override
  String toString() {
    return "{titleValue: $titleValue, url: $url}";
  }
}
