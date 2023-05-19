import 'package:cmtchat_app/theme.dart';
import 'package:flutter/material.dart';
import 'composition_root.dart';

/// RethinkDb Address ///
// Needed to connect
final dbAddress = RethinkDbAddress(
    host: '172.29.32.1',
    port: 28015
);

/// Main ///
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CompositionRoot.configure(dbAddress);
  final director = CompositionRoot.root();
  runApp(MyApp(director));
}

class MyApp extends StatelessWidget {
  final Widget director;
  const MyApp(this.director, {super.key});

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
