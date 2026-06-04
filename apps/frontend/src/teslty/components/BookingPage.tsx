import { useEffect, useMemo, useState } from "react";

const HOME_COLLECTION_FEE = 100;
const HOME_KIT_FEE = 150;
import { useToast } from "../../components/ToastProvider";
import { ArrowLeft, CheckCircle, Clock, Home, MapPin, Package } from "lucide-react";
import type { PaymentMethod } from "../../lib/bookingsApi";
import type { PublicLabCard, PublicTestResponse } from "../../lib/publicApi";
import { Breadcrumb } from "../../components/Breadcrumb";

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
  onBack: () => void;
  onComplete: () => void;
  onSubmit: (payload: {
    slotId?: string;
    bookingType: "LabVisit" | "HomeCollection" | "HomeTestKit";
    homeAddress?: string;
    paymentMethod: PaymentMethod;
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
  onBack,
  onComplete,
  onSubmit,
}: BookingPageProps) {
  const [bookingType, setBookingType] = useState<"lab" | "home" | "kit">("lab");
  const [selectedDate, setSelectedDate] = useState("");
  const [selectedSlotId, setSelectedSlotId] = useState("");
  const [homeAddress, setHomeAddress] = useState("");
  const [paymentMethod, setPaymentMethod] = useState<PaymentMethod>("Online");
  const toast = useToast();
  const [showConfirmation, setShowConfirmation] = useState(false);

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

  const effectivePaymentMethod = useMemo<PaymentMethod>(() => {
    if (bookingType === "home" && paymentMethod !== "Online" && paymentMethod !== "CashHomeCollection") return "Online";
    if (bookingType === "lab" && paymentMethod !== "Online" && paymentMethod !== "CashLabVisit") return "Online";
    if (bookingType === "kit" && paymentMethod !== "Online" && paymentMethod !== "CashOnDelivery") return "Online";
    return paymentMethod;
  }, [bookingType, paymentMethod]);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50">
        <div className="bg-white shadow-sm">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-3">
            <div className="skeleton h-4 w-48 mb-3 rounded" />
            <div className="skeleton h-4 w-32 mb-2 rounded" />
            <div className="skeleton h-6 w-56 rounded" />
          </div>
        </div>
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-5 space-y-4">
          <div className="bg-white rounded-xl shadow-sm p-5 animate-slide-up">
            <div className="skeleton h-5 w-48 mb-2 rounded" />
            <div className="skeleton h-4 w-64 mb-2 rounded" />
            <div className="skeleton h-4 w-32 rounded" />
          </div>
          <div className="bg-white rounded-xl shadow-sm p-5 animate-slide-up animation-delay-100">
            <div className="skeleton h-5 w-40 mb-3 rounded" />
            <div className="grid grid-cols-3 gap-3">
              {[0, 1, 2].map((i) => <div key={i} className="skeleton h-24 rounded-lg" />)}
            </div>
          </div>
          <div className="bg-white rounded-xl shadow-sm p-5 animate-slide-up animation-delay-200">
            <div className="skeleton h-5 w-32 mb-3 rounded" />
            <div className="grid grid-cols-4 gap-3">
              {[0, 1, 2, 3].map((i) => <div key={i} className="skeleton h-16 rounded-lg" />)}
            </div>
          </div>
        </div>
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
    if (bookingType !== "kit" && !effectiveSelectedSlotId) {
      toast.error("Please select a time slot.");
      return;
    }
    if ((bookingType === "home" || bookingType === "kit") && !homeAddress.trim()) {
      toast.error("Delivery address is required.");
      return;
    }

    try {
      await onSubmit({
        slotId: bookingType === "kit" ? undefined : effectiveSelectedSlotId,
        bookingType: bookingType === "home" ? "HomeCollection" : bookingType === "kit" ? "HomeTestKit" : "LabVisit",
        homeAddress: (bookingType === "home" || bookingType === "kit") ? homeAddress.trim() : undefined,
        paymentMethod: effectivePaymentMethod,
      });
      setShowConfirmation(true);
      setTimeout(() => onComplete(), 1600);
    } catch {
      // Parent handles API error state.
    }
  };

  if (showConfirmation && (selectedSlot || bookingType === "kit")) {
    const onlineFlow = effectivePaymentMethod === "Online";
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="bg-white rounded-xl shadow-lg p-8 max-w-md text-center">
          <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <CheckCircle className="w-10 h-10 text-green-600" />
          </div>
          <h2 className="text-2xl text-gray-900 mb-2">
            {bookingType === "kit" ? "Kit order placed" : onlineFlow ? "Booking received" : "Booking request sent"}
          </h2>
          <p className="text-gray-600 mb-4 text-sm">
            {bookingType === "kit"
              ? "The lab will ship your kit within 2 business days. Track its progress from your dashboard."
              : onlineFlow
                ? "Use the demo payment buttons on your patient dashboard so the lab can confirm this booking."
                : "Pay in cash when the sample is collected or when you visit the lab."}
          </p>
          <div className="bg-blue-50 rounded-lg p-4 text-left">
            <div className="text-gray-900 mb-2">{lab.name}</div>
            {bookingType !== "kit" && selectedSlot && (
              <div className="text-gray-600">
                {formatDay(selectedSlot.startsAt)} at {formatTime(selectedSlot.startsAt)}
              </div>
            )}
            <div className="text-gray-600">
              {bookingType === "kit" ? "Home Test Kit" : bookingType === "home" ? "Home Collection" : "Lab Visit"}
            </div>
            <div className="text-gray-700 mt-2 text-sm">
              Payment:{" "}
              {effectivePaymentMethod === "Online"
                ? "Card / online (demo)"
                : effectivePaymentMethod === "CashHomeCollection"
                  ? "Cash on home collection"
                  : effectivePaymentMethod === "CashOnDelivery"
                    ? "Cash on delivery"
                    : "Cash at lab visit"}
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-3">
          <Breadcrumb
            items={[
              { label: "Labs", href: "/labs" },
              ...(lab ? [{ label: lab.name, href: `/labs/${lab.id}` }] : []),
              { label: "Book Appointment" },
            ]}
            className="mb-2"
          />
          <button onClick={onBack} className="flex items-center gap-2 text-gray-600 hover:text-gray-900 hover:-translate-x-0.5 transition-all duration-150 mb-2">
            <ArrowLeft className="w-4 h-4" />
            Back to Lab Details
          </button>
          <h1 className="text-xl text-gray-900">Book Your Appointment</h1>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-5">
        <div className="bg-white rounded-xl shadow-sm p-5 mb-4 animate-slide-up">
          <div className="flex items-start justify-between">
            <div>
              <h2 className="text-lg text-gray-900 mb-1.5">{lab.name}</h2>
              <div className="flex items-center gap-2 text-gray-600 text-sm mb-1">
                <MapPin className="w-4 h-4" />
                <span>{lab.address}</span>
              </div>
              <div className="text-gray-600 text-sm">{test?.name || "Selected test"}</div>
            </div>
            <div className="text-right">
              <div className="text-2xl text-blue-600">EGP {basePrice}</div>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm p-5 mb-4 animate-slide-up animation-delay-100">
          <h3 className="text-base text-gray-900 mb-3">Choose Collection Type</h3>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            <button
              onClick={() => setBookingType("lab")}
              className={`p-4 rounded-lg border-2 transition ${
                bookingType === "lab" ? "border-blue-600 bg-blue-50" : "border-gray-200 hover:border-gray-300"
              }`}
            >
              <MapPin className={`w-7 h-7 mx-auto mb-2 ${bookingType === "lab" ? "text-blue-600" : "text-gray-400"}`} />
              <div className="text-gray-900 mb-0.5">Visit Lab</div>
              <div className="text-gray-600 text-sm">Come to our facility</div>
            </button>
            <button
              onClick={() => setBookingType("home")}
              disabled={!lab.homeCollection}
              className={`p-4 rounded-lg border-2 transition ${
                !lab.homeCollection
                  ? "border-gray-100 bg-gray-50 cursor-not-allowed opacity-60"
                  : bookingType === "home"
                    ? "border-blue-600 bg-blue-50"
                    : "border-gray-200 hover:border-gray-300"
              }`}
            >
              <Home className={`w-7 h-7 mx-auto mb-2 ${bookingType === "home" && lab.homeCollection ? "text-blue-600" : "text-gray-400"}`} />
              <div className={`mb-0.5 ${lab.homeCollection ? "text-gray-900" : "text-gray-500"}`}>Home Collection</div>
              {lab.homeCollection
                ? <div className="text-gray-600 text-sm">We come to you (+EGP {HOME_COLLECTION_FEE})</div>
                : <div className="text-gray-500 text-xs">Not available at this lab</div>
              }
            </button>
            <button
              onClick={() => setBookingType("kit")}
              disabled={!lab.homeTestKit}
              className={`p-4 rounded-lg border-2 transition ${
                !lab.homeTestKit
                  ? "border-gray-100 bg-gray-50 cursor-not-allowed opacity-60"
                  : bookingType === "kit"
                    ? "border-blue-600 bg-blue-50"
                    : "border-gray-200 hover:border-gray-300"
              }`}
            >
              <Package className={`w-7 h-7 mx-auto mb-2 ${bookingType === "kit" && lab.homeTestKit ? "text-blue-600" : "text-gray-400"}`} />
              <div className={`mb-0.5 ${lab.homeTestKit ? "text-gray-900" : "text-gray-500"}`}>Home Test Kit</div>
              {lab.homeTestKit
                ? <div className="text-gray-600 text-sm">Kit shipped to you (+EGP {HOME_KIT_FEE})</div>
                : <div className="text-gray-500 text-xs">Not available at this lab</div>
              }
            </button>
          </div>
        </div>

        {bookingType !== "kit" && (
          <>
            <div className="bg-white rounded-xl shadow-sm p-5 mb-4 animate-slide-up animation-delay-200">
              <h3 className="text-base text-gray-900 mb-3">Select Date</h3>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                {dates.map((date) => (
                  <button
                    key={date.key}
                    onClick={() => setSelectedDate(date.key)}
                    className={`p-3 rounded-lg border-2 transition ${
                      effectiveSelectedDate === date.key ? "border-blue-600 bg-blue-50" : "border-gray-200 hover:border-gray-300"
                    }`}
                  >
                    <div className="text-gray-900 text-sm">{date.label}</div>
                  </button>
                ))}
                {dates.length === 0 && <p className="text-gray-600 col-span-4 text-sm">No available dates in the selected range.</p>}
              </div>
            </div>

            <div className="bg-white rounded-xl shadow-sm p-5 mb-4 animate-slide-up animation-delay-300">
              <h3 className="text-base text-gray-900 mb-3">Select Time Slot</h3>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                {timeSlotsForDate.map((slot) => (
                  <button
                    key={slot.id}
                    onClick={() => setSelectedSlotId(slot.id)}
                    className={`p-3 rounded-lg border-2 transition ${
                      selectedSlotId === slot.id ? "border-blue-600 bg-blue-50" : "border-gray-200 hover:border-gray-300"
                    }`}
                  >
                    <Clock className={`w-5 h-5 mx-auto mb-1.5 ${selectedSlotId === slot.id ? "text-blue-600" : "text-gray-400"}`} />
                    <div className="text-gray-900 text-sm">{formatTime(slot.startsAt)}</div>
                  </button>
                ))}
                {effectiveSelectedDate && timeSlotsForDate.length === 0 && (
                  <p className="text-gray-600 col-span-4 text-sm">No slots available for this date.</p>
                )}
              </div>
            </div>
          </>
        )}

        {bookingType === "kit" && (
          <div className="bg-blue-50 border border-blue-200 rounded-xl p-4 mb-4 flex items-start gap-3 animate-slide-up animation-delay-200">
            <Package className="w-5 h-5 text-blue-600 mt-0.5 shrink-0" />
            <div className="text-sm text-blue-900">
              <p className="font-medium mb-1">How it works</p>
              <p>The lab will ship a self-collection kit to your address within 2 business days. You collect the sample yourself and return it using the prepaid envelope included in the kit. Results are uploaded once the lab processes your sample.</p>
            </div>
          </div>
        )}

        <div className="bg-white rounded-xl shadow-sm p-5 mb-4 animate-slide-up animation-delay-300">
          <h3 className="text-base text-gray-900 mb-3">Payment</h3>
          <p className="text-sm text-gray-600 mb-3">
            This project uses a simulated payment gateway for online payments — no real charges are made.
          </p>
          <div className="space-y-3">
            <button
              type="button"
              onClick={() => setPaymentMethod("Online")}
              className={`w-full text-left p-4 rounded-lg border-2 transition ${
                effectivePaymentMethod === "Online" ? "border-blue-600 bg-blue-50" : "border-gray-200 hover:border-gray-300"
              }`}
            >
              <div className="text-gray-900 font-medium">Pay online (demo)</div>
              <div className="text-gray-600 text-sm">Simulated card payment — complete from your dashboard after booking.</div>
            </button>
            {bookingType === "home" && (
              <button
                type="button"
                onClick={() => setPaymentMethod("CashHomeCollection")}
                className={`w-full text-left p-4 rounded-lg border-2 transition ${
                  effectivePaymentMethod === "CashHomeCollection"
                    ? "border-blue-600 bg-blue-50"
                    : "border-gray-200 hover:border-gray-300"
                }`}
              >
                <div className="text-gray-900 font-medium">Cash on home sample collection</div>
                <div className="text-gray-600 text-sm">Pay the collector when the sample is taken.</div>
              </button>
            )}
            {bookingType === "lab" && (
              <button
                type="button"
                onClick={() => setPaymentMethod("CashLabVisit")}
                className={`w-full text-left p-4 rounded-lg border-2 transition ${
                  effectivePaymentMethod === "CashLabVisit" ? "border-blue-600 bg-blue-50" : "border-gray-200 hover:border-gray-300"
                }`}
              >
                <div className="text-gray-900 font-medium">Cash at lab visit</div>
                <div className="text-gray-600 text-sm">Pay at the reception desk when you attend.</div>
              </button>
            )}
            {bookingType === "kit" && (
              <button
                type="button"
                onClick={() => setPaymentMethod("CashOnDelivery")}
                className={`w-full text-left p-4 rounded-lg border-2 transition ${
                  effectivePaymentMethod === "CashOnDelivery" ? "border-blue-600 bg-blue-50" : "border-gray-200 hover:border-gray-300"
                }`}
              >
                <div className="text-gray-900 font-medium">Cash on delivery</div>
                <div className="text-gray-600 text-sm">Pay when the kit arrives at your door.</div>
              </button>
            )}
          </div>
        </div>

        {(bookingType === "home" || bookingType === "kit") && (
          <div className="bg-white rounded-xl shadow-sm p-5 mb-4 animate-slide-up animation-delay-400">
            <h3 className="text-base text-gray-900 mb-3">
              {bookingType === "kit" ? "Kit Delivery Address" : "Home Address"}
            </h3>
            <textarea
              value={homeAddress}
              onChange={(event) => setHomeAddress(event.target.value)}
              placeholder={
                bookingType === "kit"
                  ? "Enter your full delivery address for the kit"
                  : "Enter your complete address for sample collection"
              }
              className="w-full px-4 py-3 border border-gray-300 rounded-lg resize-none"
              rows={3}
            />
          </div>
        )}

        <div className="bg-white rounded-xl shadow-sm p-5 animate-slide-up animation-delay-400">
          <h3 className="text-base text-gray-900 mb-3">Booking Summary</h3>
          <div className="space-y-3 mb-4">
            <div className="flex justify-between">
              <span className="text-gray-600">Test Price</span>
              <span className="text-gray-900">EGP {basePrice}</span>
            </div>
            {bookingType === "home" && (
              <div className="flex justify-between">
                <span className="text-gray-600">Home Collection Fee</span>
                <span className="text-gray-900">EGP {HOME_COLLECTION_FEE}</span>
              </div>
            )}
            {bookingType === "kit" && (
              <div className="flex justify-between">
                <span className="text-gray-600">Kit & Shipping Fee</span>
                <span className="text-gray-900">EGP {HOME_KIT_FEE}</span>
              </div>
            )}
            <div className="border-t pt-3 flex justify-between">
              <span className="text-gray-900">Total Amount</span>
              <span className="text-2xl text-blue-600">
                EGP {basePrice + (bookingType === "home" ? HOME_COLLECTION_FEE : bookingType === "kit" ? HOME_KIT_FEE : 0)}
              </span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">Payment method</span>
              <span className="text-gray-900">
                {effectivePaymentMethod === "Online"
                  ? "Online (demo)"
                  : effectivePaymentMethod === "CashHomeCollection"
                    ? "Cash on collection"
                    : effectivePaymentMethod === "CashOnDelivery"
                      ? "Cash on delivery"
                      : "Cash at lab"}
              </span>
            </div>
          </div>
          <button
            onClick={handleBooking}
            disabled={(bookingType !== "kit" && !effectiveSelectedSlotId) || !!isSubmitting}
            className="w-full py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 active:scale-[0.99] transition-all disabled:bg-gray-300 disabled:cursor-not-allowed"
          >
            {isSubmitting ? "Confirming..." : bookingType === "kit" ? "Order Kit" : "Confirm Booking"}
          </button>
        </div>
      </div>
    </div>
  );
}
