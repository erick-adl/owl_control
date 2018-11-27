import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';


class HomeController implements BlocBase {
  static const platform =
      const MethodChannel('flutter.rortega.com.basicchannelcommunication');

  HomeController() {
    platform.setMethodCallHandler(_handleMethod);
    _mqttConnect();
  }

  var _dataController = StreamController<String>();

  Stream<String> get outDataStatus => _dataController.stream;
  Sink<String> get inDataStatus => _dataController.sink;

  Future<Null> ShowBubbleControl() async => await platform.invokeMethod('showNativeView');

    Future<Null> GetDataFromNative() async => await platform.invokeMethod('getData');

  
  void sendData(dynamic c) {
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

  final MqttClient client = MqttClient('test.mosquitto.org', '');

  client.logging(on: false);
  client.keepAlivePeriod = 20;
  
  final MqttConnectMessage connMess = MqttConnectMessage()
      .withClientIdentifier('Mqtt_MyClientUniqueId')
      .keepAliveFor(20) // Must agree with the keep alive set above or not set
      .withWillTopic('willtopic') // If you set this you must set a will message
      .withWillMessage('My Will message')
      .startClean() // Non persistent session for testing
      .withWillQos(MqttQos.atLeastOnce);
  sendData('EXAMPLE::Mosquitto client connecting....');
  client.connectionMessage = connMess;

  /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
  /// in some circumstances the broker will just disconnect us, see the spec about this, we however eill
  /// never send malformed messages.
  try {
    await client.connect();
  } on Exception catch (e) {
    sendData('EXAMPLE::client exception - $e');
    client.disconnect();
  }

  /// Check we are connected
  if (client.connectionStatus.state == ConnectionState.connected) {
    sendData('EXAMPLE::Mosquitto client connected');
  } else {
    /// Use status here rather than state if you also want the broker return code.
    sendData(
        'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
    client.disconnect();
    
  }

  /// Ok, lets try a subscription
  const String topic = 'test/lol'; // Not a wildcard topic
  client.subscribe(topic, MqttQos.atMostOnce);

  /// The client has a change notifier object(see the Observable class) which we then listen to to get
  /// notifications of published updates to each subscribed topic.
  client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    final MqttPublishMessage recMess = c[0].payload;
    final String pt =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    /// The above may seem a little convoluted for users only interested in the
    /// payload, some users however may be interested in the received publish message,
    /// lets not constrain ourselves yet until the package has been in the wild
    /// for a while.
    /// The payload is a byte buffer, this will be specific to the topic
    print(
        'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
    print('');
  });

  /// Lets publish to our topic
  // Use the payload builder rather than a raw buffer
  print('EXAMPLE::Publishing our topic');

  /// Our known topic to publish to
  const String pubTopic = 'Dart/Mqtt_client/testtopic';
  final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
  builder.addString('Hello from mqtt_client');

  /// Subscribe to it
  client.subscribe(pubTopic, MqttQos.exactlyOnce);

  /// Publish it
  client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload);

}





  @override
  void dispose() {
    // TODO: implement dispose
  }



}



