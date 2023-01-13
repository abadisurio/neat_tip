import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neat_tip/screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return CupertinoPageRoute(
                builder: (_) => const Home(), settings: settings);
          // case '/signin':
          //   return CupertinoPageRoute(
          //       builder: (_) => const SignInPage(), settings: settings);
          // case '/register':
          //   return CupertinoPageRoute(
          //       builder: (_) => const RegisterPage(), settings: settings);
          // case '/root':
          //   return CupertinoPageRoute(
          //       builder: (_) => const RootPage(), settings: settings);
          // case '/shelter_detail':
          //   return CupertinoPageRoute(
          //       builder: (_) => const ShelterDetail(), settings: settings);
          // case '/shelter_new':
          //   return CupertinoPageRoute(
          //       builder: (_) => const ShelterNew(), settings: settings);
        }
        return null;
      },
      home: const Home(),
    );
  }
}

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
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
