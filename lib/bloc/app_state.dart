part of 'app_cubit.dart';

@immutable
abstract class AppState {}

class AppInitial extends AppState {}

class AppLoading extends AppState {}

class AppReady extends AppState {
  final File image;
  final String link;
  AppReady({this.image, this.link});
}
