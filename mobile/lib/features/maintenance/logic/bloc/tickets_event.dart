import 'package:equatable/equatable.dart';
import 'package:mobile/features/maintenance/data/dto/create_ticket_request.dart';
import 'package:mobile/features/maintenance/data/dto/update_ticket_request.dart';
import 'package:mobile/features/maintenance/data/dto/add_comment_request.dart';
import 'package:mobile/features/maintenance/data/models/status.dart';
import 'package:mobile/features/maintenance/data/models/priority.dart';

abstract class TicketsEvent extends Equatable {
  const TicketsEvent();

  @override
  List<Object?> get props => [];
}

class TicketsRequested extends TicketsEvent {
  final Status? status;
  final Priority? priority;

  const TicketsRequested({this.status, this.priority});

  @override
  List<Object?> get props => [status, priority];
}

class TicketDetailRequested extends TicketsEvent {
  final int id;

  const TicketDetailRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class TicketCreated extends TicketsEvent {
  final CreateTicketRequest request;

  const TicketCreated(this.request);

  @override
  List<Object?> get props => [request];
}

class TicketUpdated extends TicketsEvent {
  final int id;
  final UpdateTicketRequest request;

  const TicketUpdated({required this.id, required this.request});

  @override
  List<Object?> get props => [id, request];
}

class TicketCancelled extends TicketsEvent {
  final int id;

  const TicketCancelled(this.id);

  @override
  List<Object?> get props => [id];
}

class UserCommentAdded extends TicketsEvent {
  final int ticketId;
  final AddCommentRequest request;

  const UserCommentAdded({required this.ticketId, required this.request});

  @override
  List<Object?> get props => [ticketId, request];
}

class TicketSearchChanged extends TicketsEvent {
  final String query;

  const TicketSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class TicketDetailCleared extends TicketsEvent {
  const TicketDetailCleared();

  @override
  List<Object?> get props => [];
}

class ResetTickets extends TicketsEvent {
  const ResetTickets();

  @override
  List<Object?> get props => [];
}
