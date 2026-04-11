"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { BookingPage } from "../../teslty/components/BookingPage";
import { ApiError } from "../../lib/api";
import {
  createBooking,
  fetchBookingAvailability,
  type BookingAvailabilitySlot,
  type PaymentMethod,
} from "../../lib/bookingsApi";
import {
  fetchPublicLabDetail,
  fetchPublicTest,
  type PublicLabCard,
  type PublicTestResponse,
} from "../../lib/publicApi";

export default function BookingClient() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const labId = searchParams.get("labId") ?? "";
  const testId = searchParams.get("testId") ?? "";

  const [lab, setLab] = useState<PublicLabCard | null>(null);
  const [test, setTest] = useState<PublicTestResponse | null>(null);
  const [slots, setSlots] = useState<BookingAvailabilitySlot[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const requestKey = `${labId}:${testId}`;

  useEffect(() => {
    let isMounted = true;

    if (!labId || !testId) {
      setErrorMessage("Missing lab or test selection.");
      return;
    }

    setIsLoading(true);
    setErrorMessage(null);

    Promise.all([
      fetchPublicLabDetail(labId),
      fetchPublicTest(testId),
      fetchBookingAvailability({ labId, testId, days: 7 }),
    ])
      .then(([labRes, testRes, availabilityRes]) => {
        if (!isMounted) return;
        setLab(labRes.lab);
        setTest(testRes);
        setSlots(availabilityRes.items);
      })
      .catch((error) => {
        if (!isMounted) return;
        if (error instanceof ApiError && error.status === 401) {
          router.push("/login");
          return;
        }
        setErrorMessage("Unable to load booking data. Please try again.");
        setLab(null);
        setTest(null);
        setSlots([]);
      })
      .finally(() => {
        if (!isMounted) return;
        setIsLoading(false);
      });

    return () => {
      isMounted = false;
    };
  }, [labId, requestKey, router, testId]);

  const onSubmit = async (payload: {
    slotId: string;
    bookingType: "LabVisit" | "HomeCollection";
    homeAddress?: string;
    paymentMethod: PaymentMethod;
  }) => {
    if (!labId || !testId) return;
    setIsSubmitting(true);
    setErrorMessage(null);

    try {
      await createBooking({
        labId,
        testId,
        slotId: payload.slotId,
        bookingType: payload.bookingType,
        homeAddress: payload.homeAddress,
        paymentMethod: payload.paymentMethod,
      });
    } catch (error) {
      if (error instanceof ApiError) {
        if (error.status === 401) {
          router.push("/login");
          throw error;
        }
        if (error.status === 409) {
          setErrorMessage("Selected slot is no longer available. Please pick another slot.");
          const refreshed = await fetchBookingAvailability({ labId, testId, days: 7 });
          setSlots(refreshed.items);
          throw error;
        }
      }
      setErrorMessage("Could not create booking. Please review your details and try again.");
      throw error;
    } finally {
      setIsSubmitting(false);
    }
  };

  const orderedSlots = useMemo(
    () => [...slots].sort((a, b) => new Date(a.startsAt).getTime() - new Date(b.startsAt).getTime()),
    [slots],
  );

  return (
    <BookingPage
      lab={lab}
      test={test}
      slots={orderedSlots}
      isLoading={isLoading}
      isSubmitting={isSubmitting}
      errorMessage={errorMessage}
      onBack={() => {
        if (labId) {
          router.push(`/labs/${labId}`);
          return;
        }
        router.push("/labs");
      }}
      onComplete={() => router.push("/patient/dashboard")}
      onSubmit={onSubmit}
    />
  );
}
