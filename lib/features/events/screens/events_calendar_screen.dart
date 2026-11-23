import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../app/routes.dart';
import '../../../models/app_event.dart';
import '../../../widgets/state_views.dart';
import '../controllers/events_controller.dart';
import '../widgets/event_card.dart';
import '../widgets/events_header.dart';
import '../widgets/events_theme.dart';

/// S20 Events Calendar (Tab 5, core feature).
///
/// Follows the Figma "Events" frame (orange header, search, Ongoing and
/// Upcoming lists) and adds what the spec requires: category filters and a
/// month calendar view (toggle in the header).
///
/// Data comes from [eventsFeedProvider]: hardcoded yearly Iloilo events +
/// approved Supabase events, with an offline cache. Pull down to refresh.
class EventsCalendarScreen extends ConsumerStatefulWidget {
  const EventsCalendarScreen({super.key});

  @override
  ConsumerState<EventsCalendarScreen> createState() => _EventsCalendarScreenState();
}

class _EventsCalendarScreenState extends ConsumerState<EventsCalendarScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  EventCategory? _category; // null = all categories
  bool _showCalendar = false;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _category = null;
    });
  }

  void _openEvent(AppEvent event) => context.push(AppRoutes.event(event.id));

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(eventsFeedProvider);

    return EventsTheme(
      child: Scaffold(
        body: Column(
          children: [
            EventsHeader(
              title: 'Events',
              trailing: IconButton(
                tooltip: _showCalendar ? 'Show list' : 'Show calendar',
                color: Colors.white,
                iconSize: 28,
                onPressed: () => setState(() => _showCalendar = !_showCalendar),
                icon: Icon(_showCalendar ? Icons.view_list : Icons.calendar_month),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.refresh(eventsFeedProvider.future),
                child: switch (feed) {
                  AsyncData(:final value) => _buildContent(value),
                  AsyncError(:final error) => _scrollable(
                      ErrorView(
                        message: 'Could not load events.\n$error',
                        onRetry: () => ref.invalidate(eventsFeedProvider),
                      ),
                    ),
                  _ => const LoadingView(message: 'Loading events...'),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Lets pull-to-refresh work on the error state too.
  Widget _scrollable(Widget child) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [SizedBox(height: 400, child: child)],
      );

  Widget _buildContent(EventsFeed feed) {
    final now = DateTime.now();
    final filtered = filterEvents(feed.events, query: _query, category: _category);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), // room for the FAB
      children: [
        _SearchField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 12),
        _CategoryChips(
          selected: _category,
          onSelected: (c) => setState(() => _category = c),
        ),
        if (feed.offlineNotice != null) _OfflineNotice(feed.offlineNotice!),
        const SizedBox(height: 8),
        if (_showCalendar)
          ..._buildCalendar(filtered)
        else
          ..._buildLists(filtered, now),
      ],
    );
  }

  /// Ongoing + Upcoming sections (Figma layout).
  List<Widget> _buildLists(List<AppEvent> events, DateTime now) {
    final ongoing = events.where((e) => e.isOngoing(now)).toList();
    // One year ahead is enough and avoids listing next year's copy twice.
    final horizon = now.add(const Duration(days: 365));
    final upcoming = events.where((e) => e.isUpcoming(now) && e.startsAt.isBefore(horizon)).toList();

    if (ongoing.isEmpty && upcoming.isEmpty) {
      return [
        const SizedBox(height: 40),
        EmptyView(
          message: 'No events match your search.',
          icon: Icons.event_busy,
          action: TextButton(onPressed: _clearFilters, child: const Text('Clear filters')),
        ),
      ];
    }
    return [
      if (ongoing.isNotEmpty) ...[
        const _SectionTitle('Ongoing Events', color: EventsColors.crimson),
        for (final e in ongoing) EventCard(event: e, onTap: () => _openEvent(e)),
      ],
      const _SectionTitle('Upcoming Events'),
      if (upcoming.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('No upcoming events match your filters.'),
        ),
      for (final e in upcoming) EventCard(event: e, onTap: () => _openEvent(e)),
    ];
  }

  /// Month view + the events on the selected day.
  List<Widget> _buildCalendar(List<AppEvent> events) {
    final now = DateTime.now();
    final onSelectedDay = events.where((e) => e.occursOn(_selectedDay)).toList();

    return [
      Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: EventsColors.border),
        ),
        child: TableCalendar<AppEvent>(
          firstDay: DateTime(now.year, now.month, 1),
          lastDay: DateTime(now.year + 1, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
          eventLoader: (day) => events.where((e) => e.occursOn(day)).toList(),
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          headerStyle: const HeaderStyle(titleCentered: true),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: EventsColors.orange.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(color: EventsColors.orange, shape: BoxShape.circle),
            markerDecoration: const BoxDecoration(color: EventsColors.crimson, shape: BoxShape.circle),
            markersMaxCount: 3,
          ),
          onDaySelected: (selected, focused) => setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          }),
          onPageChanged: (focused) => _focusedDay = focused,
        ),
      ),
      _SectionTitle('Events on ${_selectedDay.month}/${_selectedDay.day}/${_selectedDay.year}'),
      if (onSelectedDay.isEmpty)
        const EmptyView(message: 'No events on this day.', icon: Icons.event_available)
      else
        for (final e in onSelectedDay) EventCard(event: e, onTap: () => _openEvent(e)),
    ];
  }
}

/// Rounded search field from the Figma frame.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final pill = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: EventsColors.border),
    );
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search, color: EventsColors.cardTitle),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: pill,
        enabledBorder: pill,
        focusedBorder: pill.copyWith(borderSide: const BorderSide(color: EventsColors.orange)),
      ),
    );
  }
}

/// Horizontal row of category filter chips ("All" + each category).
class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  final EventCategory? selected;
  final ValueChanged<EventCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          for (final c in EventCategory.values.where((c) => c != EventCategory.other))
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                avatar: Icon(c.icon, size: 16),
                label: Text(c.label),
                selected: selected == c,
                onSelected: (isOn) => onSelected(isOn ? c : null),
              ),
            ),
        ],
      ),
    );
  }
}

/// "Ongoing Events" / "Upcoming Events" headings.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
      ),
    );
  }
}

/// Shown when the list comes from the offline cache.
class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 16),
          const SizedBox(width: 6),
          Expanded(child: Text(message, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
