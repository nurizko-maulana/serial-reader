// import 'dart:developer';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_libserialport/flutter_libserialport.dart';

// void main() => runApp(const ExampleApp());

// class ExampleApp extends StatefulWidget {
//   const ExampleApp({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _ExampleAppState createState() => _ExampleAppState();
// }

// extension IntToString on int {
//   String toHex() => '0x${toRadixString(16)}';
//   String toPadded([int width = 3]) => toString().padLeft(width, '0');
//   String toTransport() {
//     switch (this) {
//       case SerialPortTransport.usb:
//         return 'USB';
//       case SerialPortTransport.bluetooth:
//         return 'Bluetooth';
//       case SerialPortTransport.native:
//         return 'Native';
//       default:
//         return 'Unknown';
//     }
//   }
// }

// class _ExampleAppState extends State<ExampleApp> {
//   var availablePorts = [];

//   @override
//   void initState() {
//     super.initState();
//     initPorts();
//   }

//   void initPorts() {
//     setState(() => availablePorts = SerialPort.availablePorts);
//   }

//   Uint8List _stringToUint8List(String data) {
//     List<int> codeUnits = data.codeUnits;
//     Uint8List uint8list = Uint8List.fromList(codeUnits);
//     return uint8list;
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<String> availPort = SerialPort.availablePorts;
//     log("Available Port: $availPort");
//     SerialPort port1 = SerialPort('/dev/cu.URT2');
//     try {
//       print(
//           "Written Byte ${port1.write(_stringToUint8List("Hello"))}");
//     } on SerialPortError catch (e, _) {
//       print(SerialPort.lastError);
//       port1.close();
//     }

//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Flutter Serial Port example'),
//         ),
//         body: Scrollbar(
//           child: ListView(
//             children: [
//               for (final address in availablePorts)
//                 Builder(builder: (context) {
//                   final port = SerialPort(address);
//                   return ExpansionTile(
//                     title: Text(address),
//                     children: [
//                       CardListTile('Description', port.description),
//                       CardListTile('Transport', port.transport.toTransport()),
//                       CardListTile('USB Bus', port.busNumber?.toPadded()),
//                       CardListTile('USB Device', port.deviceNumber?.toPadded()),
//                       CardListTile('Vendor ID', port.vendorId?.toHex()),
//                       CardListTile('Product ID', port.productId?.toHex()),
//                       CardListTile('Manufacturer', port.manufacturer),
//                       CardListTile('Product Name', port.productName),
//                       CardListTile('Serial Number', port.serialNumber),
//                       CardListTile('MAC Address', port.macAddress),
//                     ],
//                   );
//                 }),
//             ],
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           // ignore: sort_child_properties_last
//           child: const Icon(Icons.refresh),
//           onPressed: initPorts,
//         ),
//       ),
//     );
//   }
// }

// class CardListTile extends StatelessWidget {
//   final String name;
//   final String? value;

//   const CardListTile(this.name, this.value, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: ListTile(
//         title: Text(value ?? 'N/A'),
//         subtitle: Text(name),
//       ),
//     );
//   }
// }



//TODO 

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:quick_usb/quick_usb.dart';

void main() {
  runApp(const MyHome());
}

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return _buildColumn();
  }

  void log(String info) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(info)));
  }

  Widget _buildColumn() {
    return Column(
      children: [
        _init_exit(),
        _getDeviceList(),
        _getDevicesWithDescription(),
        _getDeviceDescription(),
        if (Platform.isLinux) _setAutoDetachKernelDriver(),
        _has_request(),
        _open_close(),
        _get_set_configuration(),
        _claim_release_interface(),
        _bulk_transfer(),
      ],
    );
  }

  Widget _init_exit() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          child: const Text('init'),
          onPressed: () async {
            var init = await QuickUsb.init();
            log('init $init');
          },
        ),
        ElevatedButton(
          child: const Text('exit'),
          onPressed: () async {
            await QuickUsb.exit();
            log('exit');
          },
        ),
      ],
    );
  }

  List<UsbDevice>? _deviceList;

  Widget _getDeviceList() {
    return ElevatedButton(
      child: const Text('getDeviceList'),
      onPressed: () async {
        _deviceList = await QuickUsb.getDeviceList();
        log('deviceList $_deviceList');
      },
    );
  }

  Widget _has_request() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          child: const Text('hasPermission'),
          onPressed: () async {
            var hasPermission = await QuickUsb.hasPermission(_deviceList!.first);
            log('hasPermission $hasPermission');
          },
        ),
        ElevatedButton(
          child: const Text('requestPermission'),
          onPressed: () async {
            await QuickUsb.requestPermission(_deviceList!.first);
            log('requestPermission');
          },
        ),
      ],
    );
  }

  Widget _open_close() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          child: const Text('openDevice'),
          onPressed: () async {
            var openDevice = await QuickUsb.openDevice(_deviceList!.first);
            log('openDevice $openDevice');
          },
        ),
        ElevatedButton(
          child: const Text('closeDevice'),
          onPressed: () async {
            await QuickUsb.closeDevice();
            log('closeDevice');
          },
        ),
      ],
    );
  }

  UsbConfiguration? _configuration;

  Widget _get_set_configuration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          child: const Text('getConfiguration'),
          onPressed: () async {
            _configuration = await QuickUsb.getConfiguration(0);
            log('getConfiguration $_configuration');
          },
        ),
        ElevatedButton(
          child: const Text('setConfiguration'),
          onPressed: () async {
            var setConfiguration =
                await QuickUsb.setConfiguration(_configuration!);
            log('setConfiguration $setConfiguration');
          },
        ),
      ],
    );
  }

  Widget _claim_release_interface() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          child: const Text('claimInterface'),
          onPressed: () async {
            var claimInterface =
                await QuickUsb.claimInterface(_configuration!.interfaces[0]);
            log('claimInterface $claimInterface');
          },
        ),
        ElevatedButton(
          child: const Text('releaseInterface'),
          onPressed: () async {
            var releaseInterface =
                await QuickUsb.releaseInterface(_configuration!.interfaces[0]);
            log('releaseInterface $releaseInterface');
          },
        ),
      ],
    );
  }

  Widget _bulk_transfer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          child: const Text('bulkTransferIn'),
          onPressed: () async {
            var endpoint = _configuration!.interfaces[0].endpoints
                .firstWhere((e) => e.direction == UsbEndpoint.DIRECTION_IN);
            var bulkTransferIn = await QuickUsb.bulkTransferIn(endpoint, 1024);
            log('bulkTransferIn ${hex.encode(bulkTransferIn)}');
          },
        ),
        ElevatedButton(
          child: const Text('bulkTransferOut'),
          onPressed: () async {
            var data = Uint8List.fromList(utf8.encode(''));
            var endpoint = _configuration!.interfaces[0].endpoints
                .firstWhere((e) => e.direction == UsbEndpoint.DIRECTION_OUT);
            var bulkTransferOut =
                await QuickUsb.bulkTransferOut(endpoint, data);
            log('bulkTransferOut $bulkTransferOut');
          },
        ),
      ],
    );
  }

  Widget _getDevicesWithDescription() {
    return ElevatedButton(
      child: const Text('getDevicesWithDescription'),
      onPressed: () async {
        var descriptions = await QuickUsb.getDevicesWithDescription();
        _deviceList = descriptions.map((e) => e.device).toList();
        log('descriptions $descriptions');
      },
    );
  }

  Widget _getDeviceDescription() {
    return ElevatedButton(
      child: const Text('getDeviceDescription'),
      onPressed: () async {
        var description =
            await QuickUsb.getDeviceDescription(_deviceList!.first);
        log('description ${description.toMap()}');
      },
    );
  }

  bool _autoDetachEnabled = false;
  Widget _setAutoDetachKernelDriver() {
    return ElevatedButton(
      child: const Text('setAutoDetachKernelDriver'),
      onPressed: () async {
        await QuickUsb.setAutoDetachKernelDriver(!_autoDetachEnabled);
        _autoDetachEnabled = !_autoDetachEnabled;
        log('setAutoDetachKernelDriver: $_autoDetachEnabled');
      },
    );
  }
}