import '../l10n/app_localizations.dart';

enum UpdateType { feature, improvement, fix }

/// A single changelog entry with date, description, and type.
class UpdateEntry {
  final DateTime date;
  final String title;
  final String description;
  final UpdateType type;
  final String version;
  final bool isNew;

  const UpdateEntry({
    required this.date,
    required this.title,
    required this.description,
    this.type = UpdateType.improvement,
    required this.version,
    this.isNew = false,
  });

  static List<UpdateEntry> all() => _entries;

  static List<UpdateEntry> newEntries() =>
      _entries.where((e) => e.isNew).toList();

  static List<UpdateEntry> allLocalized(AppLocalizations l) =>
      _localizedEntries(l);
}

final _entries = <UpdateEntry>[
  UpdateEntry(
    date: _june(13),
    title: 'Energy System',
    description:
        'Each lesson now costs energy. Answer correctly to spend only 1,'
        ' failing costs 2. Combo streaks regenerate energy.'
        ' When you reach 0, you cannot continue the lesson.',
    type: UpdateType.feature,
    version: '1.5.0',
    isNew: true,
  ),
  UpdateEntry(
    date: _june(13),
    title: 'Infinite Energy',
    description:
        'New special item in the store that grants unlimited energy'
        ' for a limited time. Activate it from your inventory.',
    type: UpdateType.feature,
    version: '1.5.0',
    isNew: true,
  ),
  UpdateEntry(
    date: _june(13),
    title: 'Improved item icons',
    description:
        'All special items now have customized'
        ' and more eye-catching icons in the store and inventory.',
    version: '1.5.0',
    isNew: true,
  ),
  UpdateEntry(
    date: _june(12),
    title: 'Typed routes with GoRouter Builder',
    description:
        'Splash and welcome routes are now typed,'
        ' catching errors at compile time.',
    version: '1.4.1',
    isNew: true,
  ),
  UpdateEntry(
    date: _june(10),
    title: 'Programmatic mascot',
    description:
        'The mascot is now drawn with CustomPainter.'
        ' 29 emotions, no assets, smooth transitions between emotions.',
    type: UpdateType.feature,
    version: '1.4.0',
  ),
  UpdateEntry(
    date: _june(8),
    title: 'Updates and news',
    description:
        'New screen in the bottom bar that shows'
        ' the changelog and app news.',
    type: UpdateType.feature,
    version: '1.4.0',
  ),
  UpdateEntry(
    date: _june(5),
    title: 'Mercado Pago integrated',
    description:
        'Direct payments with Mercado Pago for gem packages and bundles.'
        ' WhatsApp payment also available.',
    type: UpdateType.feature,
    version: '1.3.0',
  ),
  UpdateEntry(
    date: _may(30),
    title: 'Improved streak protector',
    description:
        'Maximum limit of 2 protectors. When reached,'
        ' booster offers are shown instead.',
    version: '1.2.1',
  ),
  UpdateEntry(
    date: _may(25),
    title: 'Lesson boosters',
    description:
        'New items: XP Boost (2x), Gem Multiplier (2x in chests),'
        ' Luck Boost (2x probabilities). Buy and activate from the store.',
    type: UpdateType.feature,
    version: '1.2.0',
  ),
  UpdateEntry(
    date: _may(15),
    title: 'Unit test fixes',
    description:
        'Fixed 7 failing tests. All tests now'
        ' pass correctly (419 tests). 0 analysis issues.',
    type: UpdateType.fix,
    version: '1.1.3',
  ),
  UpdateEntry(
    date: _april(20),
    title: 'Streak and lesson chests',
    description:
        'New chest system: daily streak chest,'
        ' lesson chest every 3/5/6/10 completed lessons.',
    type: UpdateType.feature,
    version: '1.1.0',
  ),
  UpdateEntry(
    date: _april(10),
    title: 'Daily missions',
    description: 'Daily mission system with gem and experience rewards.',
    type: UpdateType.feature,
    version: '1.0.2',
  ),
  UpdateEntry(
    date: _march(28),
    title: 'First version',
    description:
        'Initial launch with interactive lessons, daily streak,'
        ' gems, store and user profile.',
    type: UpdateType.feature,
    version: '1.0.0',
  ),
];

DateTime _march(int day) => DateTime(2026, 3, day);
DateTime _april(int day) => DateTime(2026, 4, day);
DateTime _may(int day) => DateTime(2026, 5, day);
DateTime _june(int day) => DateTime(2026, 6, day);

List<UpdateEntry> _localizedEntries(AppLocalizations l) => [
  UpdateEntry(
    date: _june(13),
    title: l.updateEnergySystem,
    description: l.updateEnergySystemDesc,
    type: UpdateType.feature,
    version: '1.5.0',
    isNew: true,
  ),
  UpdateEntry(
    date: _june(13),
    title: l.updateInfiniteEnergy,
    description: l.updateInfiniteEnergyDesc,
    type: UpdateType.feature,
    version: '1.5.0',
    isNew: true,
  ),
  UpdateEntry(
    date: _june(13),
    title: l.updateImprovedIcons,
    description: l.updateImprovedIconsDesc,
    version: '1.5.0',
    isNew: true,
  ),
  UpdateEntry(
    date: _june(12),
    title: l.updateTypedRoutes,
    description: l.updateTypedRoutesDesc,
    version: '1.4.1',
    isNew: true,
  ),
  UpdateEntry(
    date: _june(10),
    title: l.updateProgrammaticMascot,
    description: l.updateProgrammaticMascotDesc,
    type: UpdateType.feature,
    version: '1.4.0',
  ),
  UpdateEntry(
    date: _june(8),
    title: l.updateChangelog,
    description: l.updateChangelogDesc,
    type: UpdateType.feature,
    version: '1.4.0',
  ),
  UpdateEntry(
    date: _june(5),
    title: l.updateMercadoPago,
    description: l.updateMercadoPagoDesc,
    type: UpdateType.feature,
    version: '1.3.0',
  ),
  UpdateEntry(
    date: _may(30),
    title: l.updateStreakProtectorImproved,
    description: l.updateStreakProtectorImprovedDesc,
    version: '1.2.1',
  ),
  UpdateEntry(
    date: _may(25),
    title: l.updateLessonBoosters,
    description: l.updateLessonBoostersDesc,
    type: UpdateType.feature,
    version: '1.2.0',
  ),
  UpdateEntry(
    date: _may(15),
    title: l.updateTestFix,
    description: l.updateTestFixDesc,
    type: UpdateType.fix,
    version: '1.1.3',
  ),
  UpdateEntry(
    date: _april(20),
    title: l.updateChestSystem,
    description: l.updateChestSystemDesc,
    type: UpdateType.feature,
    version: '1.1.0',
  ),
  UpdateEntry(
    date: _april(10),
    title: l.updateDailyMissions,
    description: l.updateDailyMissionsDesc,
    type: UpdateType.feature,
    version: '1.0.2',
  ),
  UpdateEntry(
    date: _march(28),
    title: l.updateFirstVersion,
    description: l.updateFirstVersionDesc,
    type: UpdateType.feature,
    version: '1.0.0',
  ),
];
