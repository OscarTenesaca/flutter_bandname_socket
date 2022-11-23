import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServicesStatus { Online, OffLine, Connecting }

class SocketService with ChangeNotifier {
  ServicesStatus _servicesStatus = ServicesStatus.Connecting;

  IO.Socket? _socket;

  ServicesStatus get getServerstatus => _servicesStatus;
  IO.Socket get getsocket => _socket!;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    // Dart client
    _socket = IO.io(
      'http://localhost:3001/',
      {
        'transports': ['websocket'],
        'autoConnect': true,
      },
    );

    _socket!.onConnect((_) {
      // print('connect');
      _servicesStatus = ServicesStatus.Online;
      notifyListeners();
    });
    // socket.on('event', (data) => print(data));
    _socket!.onDisconnect((_) {
      // print('disconnect');
      _servicesStatus = ServicesStatus.OffLine;
      notifyListeners();
    });

    // escucha en todas las pages
    // // new msg
    // socket.on('nuevo-mensaje', (payload) {
    //   log('nuevo-mensaje: $payload');
    //   log('nombre: ${payload['nombre']}');
    //   log('mensaje: ${payload['mensaje']}');
    //   log(payload.containsKey('mensaje2')
    //       ? '${payload['mensaje2']}'
    //       : 'no hay');
    // });
  }
}
// socket.emit('emitir-mensaje','Oscar');                                      enviar string
// socket.emit('emitir-mensaje',{nombre:'Oscar',mensaje: 'hola mundo'});        enviar map