import '../../diaper/diaper_entry.dart';

enum HomeDashboardCard { todaySummary, quickDiaper, upcomingCare }

enum HomeQuickAction {
  feeding,
  milkInventory,
  diaper,
  growth,
  careCalendar,
  history,
}

class HomePreferences {
  HomePreferences({
    required Iterable<HomeDashboardCard> dashboardOrder,
    required Iterable<HomeDashboardCard> visibleDashboardCards,
    required Iterable<HomeQuickAction> quickActionOrder,
    required Iterable<HomeQuickAction> visibleQuickActions,
    required this.preferredQuickDiaperType,
  }) : dashboardOrder = List.unmodifiable(_completeOrder(dashboardOrder)),
       visibleDashboardCards = Set.unmodifiable(visibleDashboardCards),
       quickActionOrder = List.unmodifiable(
         _completeQuickOrder(quickActionOrder),
       ),
       visibleQuickActions = Set.unmodifiable(visibleQuickActions);

  factory HomePreferences.defaults() => HomePreferences(
    dashboardOrder: HomeDashboardCard.values,
    visibleDashboardCards: HomeDashboardCard.values,
    quickActionOrder: HomeQuickAction.values,
    visibleQuickActions: HomeQuickAction.values,
    preferredQuickDiaperType: DiaperType.pee,
  );

  final List<HomeDashboardCard> dashboardOrder;
  final Set<HomeDashboardCard> visibleDashboardCards;
  final List<HomeQuickAction> quickActionOrder;
  final Set<HomeQuickAction> visibleQuickActions;
  final DiaperType preferredQuickDiaperType;

  HomePreferences copyWith({
    Iterable<HomeDashboardCard>? dashboardOrder,
    Iterable<HomeDashboardCard>? visibleDashboardCards,
    Iterable<HomeQuickAction>? quickActionOrder,
    Iterable<HomeQuickAction>? visibleQuickActions,
    DiaperType? preferredQuickDiaperType,
  }) => HomePreferences(
    dashboardOrder: dashboardOrder ?? this.dashboardOrder,
    visibleDashboardCards: visibleDashboardCards ?? this.visibleDashboardCards,
    quickActionOrder: quickActionOrder ?? this.quickActionOrder,
    visibleQuickActions: visibleQuickActions ?? this.visibleQuickActions,
    preferredQuickDiaperType:
        preferredQuickDiaperType ?? this.preferredQuickDiaperType,
  );

  Map<String, dynamic> toJson() => {
    'schemaVersion': 1,
    'dashboardOrder': dashboardOrder.map((item) => item.name).toList(),
    'visibleDashboardCards': visibleDashboardCards
        .map((item) => item.name)
        .toList(),
    'quickActionOrder': quickActionOrder.map((item) => item.name).toList(),
    'visibleQuickActions': visibleQuickActions
        .map((item) => item.name)
        .toList(),
    'preferredQuickDiaperType': preferredQuickDiaperType.name,
  };

  factory HomePreferences.fromJson(Map<String, dynamic> json) {
    final defaults = HomePreferences.defaults();
    return HomePreferences(
      dashboardOrder: _readEnums(
        json['dashboardOrder'],
        HomeDashboardCard.values,
      ),
      visibleDashboardCards: _readVisibility(
        json['visibleDashboardCards'],
        HomeDashboardCard.values,
        defaults.visibleDashboardCards,
      ),
      quickActionOrder: _readEnums(
        json['quickActionOrder'],
        HomeQuickAction.values,
      ),
      visibleQuickActions: _readVisibility(
        json['visibleQuickActions'],
        HomeQuickAction.values,
        defaults.visibleQuickActions,
      ),
      preferredQuickDiaperType:
          _enumByName(DiaperType.values, json['preferredQuickDiaperType']) ??
          defaults.preferredQuickDiaperType,
    );
  }

  static List<HomeDashboardCard> _completeOrder(
    Iterable<HomeDashboardCard> source,
  ) => _complete(source, HomeDashboardCard.values);

  static List<HomeQuickAction> _completeQuickOrder(
    Iterable<HomeQuickAction> source,
  ) => _complete(source, HomeQuickAction.values);

  static List<T> _complete<T>(Iterable<T> source, List<T> defaults) {
    final result = <T>[];
    for (final item in [...source, ...defaults]) {
      if (!result.contains(item)) result.add(item);
    }
    return result;
  }

  static List<T> _readEnums<T extends Enum>(dynamic raw, List<T> values) {
    if (raw is! List) return List.of(values);
    final result = <T>[];
    for (final name in raw.whereType<String>()) {
      final value = _enumByName(values, name);
      if (value != null && !result.contains(value)) result.add(value);
    }
    return result;
  }

  static Iterable<T> _readVisibility<T extends Enum>(
    dynamic raw,
    List<T> values,
    Iterable<T> defaults,
  ) => raw is List ? _readEnums(raw, values) : defaults;

  static T? _enumByName<T extends Enum>(List<T> values, dynamic name) {
    if (name is! String) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
