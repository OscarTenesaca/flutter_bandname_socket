import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import '../model/band.dart';
import '../services/socket_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band(id: '1', name: 'Matallica', votes: 2),
    // Band(id: '2', name: 'Iron maiden', votes: 3),
    // Band(id: '3', name: 'Queen', votes: 3),
    // Band(id: '4', name: 'Ozzy', votes: 4),
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
// opt 1
// // escuchar el socket del band
//     socketService.getsocket.on('active-bands', (payload) {
//       print(payload);
//       bands = (payload as List).map((band) => Band.fronMap(band)).toList();
//       setState(() {});

// escuchar el socket del band
    socketService.getsocket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fronMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose/
    //Destruir o dejar de escuchar el socket del band
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.getsocket.off('active-bands');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Band names',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socketService.getServerstatus == ServicesStatus.Online)
                ? const Icon(Icons.check_circle, color: Colors.blue)
                : const Icon(Icons.offline_bolt, color: Colors.red),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          (bands.isNotEmpty) ? _showGraph() : Container(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, int index) => _bandTitle(bands[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: _addNewBand,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTitle(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key('${band.id}'),
      direction: DismissDirection.startToEnd,
      background: Container(
        padding: const EdgeInsets.only(left: 8),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band'),
        ),
      ),
      onDismissed: (direction) {
        print(band.id);
        socketService.getsocket.emit('delete-band', {'id': band.id});
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            band.name!.substring(0, 2),
          ),
        ),
        title: Text('${band.name}'),
        trailing: Text('${band.votes}'),
        onTap: () {
          print(band.id);

          socketService.getsocket.emit("vote-band", {
            'id': band.id,
          });
        },
      ),
    );
  }

  void _addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('New band name'),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                  child: Text('Add'),
                  elevation: 5,
                  textColor: Colors.blue,
                  onPressed: () => addBandToList(textController.text)),
            ],
          );
        },
      );
    } else {
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text('New band name'),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('add'),
                  onPressed: () => addBandToList(textController.text),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text('Dismiss'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          });
    }
  }

  addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    if (name.length > 1) {
      socketService.getsocket.emit('add-band', {
        'name': name,
      });
    }
    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = {};
    for (var band in bands) {
      dataMap.putIfAbsent('${band.name}', () => band.votes!.toDouble());
    }

    final List<Color> colorList = [
      Colors.blue,
      Colors.red,
      Colors.yellow,
      Colors.pink,
      Colors.green
    ];

    return SizedBox(
        width: double.infinity,
        height: 200,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 3.2,
          colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          // ringStrokeWidth: 32,
          centerText: "HYBRID",
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendShape: BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: false,
            showChartValuesOutside: false,
            decimalPlaces: 1,
          ),
          // gradientList: ---To add gradient colors---
          // emptyColorGradient: ---Empty Color gradient---
        ));
  }
}
