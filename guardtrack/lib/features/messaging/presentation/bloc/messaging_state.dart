import 'package:equatable/equatable.dart';

abstract class MessagingState extends Equatable {
  const MessagingState();

  @override
  List<Object?> get props => [];
}

class MessagingInitial extends MessagingState {
  const MessagingInitial();
}

class MessagingLoading extends MessagingState {
  final String message;

  const MessagingLoading({required this.message});

  @override
  List<Object?> get props => [message];
}

class WhatsAppMessageSent extends MessagingState {
  final String phoneNumber;
  final String message;

  const WhatsAppMessageSent({
    required this.phoneNumber,
    required this.message,
  });

  @override
  List<Object?> get props => [phoneNumber, message];
}

class EmailMessageSent extends MessagingState {
  final String email;
  final String subject;

  const EmailMessageSent({
    required this.email,
    required this.subject,
  });

  @override
  List<Object?> get props => [email, subject];
}

class MessagingError extends MessagingState {
  final String message;
  final String? details;

  const MessagingError({
    required this.message,
    this.details,
  });

  @override
  List<Object?> get props => [message, details];
}
