import 'package:equatable/equatable.dart';

abstract class MessagingEvent extends Equatable {
  const MessagingEvent();

  @override
  List<Object?> get props => [];
}

class SendWhatsAppMessage extends MessagingEvent {
  final String phoneNumber;
  final String message;

  const SendWhatsAppMessage({
    required this.phoneNumber,
    required this.message,
  });

  @override
  List<Object?> get props => [phoneNumber, message];
}

class SendEmailMessage extends MessagingEvent {
  final String email;
  final String subject;
  final String body;

  const SendEmailMessage({
    required this.email,
    required this.subject,
    required this.body,
  });

  @override
  List<Object?> get props => [email, subject, body];
}

class SendEmailViaClient extends MessagingEvent {
  final String email;
  final String subject;
  final String body;

  const SendEmailViaClient({
    required this.email,
    required this.subject,
    required this.body,
  });

  @override
  List<Object?> get props => [email, subject, body];
}

class ResetMessagingState extends MessagingEvent {
  const ResetMessagingState();
}
