import { useEffect, useMemo, useState } from "react";
import { ArrowLeft, CheckCircle, Clock, Home, MapPin } from "lucide-react";
import type { PublicLabCard, PublicTestResponse } from "../../lib/publicApi";

type DisplaySlot = {
  id: string;
  startsAt: string;
  endsAt: string;
};

interface BookingPageProps {
  lab: PublicLabCard | null;
  test?: PublicTestResponse | null;
  slots: DisplaySlot[];
  isLoading?: boolean;
  isSubmitting?: boolean;
  errorMessage?: string | null;
  onBack: () => void;
  onComplete: () => void;
  onSubmit: (payload: {
    slotId: string;
    bookingType: "LabVisit" | "HomeCollection";
    homeAddress?: string;
  }) => Promise<void>;
}

function toDateKey(dateIso: string) {
  return new Date(dateIso).toISOString().slice(0, 10);
}

function formatDay(dateIso: string) {
  const date = new Date(dateIso);
  return date.toLocaleDateString("en-GB", { weekday: "short", day: "2-digit", month: "short" });
}

function formatTime(dateIso: string) {
  const date = new Date(dateIso);
  return date.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit", hour12: false });
}

export function BookingPage({
  lab,
  test,
  slots,
  isLoading,
  isSubmitting,
  errorMessage,
  onBack,
  onComplete,
  onSubmit,
}: BookingPageProps) {
  const [bookingType, setBookingType] = useState<"lab" | "home">("lab");
  const [selectedDate, setSelectedDate] = useState("");
  const [selectedSlotId, setSelectedSlotId] = useState("");
  const [homeAddress, setHomeAddress] = useState("");
  const [showConfirmation, setShowConfirmation] = useState(false);
  const [localError, setLocalError] = useState<string | null>(null);

  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  const dates = useMemo(() => {
    const map = new Map<string, string>();
    for (const slot of slots) {
      const key = toDateKey(slot.startsAt);
      if (!map.has(key)) {
        map.set(key, formatDay(slot.startsAt));
      }
    }
    return Array.from(map.entries()).map(([key, label]) => ({ key, label }));
  }, [slots]);

  const effectiveSelectedDate = useMemo(() => {
    if (selectedDate && dates.some((date) => date.key === selectedDate)) {
      return selectedDate;
    }

    return dates[0]?.key ?? "";
  }, [dates, selectedDate]);

  const timeSlotsForDate = useMemo(
    () => slots.filter((slot) => toDateKey(slot.startsAt) === effectiveSelectedDate),
    [effectiveSelectedDate, slots],
  );

  const effectiveSelectedSlotId = useMemo(() => {
    if (selectedSlotId && timeSlotsForDate.some((slot) => slot.id === selectedSlotId)) {
      return selectedSlotId;
    }

    return "";
  }, [selectedSlotId, timeSlotsForDate]);

  const selectedSlot = useMemo(
    () => slots.find((slot) => slot.id === effectiveSelectedSlotId) ?? null,
    [effectiveSelectedSlotId, slots],
  );

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <p>Loading booking...</p>
      </div>
    );
  }

  if (!lab) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p>No lab selected</p>
      </div>
    );
  }

  const basePrice = test?.priceEgp ?? lab.startingFromEgp ?? 0;

  const handleBooking = async () => {
    setLocalError(null);
    if (!effectiveSelectedSlotId) {
      setLocalError("Please select a time slot.");
      return;
    }
    if (bookingType === "home" && !homeAddress.trim()) {
      setLocalError("Home address is required for home collection.");
      return;
    }

    try {
      await onSubmit({
        slotId: effectiveSelectedSlotId,
        bookingType: bookingType === "home" ? "HomeCollection" : "LabVisit",
        homeAddress: bookingType === "home" ? homeAddress.trim() : undefined,
      });
      setShowConfirmation(true);
      setTimeout(() => onComplete(), 1200);
    } catch {
      // Parent handles API error state.
    }
  };

  if (showConfirmation && selectedSlot) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="bg-white rounded-xl shadow-lg p-8 max-w-md text-center">
          <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <CheckCircle className="w-10 h-10 text-green-600" />
          </div>
          <h2 className="text-2xl text-gray-900 mb-2">Booking Confirmed!</h2>
          <div className="bg-blue-50 rounded-lg p-4 text-left">
            <div className="text-gray-900 mb-2">{lab.name}</div>
            <div className="text-gray-600">
              {formatDay(selectedSlot.startsAt)} at {formatTime(selectedSlot.startsAt)}
            </div>
            <div className="text-gray-600">{bookingType === "home" ? "Home Collection" : "Lab Visit"}</div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <button onClick={onBack} className="flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-4">
            <ArrowLeft className="w-5 h-5" />
            Back to Lab Details
          </button>
          <h1 className="text-2xl text-gray-900">Book Your Appointment</h1>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="bg-white rounded-xl shadow-sm p-6 mb-6">
          <div className="flex items-start justify-between">
            <div>
              <h2 className="text-xl text-gray-900 mb-2">{lab.name}</h2>
              <div className="flex items-center gap-2 text-gray-600 mb-2">
                <MapPin className="w-4 h-4" />
                <span>{lab.address}</span>
              </div>
              <div className="text-gray-600">{test?.name || "Selected test"}</div>
            </div>
            <div className="text-right">
              <div className="text-3xl text-blue-600">EGP {basePrice}</div>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm p-6 mb-6">
          <h3 className="text-lg text-gray-900 mb-4">Choose Collection Type</h3>
          <div className="grid grid-cols-2 gap-4">
            <button
              onClick={() => setBookingType("lab")}
              className={`p-6 rounded-lg border-2 transition ${
                bookingType === "lab" ? "border-blue-600 bg-blue-50" : "border-gray-200 hover:border-gray-300"
              }`}
            >
              <MapPin className={`w-8 h-8 mx-auto mb-3 ${bookingType === "lab" ? "text-blue-600" : "text-gray-400"}`} />
              <div className="text-gray-900 mb-1">Visit Lab</div>
              <div className="text-gray-600">Come to our facility</div>
            </button>
            {lab.homeCollection && (
              <button
                onClick={() => setBookingType("home")}
                className={`p-6 rounded-lg border-2 transition ${
                  bookingType === "home" ? "border-blue-600 bg-blue-50" : "border-gray-200 hover:border-gray-300"
                }`}
              >
                <Home className={`w-8 h-8 mx-auto mb-3 ${bookingType === "home" ? "text-blue-600" : "text-gray-400"}`} />
                <div className="text-gray-900 mb-1">Home Collection</div>
                <div className="text-gray-600">We come to you (+EGP 100)</div>
              </button>
            )}
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm p-6 mb-6">
          <h3 className="text-lg text-gray-900 mb-4">Select Date</h3>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
            {dates.map((date) => (
              <button
                key={date.key}
                onClick={() => setSelectedDate(date.key)}
                className={`p-4 rounded-lg border-2 transition ${
                  effectiveSelectedDate === date.key ? "border-blue-600 bg-blue-50" : "border-gray-200 hover:border-gray-300"
                }`}
              >
                <div className="text-gray-900">{date.label}</div>
              </button>
            ))}
            {dates.length === 0 && <p className="text-gray-600 col-span-4">No available dates in the selected range.</p>}
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm p-6 mb-6">
          <h3 className="text-lg text-gray-900 mb-4">Select Time Slot</h3>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
            {timeSlotsForDate.map((slot) => (
              <button
                key={slot.id}
                onClick={() => setSelectedSlotId(slot.id)}
                className={`p-4 rounded-lg border-2 transition ${
                  selectedSlotId === slot.id ? "border-blue-600 bg-blue-50" : "border-gray-200 hover:border-gray-300"
                }`}
              >
                <Clock className={`w-5 h-5 mx-auto mb-2 ${selectedSlotId === slot.id ? "text-blue-600" : "text-gray-400"}`} />
                <div className="text-gray-900">{formatTime(slot.startsAt)}</div>
              </button>
            ))}
            {effectiveSelectedDate && timeSlotsForDate.length === 0 && (
              <p className="text-gray-600 col-span-4">No slots available for this date.</p>
            )}
          </div>
        </div>

        {bookingType === "home" && (
          <div className="bg-white rounded-xl shadow-sm p-6 mb-6">
            <h3 className="text-lg text-gray-900 mb-4">Home Address</h3>
            <textarea
              value={homeAddress}
              onChange={(event) => setHomeAddress(event.target.value)}
              placeholder="Enter your complete address for sample collection"
              className="w-full px-4 py-3 border border-gray-300 rounded-lg resize-none"
              rows={3}
            />
          </div>
        )}

        <div className="bg-white rounded-xl shadow-sm p-6">
          <h3 className="text-lg text-gray-900 mb-4">Booking Summary</h3>
          <div className="space-y-3 mb-6">
            <div className="flex justify-between">
              <span className="text-gray-600">Test Price</span>
              <span className="text-gray-900">EGP {basePrice}</span>
            </div>
            {bookingType === "home" && (
              <div className="flex justify-between">
                <span className="text-gray-600">Home Collection Fee</span>
                <span className="text-gray-900">EGP 100</span>
              </div>
            )}
            <div className="border-t pt-3 flex justify-between">
              <span className="text-gray-900">Total Amount</span>
              <span className="text-2xl text-blue-600">EGP {basePrice + (bookingType === "home" ? 100 : 0)}</span>
            </div>
          </div>
          {(localError || errorMessage) && <p className="text-red-600 mb-4">{localError || errorMessage}</p>}
          <button
            onClick={handleBooking}
            disabled={!effectiveSelectedSlotId || !!isSubmitting}
            className="w-full py-4 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed"
          >
            {isSubmitting ? "Confirming..." : "Confirm Booking"}
          </button>
        </div>
      </div>
    </div>
  );
}
