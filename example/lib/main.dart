import 'package:flutter/material.dart';
import 'package:my_lang/my_lang.dart';

import 'languages/src.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await myLang.setUp(listLocale: listLocale);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: myLang.welcomeBack,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: myLang.welcomeBackNameApp("Wong", "Lang") ?? ""),
    );
  }
}

const listLocale = [
  Locale('en'),
  Locale('vi'),
];

MyLang myLang = MyLang();

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              myLang.youhavepushedthebuttonthismanytimes,
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
                onPressed: () {
                  myLang.loadFileJson(
                      locale: myLang.locale.isEnglish
                          ? const Locale("vi")
                          : const Locale("en"));
                },
                child: Text(myLang.language))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: myLang.increment,
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
