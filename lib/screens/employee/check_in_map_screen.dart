import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../config/app_config.dart';
import '../../models/entities.dart';
import '../../theme/app_theme.dart';
import '../../widgets/futuristic.dart';

/// Map-based check-in with geofence validation. The employee can only register
/// a checada when their location is inside the allowed radius of the obra.
class CheckInMapScreen extends StatefulWidget {
  final Obra? obra;
  const CheckInMapScreen({super.key, this.obra});

  @override
  State<CheckInMapScreen> createState() => _CheckInMapScreenState();
}

class _CheckInMapScreenState extends State<CheckInMapScreen> {
  static const Distance _distance = Distance();

  final MapController _map = MapController();

  late final double _obraLat = widget.obra?.lat ?? AppConfig.obraLat;
  late final double _obraLng = widget.obra?.lng ?? AppConfig.obraLng;
  late final double _radius =
      (widget.obra?.radioMetros ?? AppConfig.geofenceRadiusMeters).toDouble();
  late final LatLng _obra = LatLng(_obraLat, _obraLng);

  // Default just inside the geofence so the map is meaningful without GPS.
  late LatLng _me = LatLng(_obraLat + 0.0006, _obraLng + 0.0004);
  bool _simulateOutside = false;
  /// On web/headless agents GPS is often far from the obra; keep a safe
  /// in-geofence anchor for demos while still allowing real GPS on devices.
  bool _anchorToObra = kIsWeb;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _tryGetLocation();
  }

  double get _meters =>
      _distance.as(LengthUnit.Meter, _currentMe, _obra);

  bool get _inside => _meters <= _radius;

  LatLng get _nearObra => LatLng(_obraLat + 0.0006, _obraLng + 0.0004);

  LatLng get _currentMe {
    if (_simulateOutside) {
      return LatLng(_obraLat + 0.004, _obraLng + 0.004);
    }
    if (_anchorToObra) return _nearObra;
    return _me;
  }

  Future<void> _tryGetLocation() async {
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (enabled) {
        var perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.always ||
            perm == LocationPermission.whileInUse) {
          final pos = await Geolocator.getCurrentPosition(
            timeLimit: const Duration(seconds: 6),
          );
          if (mounted) {
            setState(() => _me = LatLng(pos.latitude, pos.longitude));
            _map.move(_currentMe, 16);
          }
        }
      }
    } catch (_) {
      // Fall back to default location (e.g. web without permission).
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inside = _inside;
    final meters = _meters;
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar checada')),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _currentMe,
              initialZoom: 15.5,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.checador.empleado',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _obra,
                    radius: _radius,
                    useRadiusInMeter: true,
                    color: (inside ? AppColors.green : AppColors.pink)
                        .withOpacity(0.15),
                    borderColor: inside ? AppColors.green : AppColors.pink,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _obra,
                    width: 46,
                    height: 46,
                    child: const _Pin(
                        icon: Icons.location_on, color: AppColors.amber),
                  ),
                  Marker(
                    point: _currentMe,
                    width: 44,
                    height: 44,
                    child: _Pin(
                        icon: Icons.person_pin_circle,
                        color: inside ? AppColors.cyan : AppColors.pink),
                  ),
                ],
              ),
            ],
          ),
          // Top status banner
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 70, 16, 0),
              child: GlassCard(
                glowColor: inside ? AppColors.green : AppColors.pink,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(inside ? Icons.check_circle_rounded : Icons.block_rounded,
                        color: inside ? AppColors.green : AppColors.pink,
                        size: 30),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inside
                                ? 'Dentro del área permitida'
                                : 'Fuera del área permitida',
                            style: TextStyle(
                                color: inside ? AppColors.green : AppColors.pink,
                                fontWeight: FontWeight.w700,
                                fontSize: 16),
                          ),
                          Text(
                            'A ${meters.toStringAsFixed(0)} m de la obra · límite ${_radius.toStringAsFixed(0)} m',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom controls
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.place_rounded,
                              color: AppColors.cyan, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('Anclar a la obra (pruebas)',
                                style: TextStyle(color: AppColors.textMuted)),
                          ),
                          Switch(
                            value: _anchorToObra,
                            activeThumbColor: AppColors.cyan,
                            onChanged: (v) => setState(() {
                              _anchorToObra = v;
                              if (v) _simulateOutside = false;
                            }),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.explore_rounded,
                              color: AppColors.pink, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('Simular estar fuera del área',
                                style: TextStyle(color: AppColors.textMuted)),
                          ),
                          Switch(
                            value: _simulateOutside,
                            activeThumbColor: AppColors.pink,
                            onChanged: (v) => setState(() {
                              _simulateOutside = v;
                              if (v) _anchorToObra = false;
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Opacity(
                        opacity: inside ? 1 : 0.45,
                        child: IgnorePointer(
                          ignoring: !inside,
                          child: NeonButton(
                            label: _locating
                                ? 'Ubicando...'
                                : 'Registrar checada',
                            icon: Icons.photo_camera_rounded,
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ),
                      ),
                      if (!inside)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'Acércate a la obra para poder checar',
                            style: TextStyle(
                                color: AppColors.pink, fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 210,
            child: FloatingActionButton.small(
              backgroundColor: AppColors.bg2,
              onPressed: _tryGetLocation,
              child: const Icon(Icons.my_location_rounded,
                  color: AppColors.cyan),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _Pin({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg2,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.6), blurRadius: 14),
        ],
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }
}
