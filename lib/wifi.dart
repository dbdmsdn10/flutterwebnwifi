import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'dart:io' show Platform;

class FlutterWifiIoT extends StatefulWidget {
  @override
  _FlutterWifiIoTState createState() => _FlutterWifiIoTState();
}

class _FlutterWifiIoTState extends State<FlutterWifiIoT> {
  @override
  Widget build(BuildContext poContext) {
    return Scaffold(body: getWidgets(poContext));
  }

  List<WifiNetwork> _htResultNetwork = [];
  bool _isEnabled = false;
  bool _isConnected = false;
  String ssid = "";
  String mssid = "";
  String title = "";
  String password = "";
  var wifiBSSID = "";
  var wifiIP = "";
  var wifiName = "";

  @override
  initState() {
    getWifis();

    super.initState();
  }

  getWifis() async {
    _isEnabled = await WiFiForIoTPlugin.isEnabled();
    _isConnected = await WiFiForIoTPlugin.isConnected();
    _htResultNetwork = await loadWifiList();
    setState(() {});
    if (_isConnected) {
      WiFiForIoTPlugin.getSSID().then((value) => setState(() {
        ssid = value;
      }));
    }
  }

  Future<List<APClient>> getClientList(
      bool onlyReachables, int reachableTimeout) async {
    List<APClient> htResultClient;
    try {
      htResultClient = await WiFiForIoTPlugin.getClientList(
          onlyReachables, reachableTimeout);
    } on PlatformException {
      htResultClient = List<APClient>();
    }

    return htResultClient;
  }

  Future<List<WifiNetwork>> loadWifiList() async {
    List<WifiNetwork> htResultNetwork;
    try {
      htResultNetwork = await WiFiForIoTPlugin.loadWifiList();
    } on PlatformException {
      htResultNetwork = List<WifiNetwork>();
    }

    return htResultNetwork;
  }

  isRegisteredWifiNetwork(String ssid) {
    return ssid == this.ssid;
  }

  Widget getWidgets(context) {
    WiFiForIoTPlugin.isConnected().then((val) => setState(() {
      _isConnected = val;
    }));
    WiFiForIoTPlugin.isEnabled().then((val) => setState(() {
      _isEnabled = val;
    }));

    return SingleChildScrollView(
      child: Column(
        // children: getButtonWidgetsForAndroid(context),
        children: [
          Container(
            color: Colors.blue,
            padding: EdgeInsets.only(top: 30),
            child: Center(
              child: Text(
                title,
                style: TextStyle(color: Colors.black54, fontSize: 35),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text('\n' + mssid + '\n'),
          TextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              icon: Icon(Icons.lock_outline),
              hintText: 'Your wifi password',
              labelText: 'password',
            ),
            keyboardType: TextInputType.text,
            onChanged: (value) {
              password = value;
            },
          ),
          RaisedButton(
            child: Text('connection'),
            onPressed: () {
              connect(mssid, password);
            },
          ),
          SizedBox(height: 10),
          Text(
            'Wi-Fis Found',
            style: TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
          ),
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                getWifis();
              }),

          Container(
            child: getList(context),
          )
        ],
      ),
    );
  }


  getList(contex) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (builder, i) {
        var network = _htResultNetwork[i];
        var isConnctedWifi = false;
        if (_isConnected)
          isConnctedWifi = isRegisteredWifiNetwork(network.ssid);

        if (_htResultNetwork != null && _htResultNetwork.length > 0) {
          return  Container(
            color: isConnctedWifi ? Colors.blueAccent : Colors.transparent,
            child: ListTile(
              title: Text(network.ssid),
              trailing: !isConnctedWifi
                  ? null
                  : OutlineButton(
                onPressed: () {
                  disconnect();
                },
                child: Text('Disconnet'),
              ),
              onTap: () {
                getssid(network.ssid);
              },
            ),
          );
        } else
          return Center(
            child: Text('No wifi found'),
          );
      },
      itemCount: _htResultNetwork.length,
      shrinkWrap: true,
    );
  }

  connect(String ssid, String password) async {

    var isConnected = await WiFiForIoTPlugin.connect(ssid,
        security: NetworkSecurity.WPA, password: password);
    if (isConnected) {
      wifiBSSID = await WifiInfo().getWifiBSSID();
      wifiIP = await WifiInfo().getWifiIP();
      wifiName = await WifiInfo().getWifiName();
      setState(() {
        title = wifiBSSID + "\n" + wifiIP + "\n" + wifiName;
      });
      print("성공");
    } else {
      print("실패");
    }
  }

  disconnect() async {
    await WiFiForIoTPlugin.disconnect();
    getWifis();
    getList(context);
  }

  getssid(String ssid) async {
    setState(() {
      this.mssid = ssid;
    });
  }
}

class PopupCommand {
  String command;
  String argument;

  PopupCommand(this.command, this.argument);
}
