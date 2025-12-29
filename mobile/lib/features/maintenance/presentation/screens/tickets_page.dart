import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/presentation/widgets/notification_icon_button.dart';
import 'package:mobile/core/rooting/app_routes.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/maintenance/logic/bloc/tickets_bloc.dart';
import 'package:mobile/features/maintenance/logic/bloc/tickets_event.dart';
import 'package:mobile/features/maintenance/logic/bloc/tickets_state.dart';
import 'package:mobile/features/maintenance/data/models/status.dart';
import 'package:mobile/features/maintenance/data/models/priority.dart';
import 'package:mobile/features/maintenance/presentation/widgets/ticket_card.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentSearch = context.read<TicketsBloc>().state.searchQuery;
      if (currentSearch != null && currentSearch.isNotEmpty) {
        _searchController.text = currentSearch;
      }
      context.read<TicketsBloc>().add(const TicketsRequested());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<TicketsBloc, TicketsState>(
      listener: (context, state) {
        if (state.status == TicketsStatus.failure && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (state.status == TicketsStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Opération réussie',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: theme.colorScheme.primary,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, theme),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildSearchBar(theme),
                        const SizedBox(height: 16),
                        Expanded(child: _buildTicketsList(theme)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: _buildFAB(context, theme),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onPrimary,
                ),
                onPressed: () => context.pop(),
              ),
              const Spacer(),
              const NotificationIconButton(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.confirmation_number_outlined,
                  color: theme.colorScheme.onPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes Tickets',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gérez vos demandes de support',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onPrimary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (context, value, _) {
          return TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher votre ticket',
              prefixIcon: Icon(
                Icons.search,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (value.text.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        context.read<TicketsBloc>().add(
                          const TicketSearchChanged(''),
                        );
                      },
                    ),
                  IconButton(
                    icon: Icon(Icons.tune, color: theme.colorScheme.primary),
                    onPressed: _openFilters,
                  ),
                ],
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            onChanged: (value) => context.read<TicketsBloc>().add(
              TicketSearchChanged(value.trim()),
            ),
          );
        },
      ),
    );
  }

  void _openFilters() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        Status? selectedStatus = context.read<TicketsBloc>().state.filterStatus;
        Priority? selectedPriority = context
            .read<TicketsBloc>()
            .state
            .filterPriority;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxHeight = constraints.maxHeight * 0.9;
                  return ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Filtres',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  setModalState(() {
                                    selectedStatus = null;
                                    selectedPriority = null;
                                  });
                                },
                                child: const Text('Réinitialiser'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Statut',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _statusChip(
                                        null,
                                        'Tous',
                                        selectedStatus == null,
                                        (val) => setModalState(
                                            () => selectedStatus = null),
                                      ),
                                      for (final s in Status.values)
                                        _statusChip(
                                          s,
                                          s.getDisplayName(),
                                          selectedStatus == s,
                                          (val) => setModalState(
                                              () => selectedStatus = s),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Priorité',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _priorityChip(
                                        null,
                                        'Toutes',
                                        selectedPriority == null,
                                        (val) => setModalState(
                                            () => selectedPriority = null),
                                      ),
                                      for (final p in Priority.values)
                                        _priorityChip(
                                          p,
                                          p.getDisplayName(),
                                          selectedPriority == p,
                                          (val) => setModalState(
                                              () => selectedPriority = p),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                context.pop();
                                context.read<TicketsBloc>().add(
                                  TicketsRequested(
                                    status: selectedStatus,
                                    priority: selectedPriority,
                                  ),
                                );
                              },
                              child: const Text('Appliquer les filtres'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _statusChip(
    Status? value,
    String label,
    bool selected,
    ValueChanged<bool> onSelected,
  ) {
    return FilterChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onSelected(true),
    );
  }

  Widget _priorityChip(
    Priority? value,
    String label,
    bool selected,
    ValueChanged<bool> onSelected,
  ) {
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onSelected(true),
    );
  }

  Widget _buildTicketsList(ThemeData theme) {
    return BlocBuilder<TicketsBloc, TicketsState>(
      builder: (context, state) {
        if (state.status == TicketsStatus.loading) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        if (state.status == TicketsStatus.failure) {
          return _buildEmptyState(
            theme: theme,
            icon: Icons.error_outline,
            title: 'Erreur',
            message: state.error ?? 'Une erreur est survenue',
            action: ElevatedButton(
              onPressed: () =>
                  context.read<TicketsBloc>().add(const TicketsRequested()),
              child: const Text('Réessayer'),
            ),
          );
        }

        final tickets = state.visibleTickets;

        if (tickets.isEmpty) {
          return _buildEmptyState(
            theme: theme,
            icon: state.tickets.isEmpty
                ? Icons.inbox_outlined
                : Icons.search_off,
            title: state.tickets.isEmpty ? 'Aucun ticket' : 'Aucun résultat',
            message: state.tickets.isEmpty
                ? 'Vous n\'avez pas encore créé de ticket.\nCommencez par créer votre premier ticket !'
                : 'Aucun ticket ne correspond à votre recherche.',
            action: state.tickets.isEmpty
                ? ElevatedButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.maintenanceTicketCreate),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer un ticket'),
                  )
                : null,
          );
        }

        return RefreshIndicator(
          color: theme.colorScheme.primary,
          onRefresh: () async =>
              context.read<TicketsBloc>().add(const TicketsRequested()),
          child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TicketCard(
                  ticket: ticket,
                  onTap: () => context.push(
                    AppRoutes.maintenanceTicketDetail.replaceFirst(
                      ':id',
                      ticket.id.toString(),
                    ),
                    extra: ticket,
                  ),
                  onCancel: () => context.read<TicketsBloc>().add(
                    TicketCancelled(ticket.id),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 24), action],
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.maintenanceTicketCreate),
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        hoverElevation: 0,
        focusElevation: 0,
        highlightElevation: 0,
        splashColor: Colors.white.withOpacity(0.1),
        icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
        label: Text(
          'Créer un ticket',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
