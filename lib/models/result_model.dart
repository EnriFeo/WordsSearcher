import 'query_result_model.dart';

class ResultModel {
  String word;
  List<QueryResultModel> results;

  ResultModel({required this.word, required this.results});

  @override
  String toString() {
    return "{word: $word, results: $results}";
  }
}
