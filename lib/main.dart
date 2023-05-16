import 'package:cmtchat_app/theme.dart';
import 'package:flutter/material.dart';
import 'composition_root.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CompositionRoot.configure();
  final director = CompositionRoot.director();
  runApp(MyApp(director));
}

class MyApp extends StatelessWidget {
  final Widget director;

  const MyApp(this.director, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Cot',
      debugShowCheckedModeBanner: false,
      theme: lightTheme(context),
      darkTheme: darkTheme(context),
      home: director,
    );
  }
}
