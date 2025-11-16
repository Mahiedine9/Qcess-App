import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashAnimating extends SplashState {
  const SplashAnimating();
}

class SplashCompleted extends SplashState {
  const SplashCompleted();
}