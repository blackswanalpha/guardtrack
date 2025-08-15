import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/services/messaging_service.dart';
import '../../../../core/utils/logger.dart';
import 'messaging_event.dart';
import 'messaging_state.dart';

class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {
  final MessagingService _messagingService;

  MessagingBloc({
    MessagingService? messagingService,
  })  : _messagingService = messagingService ?? MessagingService(),
        super(const MessagingInitial()) {
    on<SendWhatsAppMessage>(_onSendWhatsAppMessage);
    on<SendEmailMessage>(_onSendEmailMessage);
    on<SendEmailViaClient>(_onSendEmailViaClient);
    on<ResetMessagingState>(_onResetMessagingState);
  }

  Future<void> _onSendWhatsAppMessage(
    SendWhatsAppMessage event,
    Emitter<MessagingState> emit,
  ) async {
    try {
      // Validate phone number
      if (!_messagingService.isValidPhoneNumber(event.phoneNumber)) {
        emit(const MessagingError(
          message: 'Invalid phone number format',
          details: 'Please enter a valid phone number with country code',
        ));
        return;
      }

      // Validate message
      if (event.message.trim().isEmpty) {
        emit(const MessagingError(
          message: 'Message cannot be empty',
          details: 'Please enter a message to send',
        ));
        return;
      }

      emit(const MessagingLoading(message: 'Opening WhatsApp...'));

      final success = await _messagingService.sendWhatsAppMessage(
        phoneNumber: event.phoneNumber,
        message: event.message,
      );

      if (success) {
        emit(WhatsAppMessageSent(
          phoneNumber: event.phoneNumber,
          message: event.message,
        ));
        Logger.info(
          'WhatsApp message sent successfully to ${event.phoneNumber}',
          tag: 'MessagingBloc',
        );
      } else {
        emit(const MessagingError(
          message: 'Failed to send WhatsApp message',
          details: 'Please try again or check if WhatsApp is installed',
        ));
      }
    } catch (e) {
      Logger.error('Error sending WhatsApp message: $e', tag: 'MessagingBloc');
      emit(MessagingError(
        message: 'Failed to send WhatsApp message',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onSendEmailMessage(
    SendEmailMessage event,
    Emitter<MessagingState> emit,
  ) async {
    try {
      // Validate email
      if (!_messagingService.isValidEmail(event.email)) {
        emit(const MessagingError(
          message: 'Invalid email address',
          details: 'Please enter a valid email address',
        ));
        return;
      }

      // Validate subject and body
      if (event.subject.trim().isEmpty) {
        emit(const MessagingError(
          message: 'Subject cannot be empty',
          details: 'Please enter an email subject',
        ));
        return;
      }

      if (event.body.trim().isEmpty) {
        emit(const MessagingError(
          message: 'Message body cannot be empty',
          details: 'Please enter a message to send',
        ));
        return;
      }

      emit(const MessagingLoading(message: 'Sending email...'));

      final success = await _messagingService.sendEmail(
        to: event.email,
        subject: event.subject,
        body: event.body,
      );

      if (success) {
        emit(EmailMessageSent(
          email: event.email,
          subject: event.subject,
        ));
        Logger.info(
          'Email sent successfully to ${event.email}',
          tag: 'MessagingBloc',
        );
      } else {
        emit(const MessagingError(
          message: 'Failed to send email',
          details: 'Please try again later',
        ));
      }
    } catch (e) {
      Logger.error('Error sending email: $e', tag: 'MessagingBloc');
      emit(MessagingError(
        message: 'Failed to send email',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onSendEmailViaClient(
    SendEmailViaClient event,
    Emitter<MessagingState> emit,
  ) async {
    try {
      // Validate email
      if (!_messagingService.isValidEmail(event.email)) {
        emit(const MessagingError(
          message: 'Invalid email address',
          details: 'Please enter a valid email address',
        ));
        return;
      }

      emit(const MessagingLoading(message: 'Opening email client...'));

      final success = await _messagingService.sendEmailViaClient(
        to: event.email,
        subject: event.subject,
        body: event.body,
      );

      if (success) {
        emit(EmailMessageSent(
          email: event.email,
          subject: event.subject,
        ));
        Logger.info(
          'Email client opened for ${event.email}',
          tag: 'MessagingBloc',
        );
      } else {
        emit(const MessagingError(
          message: 'Failed to open email client',
          details: 'Please check if you have an email app installed',
        ));
      }
    } catch (e) {
      Logger.error('Error opening email client: $e', tag: 'MessagingBloc');
      emit(MessagingError(
        message: 'Failed to open email client',
        details: e.toString(),
      ));
    }
  }

  void _onResetMessagingState(
    ResetMessagingState event,
    Emitter<MessagingState> emit,
  ) {
    emit(const MessagingInitial());
  }
}
