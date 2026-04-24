import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart';

/// Affiche le personnage choisi par l'utilisateur qui se promene en boucle
/// dans une bande horizontale. Deux animations de demi-tour :
/// - Bord droit : ludique (stop, bulle "?", saut + flip) ~750 ms
/// - Bord gauche : sobre (saut vertical + flip horizontal) ~500 ms
class AvatarPromenade extends StatefulWidget {
  final int avatarId;
  final double height;
  final double speed; // pixels par seconde

  const AvatarPromenade({
    super.key,
    required this.avatarId,
    this.height = 200,
    this.speed = 40,
  });

  @override
  State<AvatarPromenade> createState() => _AvatarPromenadeState();
}

enum _PromenadeState { walking, turningRight, turningLeft }

class _AvatarPromenadeState extends State<AvatarPromenade>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  // Taille affichee du perso (conserve le ratio 110:220 = 1:2).
  static const double _avatarWidth = 80;
  static const double _avatarHeight = 160;
  // Largeur reelle de la bande, mise a jour via LayoutBuilder.
  double _bandWidth = 360;

  double _x = 20;
  int _direction = 1;
  _PromenadeState _state = _PromenadeState.walking;
  int _turnStartMs = 0;
  int _lastTickMs = 0;
  double _walkTime = 0;

  @override
  void initState() {
    super.initState();
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

    if (_state == _PromenadeState.walking) {
      _x += _direction * widget.speed * dt;
      _walkTime += dt;
      if (_x >= _bandWidth - _avatarWidth - 10) {
        _x = _bandWidth - _avatarWidth - 10;
        _state = _PromenadeState.turningRight;
        _turnStartMs = nowMs;
      } else if (_x <= 10) {
        _x = 10;
        _state = _PromenadeState.turningLeft;
        _turnStartMs = nowMs;
      }
    } else {
      final dur = nowMs - _turnStartMs;
      if (_state == _PromenadeState.turningRight && dur >= 750) {
        _direction = -1;
        _state = _PromenadeState.walking;
      } else if (_state == _PromenadeState.turningLeft && dur >= 500) {
        _direction = 1;
        _state = _PromenadeState.walking;
      }
    }
    if (mounted) setState(() {});
  }

  /// Balancement vertical pendant la marche (3 px).
  double _bob() {
    if (_state != _PromenadeState.walking) return 0;
    return math.sin(_walkTime * 8) * 3;
  }

  /// Recul de 8 px au debut du demi-tour a droite.
  double _recoilX() {
    if (_state != _PromenadeState.turningRight) return 0;
    final dur = _lastTickMs - _turnStartMs;
    if (dur < 200) {
      final t = dur / 200;
      return -8 * _easeOut(t);
    }
    return -8;
  }

  /// Offset vertical selon l'animation en cours.
  double _jumpY() {
    final dur = _lastTickMs - _turnStartMs;
    if (_state == _PromenadeState.turningLeft) {
      if (dur < 200) return -10 * _easeOut(dur / 200);
      if (dur < 350) return -10;
      if (dur < 500) return -10 * (1 - (dur - 350) / 150);
      return 0;
    }
    if (_state == _PromenadeState.turningRight) {
      if (dur >= 500 && dur < 650) {
        final t = (dur - 500) / 150;
        return -4 * math.sin(t * math.pi);
      }
    }
    return 0;
  }

  /// ScaleX selon l'animation (1 = regarde a droite, -1 = a gauche).
  double _scaleX() {
    final dur = _lastTickMs - _turnStartMs;
    final base = _direction.toDouble();
    if (_state == _PromenadeState.turningLeft) {
      if (dur < 200) return base;
      if (dur < 350) {
        final t = (dur - 200) / 150;
        return base * (1 - 2 * t);
      }
      return -base;
    }
    if (_state == _PromenadeState.turningRight) {
      if (dur < 500) return base;
      if (dur < 650) {
        final t = (dur - 500) / 150;
        return base * (1 - 2 * t);
      }
      return -base;
    }
    return base;
  }

  /// Leger squash-stretch pendant le saut gauche.
  double _scaleY() {
    if (_state != _PromenadeState.turningLeft) return 1.0;
    final dur = _lastTickMs - _turnStartMs;
    if (dur < 200) return 1.0 + 0.08 * (dur / 200);
    if (dur < 350) return 1.08 - 0.08 * ((dur - 200) / 150);
    return 1.0;
  }

  /// Affiche la bulle "?" pendant la phase reflexion du demi-tour droit.
  bool _showBubble() {
    if (_state != _PromenadeState.turningRight) return false;
    final dur = _lastTickMs - _turnStartMs;
    return dur >= 200 && dur < 500;
  }

  double _easeOut(double t) => 1 - (1 - t) * (1 - t);

  @override
  Widget build(BuildContext context) {
    final filename = _avatarFilename(widget.avatarId);

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // La bande est limitee a la largeur du parent (p.ex. ResponsiveCenter).
          // On met a jour _bandWidth pour que les demi-tours se fassent aux vrais
          // bords visibles, pas aux bords de l'ecran complet.
          _bandWidth = constraints.maxWidth;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: _x + _recoilX(),
                bottom: 0,
                child: Transform.translate(
                  offset: Offset(0, _bob() + _jumpY()),
                  child: Transform.scale(
                    scaleX: _scaleX(),
                    scaleY: _scaleY(),
                    alignment: Alignment.bottomCenter,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        SvgPicture.asset(
                          'assets/avatars/$filename',
                          width: _avatarWidth,
                          height: _avatarHeight,
                        ),
                        if (_showBubble())
                          const Positioned(
                            top: -8,
                            right: 4,
                            child: _ThinkBubble(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _avatarFilename(int id) {
    const names = {
      1: '01_sam.svg',
      2: '02_max.svg',
      3: '03_lina.svg',
      4: '04_amadou.svg',
      5: '05_theo.svg',
      6: '06_chloe.svg',
      7: '07_lucas.svg',
      8: '08_yuki.svg',
      9: '09_emma.svg',
      10: '10_nathan.svg',
    };
    return names[id] ?? '01_sam.svg';
  }
}

class _ThinkBubble extends StatelessWidget {
  const _ThinkBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.line, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        '?',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.cyan,
          height: 1.0,
        ),
      ),
    );
  }
}

/// Liste statique des avatars avec leur nom affichable.
class WhatekaAvatar {
  final int id;
  final String name;
  final String filename;
  const WhatekaAvatar(this.id, this.name, this.filename);

  static const all = [
    WhatekaAvatar(1, 'Sam', '01_sam.svg'),
    WhatekaAvatar(2, 'Max', '02_max.svg'),
    WhatekaAvatar(3, 'Lina', '03_lina.svg'),
    WhatekaAvatar(4, 'Amadou', '04_amadou.svg'),
    WhatekaAvatar(5, 'Théo', '05_theo.svg'),
    WhatekaAvatar(6, 'Chloé', '06_chloe.svg'),
    WhatekaAvatar(7, 'Lucas', '07_lucas.svg'),
    WhatekaAvatar(8, 'Yuki', '08_yuki.svg'),
    WhatekaAvatar(9, 'Emma', '09_emma.svg'),
    WhatekaAvatar(10, 'Nathan', '10_nathan.svg'),
  ];

  static WhatekaAvatar byId(int id) =>
      all.firstWhere((a) => a.id == id, orElse: () => all.first);
}
