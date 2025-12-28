import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mobile/features/maintenance/data/dto/ticket_dto.dart';
import 'package:mobile/features/maintenance/data/repositories/i_maintenance_repository.dart';
import 'tickets_event.dart';
import 'tickets_state.dart';

class TicketsBloc extends Bloc<TicketsEvent, TicketsState> {
  final IMaintenanceRepository maintenanceRepository;

  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
  }

  List<TicketDTO> _applySearchFilter(List<TicketDTO> source, String? rawQuery) {
    final query = (rawQuery ?? '').trim().toLowerCase();
    if (query.isEmpty) return source;

    return source.where((t) {
      final title = t.title.toLowerCase();
      final desc = t.description.toLowerCase();
      final idStr = t.id.toString();
      final createdBy = (t.createdByUserName ?? '').toLowerCase();
      return title.contains(query) ||
          desc.contains(query) ||
          idStr.contains(query) ||
          createdBy.contains(query);
    }).toList();
  }

  List<TicketDTO> _sortByCreatedDesc(List<TicketDTO> source) {
    final list = [...source];
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  TicketsBloc({required this.maintenanceRepository}) : super(TicketsState()) {
    on<TicketsRequested>(_onTicketsRequested);
    on<TicketDetailRequested>(_onTicketDetailRequested);
    on<TicketCreated>(_onTicketCreated);
    on<TicketUpdated>(_onTicketUpdated);
    on<TicketCancelled>(_onTicketCancelled);
    on<UserCommentAdded>(_onUserCommentAdded);
    on<TicketSearchChanged>(
      _onSearchChanged,
      transformer: debounce(const Duration(milliseconds: 300)),
    );
    on<TicketDetailCleared>(_onTicketDetailCleared);
    on<ResetTickets>(_onResetTickets);
  }

  String _getUserFriendlyError(dynamic error, String action) {
    final errorString = error.toString();
    
    if (errorString.contains('Erreur') || errorString.contains('impossible')) {
      return errorString;
    }
    
    if (errorString.contains('403') || errorString.contains('Forbidden')) {
      return 'Vous n\'avez pas les permissions nécessaires pour $action.';
    }
    if (errorString.contains('404') || errorString.contains('Not Found')) {
      return 'Le ticket demandé n\'existe pas ou a été supprimé.';
    }
    if (errorString.contains('400') || errorString.contains('Bad Request')) {
      return 'Les données fournies sont invalides. Veuillez vérifier et réessayer.';
    }
    if (errorString.contains('401') || errorString.contains('Unauthorized')) {
      return 'Votre session a expiré. Veuillez vous reconnecter.';
    }
    if (errorString.contains('409') || errorString.contains('Conflict')) {
      return 'Ce ticket ne peut pas être modifié dans son état actuel.';
    }
    if (errorString.contains('réseau') || errorString.contains('connexion')) {
      return 'Impossible de $action. Vérifiez votre connexion internet.';
    }
    if (errorString.contains('timeout') || errorString.contains('Délai')) {
      return 'La requête a pris trop de temps. Veuillez réessayer.';
    }
    
    return 'Impossible de $action. Veuillez réessayer.';
  }

  Future<void> _onTicketsRequested(
    TicketsRequested event,
    Emitter<TicketsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: TicketsStatus.loading,
        error: null,
        filterStatus: event.status,
        filterPriority: event.priority,
      ),
    );
    try {
      final rawTickets = await maintenanceRepository.getMyTickets(
        status: event.status,
        priority: event.priority,
      );
      final sorted = _sortByCreatedDesc(rawTickets);
      final visible = _applySearchFilter(sorted, state.searchQuery);
      emit(
        state.copyWith(
          status: TicketsStatus.loaded,
          tickets: sorted,
          visibleTickets: visible,
        ),
      );
    } catch (e) {
      final userMessage = _getUserFriendlyError(e, 'charger les tickets');
      emit(state.copyWith(status: TicketsStatus.failure, error: userMessage));
    }
  }

  Future<void> _onTicketDetailRequested(
    TicketDetailRequested event,
    Emitter<TicketsState> emit,
  ) async {
    emit(state.copyWith(isDetailLoading: true, error: null));
    try {
      final ticket = await maintenanceRepository.getTicketById(event.id);

      // Met à jour la liste et les tickets visibles pour garder
      // l'écran de liste et le détail synchronisés.
      List<TicketDTO> updatedTickets;
      if (state.tickets.isEmpty) {
        updatedTickets = [ticket];
      } else {
        updatedTickets = _sortByCreatedDesc(
          state.tickets.map((t) => t.id == ticket.id ? ticket : t).toList(),
        );
      }

      final visible = _applySearchFilter(updatedTickets, state.searchQuery);

      emit(
        state.copyWith(
          selectedTicket: ticket,
          isDetailLoading: false,
          tickets: updatedTickets,
          visibleTickets: visible,
        ),
      );
    } catch (e) {
      final userMessage = _getUserFriendlyError(e, 'charger les détails du ticket');
      emit(state.copyWith(isDetailLoading: false, error: userMessage));
    }
  }

  Future<void> _onTicketCreated(
    TicketCreated event,
    Emitter<TicketsState> emit,
  ) async {
    emit(state.copyWith(status: TicketsStatus.submitting, error: null));
    try {
      final created = await maintenanceRepository.createTicket(event.request);
      final updatedTickets = _sortByCreatedDesc(<TicketDTO>[
        ...state.tickets,
        created,
      ]);
      final visible = _applySearchFilter(updatedTickets, state.searchQuery);
      emit(
        state.copyWith(
          status: TicketsStatus.success,
          tickets: updatedTickets,
          visibleTickets: visible,
        ),
      );
      emit(state.copyWith(status: TicketsStatus.loaded));
    } catch (e) {
      final userMessage = _getUserFriendlyError(e, 'créer le ticket');
      emit(state.copyWith(status: TicketsStatus.failure, error: userMessage));
    }
  }

  Future<void> _onTicketUpdated(
    TicketUpdated event,
    Emitter<TicketsState> emit,
  ) async {
    emit(state.copyWith(status: TicketsStatus.submitting, error: null));
    try {
      final updated = await maintenanceRepository.updateTicket(
        event.id,
        event.request,
      );
      final updatedTickets = _sortByCreatedDesc(
        state.tickets.map((t) => t.id == event.id ? updated : t).toList(),
      );
      final visible = _applySearchFilter(updatedTickets, state.searchQuery);
      emit(
        state.copyWith(
          status: TicketsStatus.success,
          tickets: updatedTickets,
          visibleTickets: visible,
        ),
      );
      emit(state.copyWith(status: TicketsStatus.loaded));
    } catch (e) {
      final userMessage = _getUserFriendlyError(e, 'modifier le ticket');
      emit(state.copyWith(status: TicketsStatus.failure, error: userMessage));
    }
  }

  Future<void> _onTicketCancelled(
    TicketCancelled event,
    Emitter<TicketsState> emit,
  ) async {
    emit(state.copyWith(status: TicketsStatus.submitting, error: null));
    try {
      final cancelled = await maintenanceRepository.cancelTicket(event.id);
      final updatedTickets = _sortByCreatedDesc(
        state.tickets.map((t) => t.id == event.id ? cancelled : t).toList(),
      );
      final visible = _applySearchFilter(updatedTickets, state.searchQuery);
      emit(
        state.copyWith(
          status: TicketsStatus.success,
          tickets: updatedTickets,
          visibleTickets: visible,
        ),
      );
      emit(state.copyWith(status: TicketsStatus.loaded));
    } catch (e) {
      final userMessage = _getUserFriendlyError(e, 'annuler le ticket');
      emit(state.copyWith(status: TicketsStatus.failure, error: userMessage));
    }
  }

  Future<void> _onUserCommentAdded(
    UserCommentAdded event,
    Emitter<TicketsState> emit,
  ) async {
    emit(state.copyWith(status: TicketsStatus.submitting, error: null));
    try {
      final updatedTicket = await maintenanceRepository.addUserComment(
        event.ticketId,
        event.request,
      );

      final updatedTickets = _sortByCreatedDesc(
        state.tickets
            .map((t) => t.id == event.ticketId ? updatedTicket : t)
            .toList(),
      );

      TicketDTO? refreshedSelected = state.selectedTicket;
      if (state.selectedTicket?.id == event.ticketId) {
        refreshedSelected = updatedTicket;
      }

      final visible = _applySearchFilter(updatedTickets, state.searchQuery);
      emit(
        state.copyWith(
          status: TicketsStatus.success,
          tickets: updatedTickets,
          visibleTickets: visible,
          selectedTicket: refreshedSelected,
        ),
      );
      emit(state.copyWith(status: TicketsStatus.loaded));
    } catch (e) {
      final userMessage = _getUserFriendlyError(e, 'ajouter le commentaire');
      emit(state.copyWith(status: TicketsStatus.failure, error: userMessage));
    }
  }

  Future<void> _onTicketDetailCleared(
    TicketDetailCleared event,
    Emitter<TicketsState> emit,
  ) async {
    emit(
      TicketsState(
        status: state.status,
        tickets: state.tickets,
        visibleTickets: state.visibleTickets,
        error: state.error,
        selectedTicket: null,
        isDetailLoading: state.isDetailLoading,
        filterStatus: state.filterStatus,
        filterPriority: state.filterPriority,
        searchQuery: state.searchQuery,
      ),
    );
  }

  Future<void> _onSearchChanged(
    TicketSearchChanged event,
    Emitter<TicketsState> emit,
  ) async {
    final visible = _applySearchFilter(state.tickets, event.query);
    emit(state.copyWith(searchQuery: event.query, visibleTickets: visible));
  }

  Future<void> _onResetTickets(
    ResetTickets event,
    Emitter<TicketsState> emit,
  ) async {
    emit(TicketsState());
  }
}
