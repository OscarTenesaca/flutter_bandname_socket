import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/socket_services.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'StatusServer: ${socketService.getServerstatus}',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          print('eontuhoentuheot');
          socketService.getsocket.emit("emitir-mensaje", {
            'nombre': 'Flutter',
            'mensaje': 'Hola desde flutter',
          });
        },
      ),
    );
  }
}
