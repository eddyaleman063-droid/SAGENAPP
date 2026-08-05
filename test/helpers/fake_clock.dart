class FakeClock {
  FakeClock(this.fixedTime);

  final DateTime fixedTime;

  DateTime now() => fixedTime;
}
