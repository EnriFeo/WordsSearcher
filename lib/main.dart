import 'package:flutter/material.dart';
import 'package:words_searcher/models/models.dart';
import 'utils/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  String error = "";
  List<ResultModel> results = [];
  List<String> words = [];

  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void parseWords(String text) async {
    //GETTING WORDS
    List<String> words =
        text.split(RegExp(r"\n")).map((e) => e.trim()).toList();

    for (int i = 0; i < words.length; i++) {
      // CHECKING WORDS
      if (!RegExp(r"^([a-zA-Z]+\s{0,1})+[a-zA-Z]+$").hasMatch(words[i])) {
        print("errore su \"${words[i]}\"");
        return;
      } else {
        // REPLACING WORDS' SPACES
        var splittedWord = words[i].split(RegExp(r"\s"));
        if (splittedWord.length > 1) {
          words[i] = splittedWord.join("+");
        }
      }
    }
    print(words);
    setState(() {
      WordsSearcher.setWords(words);
      waitAndGet();
    });
  }

  Future<void> waitAndGet() async {
    List<String> wordstmp = WordsSearcher.getWords();
    //String urlTmp = widget._url_inserted;
    await Future.delayed(
      const Duration(milliseconds: 5000),
      () async {
        print("secondo passato");
        var currentWords = WordsSearcher.getWords();
        print("$wordstmp == $currentWords");
        print(wordstmp == currentWords);
        if (wordstmp.length == currentWords.length &&
            currentWords.every((element) => wordstmp.contains(element))) {
          print("si comincia");
          await WordsSearcher.searchWords().then((badresults) {
            List<ResultModel> goodresults = [];
            print("ok entrato");
            currentWords.removeWhere((element) =>
                element.contains("&start=10") || element.contains("&start=20"));
            print("passato il filtering");
            for (var word in currentWords) {
              print("$word");
              var pag1 =
                  badresults.firstWhere((element) => element.word == word);
              print("trovata pag1");
              var pag2 = badresults
                  .firstWhere((element) => element.word == "$word&start=10");
              print("trovata pag2");
              var pag3 = badresults
                  .firstWhere((element) => element.word == "$word&start=20");
              print("trovata pag3");
              pag1.results.addAll(pag2.results);
              print("aggiunta pag2");
              pag1.results.addAll(pag3.results);
              print("aggiunta pag3");
              goodresults.add(pag1);
            }
            setState(() {
              widget.results = goodresults;
            });
          }).catchError((error) => print("errore: $error"));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Anadir palabras"),
                    TextField(
                      minLines: 6,
                      maxLines: null,
                      onChanged: (value) => parseWords(value),
                    ),
                  ]),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.results.isNotEmpty
                      ? SizedBox(
                          height: 452,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView(
                              children: widget.results
                                  .map((e) => ExpansionTile(
                                        title:
                                            Text(e.word.split("+").join(" ")),
                                        children: e.results
                                            .toList()
                                            .sublist(
                                                0,
                                                e.results.length > 10
                                                    ? 10
                                                    : e.results.length - 1)
                                            .map((r) => ListTile(
                                                  title: Text(r.titleValue),
                                                  subtitle: Text(r.url),
                                                ))
                                            .toList(),
                                      ))
                                  .toList(),
                            ),
                          ),
                        )
                      : const Center(
                          child: Text("aquí se mostrarán los resultados"),
                        ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
