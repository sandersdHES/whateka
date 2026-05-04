import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart';

/// Palette de couleurs par avatar pour dessiner les membres animes
/// (bras et jambes) dans le meme style que le corps SVG statique.
class _Palette {
  final Color sleeve; // couleur du bras (manche ou peau si bras nus)
  final Color pants; // couleur de la jambe
  final Color shoe; // couleur du pied/chaussure
  final Color skin; // couleur de la main
  const _Palette({
    required this.sleeve,
    required this.pants,
    required this.shoe,
    required this.skin,
  });
}

/// Affiche le personnage choisi qui se promene en boucle dans une bande
/// horizontale, avec animation realiste des bras et jambes (inspiree GTA).
///
/// Implementation paper-doll : le fichier SVG `XX_name_body.svg` ne contient
/// que le torse, la tete et les accessoires (bras et jambes retires). Les
/// bras et jambes sont redessines en Flutter par-dessus/dessous avec une
/// rotation sinusoidale pour simuler la demarche.
class AvatarPromenade extends StatefulWidget {
  final int avatarId;
  final double height;
  final double speed; // pixels par seconde
  /// Total de metres deja marches cumule (charge depuis user_metadata).
  /// Le widget continue a compter a partir de cette valeur.
  final double initialMeters;
  final ValueChanged<double>? onMetersWalked;

  const AvatarPromenade({
    super.key,
    required this.avatarId,
    this.height = 200,
    this.speed = 40,
    this.initialMeters = 0,
    this.onMetersWalked,
  });

  @override
  State<AvatarPromenade> createState() => _AvatarPromenadeState();
}

enum _PromenadeState { walking, turningRight, turningLeft }

class _AvatarPromenadeState extends State<AvatarPromenade>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  // Taille intrinseque du personnage composite (meme que SVG source).
  static const double _svgWidth = 110;
  static const double _svgHeight = 220;
  // Taille d'affichage finale (scale = 80/110 = 0.727).
  static const double _displayWidth = 80;
  static const double _displayHeight = 160;
  static const double _scale = _displayWidth / _svgWidth;

  // Palettes par avatar (15 personnages thematiques style alpin Suisse,
  // refonte complete v2026-05). Couleurs alignees EXACTEMENT sur les SVG :
  //   - sleeve : couleur du haut/manche (le bras anime utilise cette couleur)
  //   - pants  : couleur des jambes animees (skin pour shorts, pant color sinon)
  //   - shoe   : couleur des chaussures animees
  //   - skin   : couleur des mains animees (= peau visible du visage SVG)
  static const Map<int, _Palette> _palettes = {
    1: _Palette( // Lina - randonneuse (bermuda kaki, polo vert, sac cyan)
      sleeve: Color(0xFF5A7F6F),
      pants: Color(0xFFE8D4B8), // shorts -> jambes nues
      shoe: Color(0xFF5C4A3A),
      skin: Color(0xFFE8D4B8),
    ),
    2: _Palette( // Tom - cycliste (maillot jaune, cuissard, casque)
      sleeve: Color(0xFFD4BC34),
      pants: Color(0xFFE8D4B8), // cuissard -> jambes nues sous le short
      shoe: Color(0xFFF5F5F5),
      skin: Color(0xFFE8D4B8),
    ),
    3: _Palette( // Aicha - paysagiste (chapeau paille, peau foncee)
      sleeve: Color(0xFF6B8F7F),
      pants: Color(0xFFD4C4AE),
      shoe: Color(0xFFC4A57A),
      skin: Color(0xFF7D5840),
    ),
    4: _Palette( // Marc - architecte (cardigan, lunettes, sac fourre-tout)
      sleeve: Color(0xFF556B7F),
      pants: Color(0xFF2C3E50),
      shoe: Color(0xFF5C4A3A),
      skin: Color(0xFFE8D4B8),
    ),
    5: _Palette( // Anais - photographe (veste kaki, appareil photo)
      sleeve: Color(0xFF556B7F),
      pants: Color(0xFF1A1A20),
      shoe: Color(0xFF2A2A2A),
      skin: Color(0xFFE8D4B8),
    ),
    6: _Palette( // Igor - musicien (manteau gris, etui guitare)
      sleeve: Color(0xFF8B8680),
      pants: Color(0xFF2C3E50),
      shoe: Color(0xFF2A2A2A),
      skin: Color(0xFFE8D4B8),
    ),
    7: _Palette( // Pauline - sommeliere (gilet bordeaux, foulard)
      sleeve: Color(0xFF6B5A7F),
      pants: Color(0xFF1A1A1A),
      shoe: Color(0xFF2A2A2A),
      skin: Color(0xFFE8D4B8),
    ),
    8: _Palette( // Matteo - patissier (toque blanche, tablier)
      sleeve: Color(0xFFD4C4AE),
      pants: Color(0xFF2C2C2C),
      shoe: Color(0xFFF5F5F5),
      skin: Color(0xFFE8D4B8),
    ),
    9: _Palette( // Lucas - skieur (combi marine, lunettes ski)
      sleeve: Color(0xFF1F3A4A),
      pants: Color(0xFF1F3A4A),
      shoe: Color(0xFF1A1A1A),
      skin: Color(0xFFE8D4B8),
    ),
    10: _Palette( // Emma - traileuse (tank corail, short, sac d'eau)
      sleeve: Color(0xFFE8D4B8), // bras nus
      pants: Color(0xFFE8D4B8), // short -> jambes nues
      shoe: Color(0xFFE6F029),
      skin: Color(0xFFE8D4B8),
    ),
    11: _Palette( // Yuki - kayakiste (gilet jaune fluo, pagaie)
      sleeve: Color(0xFF1A1A1A), // rashguard noir
      pants: Color(0xFFF0DCC4), // short -> jambes nues
      shoe: Color(0xFF6B7A8B),
      skin: Color(0xFFF0DCC4),
    ),
    12: _Palette( // Maya - thermes (peignoir blanc, turban corail)
      sleeve: Color(0xFFF8F4ED),
      pants: Color(0xFFF8F4ED), // peignoir long
      shoe: Color(0xFFC4A57A),
      skin: Color(0xFFE8B88B),
    ),
    13: _Palette( // Hugo - lecteur (cardigan beige, lunettes, livre)
      sleeve: Color(0xFFA89274),
      pants: Color(0xFF6B5A6B),
      shoe: Color(0xFF5C4A3A),
      skin: Color(0xFFE8D4B8),
    ),
    14: _Palette( // Nathan - grimpeur (harnais orange, corde)
      sleeve: Color(0xFFD4A878), // bras nus peau bronzee
      pants: Color(0xFFD4A878), // short -> jambes nues
      shoe: Color(0xFFD83034),
      skin: Color(0xFFD4A878),
    ),
    15: _Palette( // Sophia - maman (echarpe portage, sac a langer)
      sleeve: Color(0xFFC4B5DD),
      pants: Color(0xFFBFBAB0),
      shoe: Color(0xFFF5F5F5),
      skin: Color(0xFFE8D4B8),
    ),
  };

  double _bandWidth = 360;

  double _x = 20;
  int _direction = 1;
  _PromenadeState _state = _PromenadeState.walking;
  int _turnStartMs = 0;
  int _lastTickMs = 0;
  double _walkTime = 0;
  double _metersWalked = 0;
  double _lastReportedMeters = -1;

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

    if (_state == _PromenadeState.walking) {
      final deltaPx = _direction * widget.speed * dt;
      _x += deltaPx;
      _walkTime += dt;
      _metersWalked += deltaPx.abs() / 40.0;
      final intMeters = _metersWalked.floorToDouble();
      if (intMeters != _lastReportedMeters) {
        _lastReportedMeters = intMeters;
        widget.onMetersWalked?.call(_metersWalked);
      }
      if (_x >= _bandWidth - _displayWidth - 10) {
        _x = _bandWidth - _displayWidth - 10;
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

  /// Phase de marche : sinusoide en ±1, 0.8 Hz (cycle de ~1.25 s par pas).
  double get _walkPhase {
    if (_state != _PromenadeState.walking) return 0;
    return math.sin(_walkTime * 5);
  }

  double _bob() {
    if (_state != _PromenadeState.walking) return 0;
    // Bob vertical : 2x la frequence de la marche (chaque appui de pied).
    return math.sin(_walkTime * 10).abs() * -3;
  }

  double _recoilX() {
    if (_state != _PromenadeState.turningRight) return 0;
    final dur = _lastTickMs - _turnStartMs;
    if (dur < 200) {
      final t = dur / 200;
      return -8 * _easeOut(t);
    }
    return -8;
  }

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

  double _scaleY() {
    if (_state != _PromenadeState.turningLeft) return 1.0;
    final dur = _lastTickMs - _turnStartMs;
    if (dur < 200) return 1.0 + 0.08 * (dur / 200);
    if (dur < 350) return 1.08 - 0.08 * ((dur - 200) / 150);
    return 1.0;
  }

  bool _showBubble() {
    if (_state != _PromenadeState.turningRight) return false;
    final dur = _lastTickMs - _turnStartMs;
    return dur >= 200 && dur < 500;
  }

  double _easeOut(double t) => 1 - (1 - t) * (1 - t);

  @override
  Widget build(BuildContext context) {
    final palette = _palettes[widget.avatarId] ?? _palettes[1]!;
    final bodyAsset = _bodyAsset(widget.avatarId);
    final phase = _walkPhase;
    // Amplitude des rotations de membres (en radians). ~28° max.
    final armSwing = phase * 0.5;
    final legSwing = phase * 0.4;
    // v2 : flexion realiste du genou et du coude.
    // Le genou plie quand la jambe est en phase de "swing" (foot off ground),
    // c'est-a-dire quand l'angle de hanche est en train d'augmenter (cos > 0).
    // Pour la jambe gauche : angle = +legSwing, derivee = +cos(t) → bend si cos > 0.
    // Pour la jambe droite : angle = -legSwing, derivee = -cos(t) → bend si cos < 0.
    // Idem pour les coudes (les bras swing en phase opposee aux jambes).
    final cosPhase = _state == _PromenadeState.walking
        ? math.cos(_walkTime * 5)
        : 0.0;
    final leftKneeBend = math.max(0.0, cosPhase) * 0.7;   // 0..40°
    final rightKneeBend = math.max(0.0, -cosPhase) * 0.7;
    // Coude : plus subtil que le genou (~25° max).
    // Bras droit (avant) : angle = +armSwing → bend si cos > 0.
    // Bras gauche (arriere) : angle = -armSwing → bend si cos < 0.
    final rightElbowBend = math.max(0.0, cosPhase) * 0.4;
    final leftElbowBend = math.max(0.0, -cosPhase) * 0.4;

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
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
                    child: SizedBox(
                      width: _displayWidth,
                      height: _displayHeight,
                      child: Transform.scale(
                        scale: _scale,
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          width: _svgWidth,
                          height: _svgHeight,
                          // On construit en coordonnees SVG natives (110x220)
                          // puis on scale l'ensemble pour l'affichage.
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Ombre au sol (reste statique dans le SVG)
                              // Jambe arriere (dessinee avant pour etre derriere
                              // les jambes avant, la distinction gauche/droite
                              // depend de la phase de marche).
                              _Leg(
                                // v3 : nouveau design corps ovale.
                                // Hanche descendue de y=118 a y=124 pour
                                // matcher le bas de l'ovale (le corps SVG
                                // s'etend jusqu'a y=124). Hanches a x=47/63.
                                hipX: 47,
                                hipY: 124,
                                hipAngle: legSwing,
                                kneeBend: leftKneeBend,
                                pants: palette.pants,
                                shoe: palette.shoe,
                              ),
                              _Leg(
                                hipX: 63,
                                hipY: 124,
                                hipAngle: -legSwing,
                                kneeBend: rightKneeBend,
                                pants: palette.pants,
                                shoe: palette.shoe,
                              ),
                              // Bras arriere (derriere le torse).
                              // v3 : epaule descendue de y=58 a y=62 et
                              // entierement DANS l'ovale du corps (qui va
                              // de x=22 a x=88, l'epaule a x=28 est a
                              // l'interieur).
                              _Arm(
                                shoulderX: 28,
                                shoulderY: 62,
                                shoulderAngle: -armSwing,
                                elbowBend: leftElbowBend,
                                sleeve: palette.sleeve,
                                skin: palette.skin,
                              ),
                              // Corps stripped : torse + tete + accessoires.
                              SvgPicture.asset(
                                bodyAsset,
                                width: _svgWidth,
                                height: _svgHeight,
                              ),
                              // Bras avant (devant le torse).
                              _Arm(
                                shoulderX: 82,
                                shoulderY: 62,
                                shoulderAngle: armSwing,
                                elbowBend: rightElbowBend,
                                sleeve: palette.sleeve,
                                skin: palette.skin,
                              ),
                              if (_showBubble())
                                const Positioned(
                                  top: -8,
                                  right: 8,
                                  child: _ThinkBubble(),
                                ),
                            ],
                          ),
                        ),
                      ),
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

  static String _bodyAsset(int id) {
    final name = WhatekaAvatar.byId(id).filename.replaceAll('.svg', '_body.svg');
    return 'assets/avatars/$name';
  }
}

/// Jambe animee a 2 segments avec genou flexible.
/// - Cuisse : pivote autour de la hanche selon [hipAngle]
/// - Tibia : pivote autour du genou (bas de cuisse) selon [kneeBend]
/// - Pied : ellipse au bas du tibia
///
/// Le genou plie naturellement quand la jambe est en phase de "swing"
/// (foot off ground) — donne une demarche realiste plutot que stiff.
class _Leg extends StatelessWidget {
  final double hipX;
  final double hipY;
  final double hipAngle; // radians, ± ~25°
  final double kneeBend; // radians, 0 a ~40° (toujours positif, plie en arriere)
  final Color pants;
  final Color shoe;

  const _Leg({
    required this.hipX,
    required this.hipY,
    required this.hipAngle,
    required this.kneeBend,
    required this.pants,
    required this.shoe,
  });

  @override
  Widget build(BuildContext context) {
    // v3 : jambes calees pour le nouveau design ovale.
    // Largeur 14 (suffisant + match avec le bas de l'ovale qui se ferme).
    // Hauteur ajustee pour atteindre y=205 depuis hipY=124 (=> 81 px).
    const thighWidth = 14.0;
    const thighHeight = 35.0;
    const shinWidth = 13.0;
    const shinHeight = 38.0;
    const shoeHeight = 10.0;
    const totalHeight = thighHeight + shinHeight + shoeHeight - 4;

    return Positioned(
      left: hipX - thighWidth / 2,
      top: hipY,
      child: Transform.rotate(
        angle: hipAngle,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: thighWidth,
          height: totalHeight + 4,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Cuisse (haut)
              Container(
                width: thighWidth,
                height: thighHeight,
                decoration: BoxDecoration(
                  color: pants,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                    bottom: Radius.circular(2),
                  ),
                ),
              ),
              // Tibia + pied : pivote autour du genou (bas de cuisse).
              Positioned(
                top: thighHeight - 1,
                child: Transform.rotate(
                  angle: kneeBend,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: shinWidth,
                    height: shinHeight + shoeHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          width: shinWidth,
                          height: shinHeight,
                          decoration: BoxDecoration(
                            color: pants,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(2),
                              bottom: Radius.circular(3),
                            ),
                          ),
                        ),
                        Positioned(
                          top: shinHeight - 5,
                          child: Container(
                            width: shinWidth + 6,
                            height: shoeHeight,
                            decoration: BoxDecoration(
                              color: shoe,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bras anime a 2 segments avec coude flexible.
/// - Bras (haut) : pivote autour de l'epaule selon [shoulderAngle]
/// - Avant-bras : pivote autour du coude selon [elbowBend]
/// - Main : cercle au bout de l'avant-bras
///
/// Le coude plie subtilement quand le bras swing en avant — donne une
/// allure naturelle (pas de bras raides comme un soldat).
class _Arm extends StatelessWidget {
  final double shoulderX;
  final double shoulderY;
  final double shoulderAngle; // radians, ± ~28°
  final double elbowBend;     // radians, 0 a ~25°
  final Color sleeve;
  final Color skin;

  const _Arm({
    required this.shoulderX,
    required this.shoulderY,
    required this.shoulderAngle,
    required this.elbowBend,
    required this.sleeve,
    required this.skin,
  });

  @override
  Widget build(BuildContext context) {
    // v3 : bras emergent de l'INTERIEUR de l'ovale corps (ovale x=22-88).
    // Largeur 13, hauteur ajustee pour ne pas depasser le bas de l'ovale.
    // upperArm + forearm = 50 px max (epaule y=62 + 50 = y=112, dans l'ovale).
    const armWidth = 13.0;
    const upperArmHeight = 24.0;
    const forearmWidth = 12.0;
    const forearmHeight = 26.0;
    const handSize = 9.0;

    return Positioned(
      left: shoulderX - armWidth / 2,
      top: shoulderY,
      child: Transform.rotate(
        angle: shoulderAngle,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: armWidth,
          height: upperArmHeight + forearmHeight + handSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Bras (haut)
              Container(
                width: armWidth,
                height: upperArmHeight,
                decoration: BoxDecoration(
                  color: sleeve,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                    bottom: Radius.circular(3),
                  ),
                ),
              ),
              // Avant-bras + main : pivote autour du coude.
              Positioned(
                top: upperArmHeight - 1,
                child: Transform.rotate(
                  angle: elbowBend,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: forearmWidth,
                    height: forearmHeight + handSize,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          width: forearmWidth,
                          height: forearmHeight,
                          decoration: BoxDecoration(
                            color: sleeve,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Positioned(
                          top: forearmHeight - 3,
                          child: Container(
                            width: handSize,
                            height: handSize,
                            decoration: BoxDecoration(
                              color: skin,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    WhatekaAvatar(1, 'Lina', '01_lina.svg'),
    WhatekaAvatar(2, 'Tom', '02_tom.svg'),
    WhatekaAvatar(3, 'Aïcha', '03_aicha.svg'),
    WhatekaAvatar(4, 'Marc', '04_marc.svg'),
    WhatekaAvatar(5, 'Anaïs', '05_anais.svg'),
    WhatekaAvatar(6, 'Igor', '06_igor.svg'),
    WhatekaAvatar(7, 'Pauline', '07_pauline.svg'),
    WhatekaAvatar(8, 'Matteo', '08_matteo.svg'),
    WhatekaAvatar(9, 'Lucas', '09_lucas.svg'),
    WhatekaAvatar(10, 'Emma', '10_emma.svg'),
    WhatekaAvatar(11, 'Yuki', '11_yuki.svg'),
    WhatekaAvatar(12, 'Maya', '12_maya.svg'),
    WhatekaAvatar(13, 'Hugo', '13_hugo.svg'),
    WhatekaAvatar(14, 'Nathan', '14_nathan.svg'),
    WhatekaAvatar(15, 'Sophia', '15_sophia.svg'),
  ];

  static WhatekaAvatar byId(int id) =>
      all.firstWhere((a) => a.id == id, orElse: () => all.first);
}
