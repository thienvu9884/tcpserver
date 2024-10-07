import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tcpserver/models/client_model.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  late Client client;
  List<String> serverLogs = [];
  TextEditingController controller = TextEditingController();

  @override
  initState() {
    super.initState();

    client = Client(
      // hostname: "172.20.10.3",
      hostname: "0.0.0.0",
      port: 4040,
      onData: onData,
      onError: onError,
    );
  }

  onData(Uint8List data) {
    DateTime time = DateTime.now();
    serverLogs
        .add("${time.hour}h${time.minute} : ${String.fromCharCodes(data)}");
    setState(() {});
  }

  onError(dynamic error) {
    print(error);
  }

  @override
  dispose() {
    controller.dispose();
    client.disconnect();
    super.dispose();
  }

  confirmReturn() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("ATTENTION"),
          content: const Text(
              "Quitter cette page déconnectera le client du serveur de socket"),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Quitter", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child:
                  const Text("Annuler", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: confirmReturn,
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        "Client",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: client.connected ? Colors.green : Colors.red,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(3)),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          client.connected ? 'Connected' : 'Disconnected',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    child: Text(!client.connected
                        ? 'Connect to Client'
                        : 'Disconnect from Client'),
                    onPressed: () async {
                      if (client.connected) {
                        await client.disconnect();
                        serverLogs.clear();
                      } else {
                        await client.connect();
                      }
                      setState(() {});
                    },
                  ),
                  const Divider(
                    height: 30,
                    thickness: 1,
                    color: Colors.black12,
                  ),
                  Expanded(
                    flex: 1,
                    child: ListView(
                      children: serverLogs.map((String log) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(log),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.grey,
            height: 80,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Message to send :',
                        style: TextStyle(
                          fontSize: 8,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: controller,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                MaterialButton(
                  onPressed: () {
                    controller.text = "";
                  },
                  minWidth: 30,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: const Icon(Icons.clear),
                ),
                const SizedBox(
                  width: 15,
                ),
                MaterialButton(
                  onPressed: () {
                    client.write(controller.text);
                    controller.text = "";
                  },
                  minWidth: 30,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: const Icon(Icons.send),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
