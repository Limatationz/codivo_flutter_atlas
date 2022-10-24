import 'package:atlas/atlas.dart';
import 'package:atlas_test/clustered_map.dart';
import 'package:atlas_test/clustered_world_map.dart';
import 'package:atlas_test/normal_map.dart';
import 'package:atlas_test/single_marker_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_atlas/google_atlas.dart';
import 'package:osm_atlas/osm_atlas.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  AtlasProvider.instance = GoogleAtlas();
  //AtlasProvider.instance = OSMAtlas();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atlas Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AppWrapper(),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  late List<Widget> _pages;

  int _selectedIndex = 2;

  bool usingGoogleMaps = true;

  @override
  void initState() {
    Permission.location.request();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _pages = <Widget>[
      const NormalMap(),
      const ClusteredMap(),
      const SingleMarkerMap(),
      const ClusteredWorldMap()
    ];
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Atlas Demo'),
          actions: [
        IconButton(
          icon: const Icon(Icons.map),
          onPressed: () {
            setState(() {
              usingGoogleMaps = !usingGoogleMaps;
              AtlasProvider.instance = usingGoogleMaps
                  ? GoogleAtlas()
                  : OSMAtlas();
            });
          },
        ),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Normal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Clustered',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pin_drop),
            label: 'Single Marker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: 'World',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: _pages[_selectedIndex],
    );
  }
}

