import 'dart:math';
import 'package:flutter/material.dart';

// ====== Edit here only ======
const guestName = 'lagloga';
const question = 'Wanna hang out?';
const day = 'Friday';
const time = '6:00 PM';
const place = 'El Zamalek';
const backgroundImage = 'assets/img_2.png';
// ==========================

const ink = Color(0xFF1B1030);
const apricot = Color(0xFFFFB48A);
const lilac = Color(0xFFC9B8FF);
const mint = Color(0xFF9FF0D0);

const noTexts = [
  'No',
  'Are you sure?',
  'Think again',
  'Really?',
  'Easy now',
  "You can't catch me 😄",
  'Just say yes',
];

void main() => runApp(const InviteApp());

class InviteApp extends StatelessWidget {
  const InviteApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: ink),
    builder: (_, child) => Directionality(textDirection: TextDirection.ltr, child: child!),
    home: const InvitePage(),
  );
}

class InvitePage extends StatefulWidget {
  const InvitePage({super.key});

  @override
  State<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> with TickerProviderStateMixin {
  late final sky = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  late final confetti = AnimationController(vsync: this, duration: const Duration(seconds: 3));
  final rnd = Random();
  Offset noPos = const Offset(0, 130);
  int dodges = 0;
  bool accepted = false;

  @override
  void dispose() {
    sky.dispose();
    confetti.dispose();
    super.dispose();
  }

  void dodge(double areaWidth) {
    setState(() {
      dodges++;
      noPos = Offset(
        rnd.nextDouble() * (areaWidth - 120).clamp(0, 400),
        110 + rnd.nextDouble() * 50,
      );
    });
  }

  void accept() {
    setState(() => accepted = true);
    confetti.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            backgroundImage,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          ColoredBox(color: ink.withOpacity(0.6)),
          CustomPaint(painter: SkyPainter(sky)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: accepted ? _ticket() : _ask(),
                  ),
                ),
              ),
            ),
          ),
          if (accepted) IgnorePointer(child: CustomPaint(painter: ConfettiPainter(confetti))),
        ],
      ),
    );
  }

  Widget _card({required Widget child, Key? key}) => Container(
    key: key,
    padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.07),
      borderRadius: BorderRadius.circular(36),
      border: Border.all(color: lilac.withOpacity(0.3)),
    ),
    child: child,
  );

  Widget _ask() {
    return _card(
      key: const ValueKey('ask'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('$guestName,', style: TextStyle(color: lilac, fontSize: 18)),
          const SizedBox(height: 12),
          const Text(
            question,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, height: 1.25),
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (_, box) => SizedBox(
              height: 220,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: AnimatedScale(
                      scale: 1 + min(dodges * 0.12, 0.5),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: FilledButton(
                        onPressed: accept,
                        style: FilledButton.styleFrom(
                          backgroundColor: apricot,
                          foregroundColor: ink,
                          minimumSize: const Size(180, 60),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        child: const Text('Sure'),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    left: noPos.dx,
                    top: noPos.dy,
                    child: MouseRegion(
                      onEnter: (_) => dodge(box.maxWidth),
                      child: Listener(
                        onPointerDown: (_) => dodge(box.maxWidth),
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: lilac,
                            side: const BorderSide(color: lilac),
                            shape: const StadiumBorder(),
                            minimumSize: const Size(100, 46),
                          ),
                          child: Text(noTexts[dodges % noTexts.length]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticket() {
    Widget row(IconData icon, String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: mint),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(color: lilac, fontSize: 16)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );

    return _card(
      key: const ValueKey('ticket'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("It's a date 🎉", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text("Here's the plan", style: TextStyle(color: lilac, fontSize: 16)),
          const SizedBox(height: 20),
          Divider(color: lilac.withOpacity(0.3)),
          row(Icons.event_rounded, 'Day', day),
          row(Icons.schedule_rounded, 'Time', time),
          row(Icons.place_rounded, 'Place', place),
        ],
      ),
    );
  }
}

class SkyPainter extends CustomPainter {
  SkyPainter(this.t) : super(repaint: t);
  final Animation<double> t;
  static final stars = List.generate(
    70,
        (i) {
      final r = Random(i);
      return [r.nextDouble(), r.nextDouble(), 0.8 + r.nextDouble() * 1.8, r.nextDouble() * 6.28, 1.0 + r.nextInt(3)];
    },
  );

  @override
  void paint(Canvas canvas, Size size) {
    final moon = Offset(size.width * 0.82, size.height * 0.14);
    canvas.drawCircle(
      moon,
      size.shortestSide * 0.45,
      Paint()
        ..shader = RadialGradient(colors: [apricot.withOpacity(0.35), Colors.transparent])
            .createShader(Rect.fromCircle(center: moon, radius: size.shortestSide * 0.45)),
    );
    canvas.drawCircle(moon, 26, Paint()..color = apricot);

    for (final s in stars) {
      final glow = (sin(t.value * 6.28 * s[4] + s[3]) + 1) / 2;
      canvas.drawCircle(
        Offset(s[0] * size.width, s[1] * size.height),
        s[2],
        Paint()..color = Colors.white.withOpacity(0.2 + 0.7 * glow),
      );
    }
  }

  @override
  bool shouldRepaint(SkyPainter old) => false;
}

class ConfettiPainter extends CustomPainter {
  ConfettiPainter(this.t) : super(repaint: t);
  final Animation<double> t;
  static const colors = [apricot, lilac, mint, Colors.white];
  static final bits = List.generate(80, (i) {
    final r = Random(i + 100);
    final angle = -pi / 2 + (r.nextDouble() - 0.5) * pi * 1.2;
    return [angle, 0.4 + r.nextDouble() * 0.9, r.nextDouble() * 6.28, i % 4];
  });

  @override
  void paint(Canvas canvas, Size size) {
    final v = Curves.easeOut.transform(t.value);
    final fade = (1 - t.value).clamp(0.0, 1.0);
    for (final b in bits) {
      final dist = b[1] * size.height * 0.7 * v;
      final pos = Offset(
        size.width / 2 + cos(b[0]) * dist,
        size.height * 0.65 + sin(b[0]) * dist + 350 * t.value * t.value,
      );
      canvas
        ..save()
        ..translate(pos.dx, pos.dy)
        ..rotate(b[2] + t.value * 8)
        ..drawRect(
          const Rect.fromLTWH(-5, -3, 10, 6),
          Paint()..color = colors[b[3] as int].withOpacity(fade),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter old) => false;
}