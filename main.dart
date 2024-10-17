import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const HijriCalendarApp());
}

class HijriCalendarApp extends StatelessWidget {
  const HijriCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hijri Calendar',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HijriCalendarPage(),
    );
  }
}

class HijriCalendarPage extends StatefulWidget {
  const HijriCalendarPage({super.key});

  @override
  _HijriCalendarPageState createState() => _HijriCalendarPageState();
}

class _HijriCalendarPageState extends State<HijriCalendarPage>
    with TickerProviderStateMixin {
  final HijriCalendar _hijriCalendar = HijriCalendar.now();
  final HijriCalendar _todayHijri = HijriCalendar.now();

  final List<Color> _colorScheme = [
    const Color(0xFF6A1B9A),
    const Color(0xFFBA68C8),
    const Color(0xFFFF7043),
    const Color(0xFF29B6F6),
    const Color(0xFF66BB6A),
    const Color(0xFFFFD54F),
    const Color(0xFFD32F2F),
  ];
  late Color _primaryColor;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _primaryColor = _colorScheme[(_hijriCalendar.hMonth - 1) % _colorScheme.length];

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1, end: 1.05).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextMonth() {
    setState(() {
      _hijriCalendar.hMonth += 1;
      if (_hijriCalendar.hMonth > 12) {
        _hijriCalendar.hMonth = 1;
        _hijriCalendar.hYear += 1;
      }
      _primaryColor = _colorScheme[(_hijriCalendar.hMonth - 1) % _colorScheme.length];
    });
  }

  void _previousMonth() {
    setState(() {
      _hijriCalendar.hMonth -= 1;
      if (_hijriCalendar.hMonth < 1) {
        _hijriCalendar.hMonth = 12;
        _hijriCalendar.hYear -= 1;
      }
      _primaryColor = _colorScheme[(_hijriCalendar.hMonth - 1) % _colorScheme.length];
    });
  }

  void _handleSwipe(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dx > 0) {
      _previousMonth();
    } else if (details.velocity.pixelsPerSecond.dx < 0) {
      _nextMonth();
    }
  }

  List<Widget> _buildDaysGrid() {
    int daysInMonth = _hijriCalendar.getDaysInMonth(_hijriCalendar.hYear, _hijriCalendar.hMonth);
    List<Widget> days = [];

    for (int day = 1; day <= daysInMonth; day++) {
      bool isToday = (_hijriCalendar.hMonth == _todayHijri.hMonth &&
          _hijriCalendar.hYear == _todayHijri.hYear &&
          day == _todayHijri.hDay);

      days.add(
        GestureDetector(
          onTap: () {},
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Card(
              elevation: isToday ? 12.0 : 8.0,
              margin: const EdgeInsets.all(6.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: isToday
                    ? const BorderSide(color: Colors.orangeAccent, width: 2)
                    : BorderSide.none,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                decoration: BoxDecoration(
                  gradient: isToday
                      ? const LinearGradient(
                    colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : LinearGradient(
                    colors: [_primaryColor.withOpacity(0.4), _primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: isToday ? 10 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return days;
  }

  final List<String> _weekDays = ["Fri", "Sat", "Sun", "Mon", "Tue", "Wed", "Thu"];

  Widget _buildWeekDaysRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _weekDays.map((day) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            day,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentGregorianDate = DateFormat.yMMMMd().format(DateTime.now());
    String currentDayOfWeek = DateFormat.EEEE().format(DateTime.now());

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: ClipPath(
          clipper: CustomAppBarClipper(),
          child: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor, _primaryColor.withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 30.0,
                ),
                const SizedBox(width: 10),
                Text(
                  'Hijri Calendar',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            elevation: 8.0,
          ),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: _handleSwipe,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Container(
            key: ValueKey<int>(_hijriCalendar.hMonth),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFe0f7fa), Color(0xFF80deea)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      Text(
                        '${_hijriCalendar.getLongMonthName()} ${_hijriCalendar.hYear}',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.09,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 10.0,
                        margin: const EdgeInsets.all(6.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: _primaryColor,
                                size: 30.0,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Gregorian Date: $currentGregorianDate',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.045,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 10.0,
                        margin: const EdgeInsets.all(6.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.today,
                                color: _primaryColor,
                                size: 30.0,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  ' $currentDayOfWeek',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _buildWeekDaysRow(),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 7,
                    children: _buildDaysGrid(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 30);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(3 * size.width / 4, size.height - 60);
    var secondEndPoint = Offset(size.width, size.height - 30);

    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
