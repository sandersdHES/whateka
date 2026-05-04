import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Avatar Whateka v5 — version simplifiee.
///
/// Plus de paper-doll, plus de marche : 5 personnages cartoon STATIQUES
/// qui font signe de la main droite (le bras est leve dans le SVG). Le
/// widget anime uniquement :
///   - un leger bob vertical (haut-bas, comme une respiration)
///   - une legere rotation oscillante (effet "salut joyeux")
///
/// Le compteur de metres marches est conserve (cumul du bob) pour ne pas
/// casser le profil utilisateur.
class AvatarPromenade extends StatefulWidget {
  final int avatarId;
  final double height;
  final double speed; // ignore mais garde pour API compat
  final double initialMeters;
  final ValueChanged<double>? onMetersWalked;

  const AvatarPromenade({
    super.key,
    required this.avatarId,
    this.height = 240,
    this.speed = 0,
    this.initialMeters = 0,
    this.onMetersWalked,
  });

  @override
  State<AvatarPromenade> createState() => _AvatarPromenadeState();
}

class _AvatarPromenadeState extends State<AvatarPromenade>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _t = 0; // temps en secondes
  double _metersWalked = 0;
  double _lastReportedMeters = -1;
  int _lastTickMs = 0;

  @override
  void initState() {
    super.initState();
    _metersWalked = widget.initialMeters;
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final nowMs = elapsed.inMilliseconds;
    final dt = (nowMs - _lastTickMs) / 1000.0;
    _lastTickMs = nowMs;
    _t += dt;

    // Compteur de metres : 1 m / s pour preserver l'effet "il marche".
    _metersWalked += dt * 1.0;
    final intMeters = _metersWalked.floorToDouble();
    if (intMeters != _lastReportedMeters) {
      _lastReportedMeters = intMeters;
      widget.onMetersWalked?.call(_metersWalked);
    }
    if (mounted) setState(() {});
  }

  /// Bob vertical : oscille de 0 a -4 px sur 1.5s. Comme une respiration.
  double _bob() => math.sin(_t * 4) * -3;

  /// Rotation oscillante : ±3° sur 2s. Donne un effet "salut joyeux".
  double _tilt() => math.sin(_t * 3) * 0.05; // 0.05 rad ≈ 3°

  @override
  Widget build(BuildContext context) {
    final asset = WhatekaAvatar.byId(widget.avatarId).filename;
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Center(
        child: Transform.translate(
          offset: Offset(0, _bob()),
          child: Transform.rotate(
            angle: _tilt(),
            alignment: Alignment.bottomCenter,
            child: SvgPicture.asset(
              'assets/avatars/$asset',
              width: 200,
              height: 240,
            ),
          ),
        ),
      ),
    );
  }
}

/// Liste statique des 5 avatars.
class WhatekaAvatar {
  final int id;
  final String name;
  final String filename;
  const WhatekaAvatar(this.id, this.name, this.filename);

  static const all = [
    WhatekaAvatar(1, 'Sam', '01_sam.svg'),
    WhatekaAvatar(2, 'Lia', '02_lia.svg'),
    WhatekaAvatar(3, 'Tom', '03_tom.svg'),
    WhatekaAvatar(4, 'Anna', '04_anna.svg'),
    WhatekaAvatar(5, 'Max', '05_max.svg'),
  ];

  static WhatekaAvatar byId(int id) =>
      all.firstWhere((a) => a.id == id, orElse: () => all.first);
}
