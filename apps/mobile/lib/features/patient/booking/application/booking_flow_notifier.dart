import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/booking_models.dart';
import '../data/booking_repository.dart';

enum BookingStep { type, slot, address, payment, confirm, submitting, done, error }

class BookingFlowState {
  const BookingFlowState({
    required this.params,
    this.step = BookingStep.type,
    this.selectedType,
    this.slots = const [],
    this.slotsLoading = false,
    this.selectedSlot,
    this.homeAddress,
    this.selectedPayment,
    this.result,
    this.errorMessage,
  });

  final BookingFlowParams params;
  final BookingStep step;
  final BookingType? selectedType;
  final List<BookingSlot> slots;
  final bool slotsLoading;
  final BookingSlot? selectedSlot;
  final String? homeAddress;
  final PaymentMethod? selectedPayment;
  final BookingItem? result;
  final String? errorMessage;

  BookingFlowState copyWith({
    BookingStep? step,
    BookingType? selectedType,
    List<BookingSlot>? slots,
    bool? slotsLoading,
    BookingSlot? selectedSlot,
    String? homeAddress,
    PaymentMethod? selectedPayment,
    BookingItem? result,
    String? errorMessage,
  }) {
    return BookingFlowState(
      params: params,
      step: step ?? this.step,
      selectedType: selectedType ?? this.selectedType,
      slots: slots ?? this.slots,
      slotsLoading: slotsLoading ?? this.slotsLoading,
      selectedSlot: selectedSlot ?? this.selectedSlot,
      homeAddress: homeAddress ?? this.homeAddress,
      selectedPayment: selectedPayment ?? this.selectedPayment,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class BookingFlowNotifier
    extends FamilyNotifier<BookingFlowState, BookingFlowParams> {
  @override
  BookingFlowState build(BookingFlowParams arg) {
    return BookingFlowState(params: arg);
  }

  Future<void> selectType(BookingType type) async {
    state = state.copyWith(
      selectedType: type,
      slotsLoading: true,
      step: BookingStep.slot,
      slots: [],
    );

    try {
      final response = await ref.read(bookingRepositoryProvider).getAvailability(
            labId: arg.labId,
            testId: arg.testId,
            days: 7,
          );
      state = state.copyWith(slots: response.items, slotsLoading: false);
    } catch (e) {
      state = state.copyWith(
        slotsLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void selectSlot(BookingSlot slot) {
    final needsAddress = state.selectedType == BookingType.homeCollection ||
        state.selectedType == BookingType.homeTestKit;
    state = state.copyWith(
      selectedSlot: slot,
      step: needsAddress ? BookingStep.address : BookingStep.payment,
    );
  }

  void skipSlot() {
    final needsAddress = state.selectedType == BookingType.homeCollection ||
        state.selectedType == BookingType.homeTestKit;
    state = state.copyWith(
      step: needsAddress ? BookingStep.address : BookingStep.payment,
    );
  }

  void submitAddress(String address) {
    state = state.copyWith(homeAddress: address, step: BookingStep.payment);
  }

  void selectPayment(PaymentMethod payment) {
    state = state.copyWith(selectedPayment: payment, step: BookingStep.confirm);
  }

  void back() {
    switch (state.step) {
      case BookingStep.slot:
        state = state.copyWith(step: BookingStep.type);
        break;
      case BookingStep.address:
        state = state.copyWith(step: BookingStep.slot);
        break;
      case BookingStep.payment:
        final hasAddress = state.selectedType == BookingType.homeCollection ||
            state.selectedType == BookingType.homeTestKit;
        state = state.copyWith(
            step: hasAddress ? BookingStep.address : BookingStep.slot);
        break;
      case BookingStep.confirm:
        state = state.copyWith(step: BookingStep.payment);
        break;
      default:
        break;
    }
  }

  Future<void> confirm() async {
    state = state.copyWith(step: BookingStep.submitting);
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final booking = await repo.createBooking(
        labId: arg.labId,
        testId: arg.testId,
        bookingType: state.selectedType!,
        slotId: state.selectedSlot?.id,
        homeAddress: state.homeAddress,
        paymentMethod: state.selectedPayment,
      );

      if (state.selectedPayment == PaymentMethod.online) {
        final paid = await repo.demoPayment(booking.id, 'success');
        state = state.copyWith(result: paid, step: BookingStep.done);
      } else {
        state = state.copyWith(result: booking, step: BookingStep.done);
      }
    } catch (e) {
      state = state.copyWith(
        step: BookingStep.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final bookingFlowProvider = NotifierProvider.family<BookingFlowNotifier,
    BookingFlowState, BookingFlowParams>(
  BookingFlowNotifier.new,
);
