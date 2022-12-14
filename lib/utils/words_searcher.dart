import 'package:puppeteer/puppeteer.dart';
import 'package:html/dom.dart';
import 'package:words_searcher/models/query_result_model.dart';
import 'package:words_searcher/models/result_model.dart';

class WordsSearcher {
  static List<String> _words = [];
  static bool _wordsSetted = false;

  static const BASE_URL = "https://www.google.com/search?q=";

  static void setWords(List<String> words) {
    // _words = words;
    _words.clear();
    for (var word in words) {
      _words.addAll([word, "$word&start=10", "$word&start=20"]);
    }
    if (!_wordsSetted) _wordsSetted = true;
  }

  static List<String> getWords() {
    List<String> toRet = [];
    toRet.addAll(_words);
    return toRet;
  }

  static Future<List<ResultModel>> searchWords() async {
    if (!_wordsSetted) return [];
    print("funzione chiamata");
    /*return await Future.wait(
      _words.map(
        (word) {
          return puppeteer.launch(headless: true).then(
                (browser) async => await browser.newPage().then(
                  (page) async {
                    print("iniziato");
                    page.waitForNavigation();
                    return await page.goto("$BASE_URL$word").then(
                      (res) async {
                        var doc = Document.html(await res.text);
                        var results = doc.querySelectorAll(
                            //"#rso > div.MjjYud > div > div > div.Z26q7c.UK95Uc.jGGQ5e.VGXe8 > div > a");
                            "#rso > div");
                        print("$word: ${results.where((element) => [
                              "MjjYud",
                              "hlcw0c"
                            ].contains(element.className)).map((element) {
                          return "${element.querySelector(".yuRUbf > a > h3")?.innerHtml}, ${element.className}";
                        })}");

                        browser.close().then(
                              (value) => print("browser chiuso"),
                            );
                        return "ciao";
                      },
                    );
                  },
                ),
              );
        },
      ),
    );*/
    return puppeteer.launch(headless: true).then(
      (browser) async {
        var toRet = await Future.wait(
          _words.map((word) {
            return browser.newPage().then(
              (page) async {
                print("iniziato");
                page.waitForNavigation();
                print("$BASE_URL$word");
                return await page.goto("$BASE_URL$word").then(
                  (res) async {
                    var doc = Document.html(await res.text);
                    var results = doc.querySelectorAll("#rso > div");
                    // print("$word: ${results.where((element) => [
                    //       "MjjYud",
                    //       "hlcw0c"
                    //     ].contains(element.className)).map((element) {
                    //   return "${element.querySelector(".yuRUbf > a > h3")?.innerHtml}, ${element.className}";
                    // }).toList()}, length: ${results.length}");
                    print(ResultModel(
                        word: word,
                        results: results
                            .where((element) => ["MjjYud", "hlcw0c"]
                                .contains(element.className))
                            .map((element) =>
                                // "${element.querySelector(".yuRUbf > a > h3")?.innerHtml}, ${element.className}",
                                QueryResultModel(
                                    titleValue: element.querySelector(
                                                ".yuRUbf > a > h3") !=
                                            null
                                        ? element
                                            .querySelector(".yuRUbf > a > h3")!
                                            .innerHtml
                                        : "N/D",
                                    url: element
                                                .querySelector(".yuRUbf > a")
                                                ?.attributes['href'] !=
                                            null
                                        ? element
                                            .querySelector(".yuRUbf > a")!
                                            .attributes['href']!
                                        : "N/D"))
                            .toList()));

                    return ResultModel(
                        word: word,
                        results: results
                            .where((element) => ["MjjYud", "hlcw0c"]
                                .contains(element.className))
                            .map(
                              (element) =>
                                  // "${element.querySelector(".yuRUbf > a > h3")?.innerHtml}, ${element.className}",
                                  QueryResultModel(
                                titleValue:
                                    element.querySelector(".yuRUbf > a > h3") !=
                                            null
                                        ? element
                                            .querySelector(".yuRUbf > a > h3")!
                                            .innerHtml
                                        : "N/D",
                                url: element
                                            .querySelector(".yuRUbf > a")
                                            ?.attributes['href'] !=
                                        null
                                    ? element
                                        .querySelector(".yuRUbf > a")!
                                        .attributes['href']!
                                    : "N/D",
                              ),
                            )
                            .where(
                              (element) => element.titleValue != "N/D",
                            )
                            .toList());
                  },
                );
              },
            );
          }),
        );
        browser.close().then(
              (value) => print("browser chiuso"),
            );
        return toRet;
      },
    );

    return [];
  }
}
