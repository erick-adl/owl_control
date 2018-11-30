import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';

class HomeController implements BlocBase {
  static const platform =
      const MethodChannel('flutter.rortega.com.basicchannelcommunication');

  List<String> _onlineBoards =  new List<String>();
  String _status;

  HomeController() {
    platform.setMethodCallHandler(_handleMethod);
    _mqttConnect();
  }

  var _dataStatusController = StreamController<String>();

  Stream<String> get outDataStatus => _dataStatusController.stream;
  Sink<String> get inDataStatus => _dataStatusController.sink;

  var _dataOnlineBoardsController = StreamController<List<String>>();

  Stream<List<String>> get oudataOnlineBoardsController =>
      _dataOnlineBoardsController.stream;
  Sink<List<String>> get _indataOnlineBoardsController =>
      _dataOnlineBoardsController.sink;

  Future<Null> ShowBubbleControl() async =>
      await platform.invokeMethod('showNativeView');
  Future<Null> GetDataFromNative() async =>
      await platform.invokeMethod('getData');

  void sendListOnlineBoards(String s) {
    if (!_onlineBoards.contains(s)) {
      _onlineBoards.add(s);
    }
    _indataOnlineBoardsController.add(_onlineBoards);

  }


  int listLenght(){
    return _onlineBoards.length;
  }
  void sendDataStatus(dynamic c) {
    inDataStatus.add(c);
  }


  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "message":
        print(call.arguments);
        // sendData(call.arguments);
        return new Future.value(call.arguments);
    }
  }

  Future<int> _mqttConnect() async {
    await MqttUtilities.asyncSleep(3);

    final MqttClient client = MqttClient('iot.eclipse.org', '');

    client.logging(on: false);
    client.keepAlivePeriod = 20;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .keepAliveFor(20) // Must agree with the keep alive set above or not set
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    sendDataStatus('Conectando, aguarde...');
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on Exception catch (e) {
      sendDataStatus('Erro ao conectar - $e');
      client.disconnect();
    }

    /// Check we are connected
    if (client.connectionStatus.state == ConnectionState.connected) {
      sendDataStatus('Usuário conectado');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      sendDataStatus(
          'Falha de conexão - desconectando, status: ${client.connectionStatus}');
      client.disconnect();
    }

    /// Ok, lets try a subscription
    const String topic = 'owl/online-boards'; // Not a wildcard topic
    client.subscribe(topic, MqttQos.atMostOnce);

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      print('TOPIC >>> ${c[0].topic} PAYLOAD >>> $pt');
      sendListOnlineBoards(pt);
      
    });

    /// Lets publish to our topic
    // Use the payload builder rather than a raw buffer
    print('Publishing our topic');

    /// Our known topic to publish to
    const String pubTopic = 'owl/online-boards';
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString('camera de seguranca 1');

    /// Subscribe to it
    client.subscribe(pubTopic, MqttQos.exactlyOnce);

    /// Publish it
    client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload);
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  BuildContext context;
}

