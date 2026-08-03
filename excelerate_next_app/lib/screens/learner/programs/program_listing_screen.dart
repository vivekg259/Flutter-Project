/// Program listing screen — browsable, filterable, searchable list of all
/// programs from Firestore (real data). Replaces the old RTDB fallback version.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/program_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_bottom_nav.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_overlay.dart';
import '../../../widgets/program_card.dart';

class ProgramListingScreen extends StatefulWidget {
  const ProgramListingScreen({super.key});

  @override
  State<ProgramListingScreen> createState() => _ProgramListingScreenState();
}

class _ProgramListingScreenState extends State<ProgramListingScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final programs = context.watch<ProgramProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && context.mounted) {
          final navigator = Navigator.of(context, rootNavigator: true);
          if (navigator.canPop()) {
            navigator.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Image.asset('assets/logo.png', height: AppSizes.logoAppBar),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.xl,
                AppSizes.lg,
                AppSizes.xl,
                AppSizes.sm,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: programs.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search programs or skills...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.buttonBlue,
                  ),
                  suffixIcon: programs.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            programs.setSearchQuery('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Level filter chips
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: programs.levelFilter == null,
                    onTap: () => programs.setLevelFilter(null),
                  ),
                  ...programs.availableLevels.map(
                    (level) => _FilterChip(
                      label: level,
                      selected: programs.levelFilter == level,
                      onTap: () => programs.setLevelFilter(level),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            // Programs list
            Expanded(
              child: programs.isLoading
                  ? const LoadingOverlay(message: 'Loading programs...')
                  : programs.programs.isEmpty
                  ? EmptyState(
                      icon: Icons.search_off,
                      title: 'No programs found',
                      subtitle:
                          programs.searchQuery.isNotEmpty ||
                              programs.levelFilter != null
                          ? 'Try adjusting your search or filters.'
                          : 'No programs are available yet.',
                      actionLabel:
                          programs.searchQuery.isNotEmpty ||
                              programs.levelFilter != null
                          ? 'Clear filters'
                          : null,
                      onAction:
                          programs.searchQuery.isNotEmpty ||
                              programs.levelFilter != null
                          ? () {
                              _searchController.clear();
                              programs.clearFilters();
                            }
                          : null,
                    )
                  : ListView(
                      padding: const EdgeInsets.all(AppSizes.xl),
                      children: programs.programs
                          .map(
                            (p) => ProgramCard(
                              program: p,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.learnerProgramDetails,
                                arguments: p,
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNav(
          currentTab: BottomNavTab.programs,
          onTabChanged: (tab) => handleBottomNavTap(context, tab),
        ),
      ), // Scaffold
    ); // PopScope
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSizes.sm),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.buttonBlue,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.deepBlue,
          fontWeight: FontWeight.w500,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? AppColors.buttonBlue : Colors.grey.shade300,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }
}
