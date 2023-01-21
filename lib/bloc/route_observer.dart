import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RouteObserverCubit extends Cubit<RouteObserver<PageRoute>> {
  RouteObserver<PageRoute> _routeObserver = RouteObserver<PageRoute>();
  RouteObserverCubit() : super(RouteObserver<PageRoute>());
  get routeObserver => _routeObserver;
  // void increment() => emit(state + 1);
  // List<CameraDescription> _routeObserver = [];
  void setRouteObserver(routeObserver) {
    _routeObserver = routeObserver;
    // emit(cameras);
  }
  // void decrement() => emit(state - 1);
}
