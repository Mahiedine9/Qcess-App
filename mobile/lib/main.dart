import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/bloc_observer.dart';
import 'package:mobile/core/di/di.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDependencies();
  Bloc.observer = SimpleBlocObserver(); //for debugging
  runApp(const MyApp());
}
