import { useState, useEffect } from 'react';
import { ArrowLeft, Clock, Home, MapPin, CheckCircle } from 'lucide-react';
import type { PublicLabCard, PublicTestResponse } from '../../lib/publicApi';

interface BookingPageProps {
  lab: (PublicLabCard & { timeSlots?: string[]; price?: number }) | null;
  test?: PublicTestResponse | null;
  isLoading?: boolean;
  onBack: () => void;
  onComplete: () => void;
}

export function BookingPage({ lab, test, isLoading, onBack, onComplete }: BookingPageProps) {
  const [bookingType, setBookingType] = useState<'lab' | 'home'>('lab');
  const [selectedDate, setSelectedDate] = useState('2025-12-07');
  const [selectedTime, setSelectedTime] = useState('');
  const [homeAddress, setHomeAddress] = useState('');
  const [showConfirmation, setShowConfirmation] = useState(false);

  // Scroll to top when component mounts
  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  const testPrice = test?.priceEgp ?? null;

  const handleBooking = () => {
    setShowConfirmation(true);
    setTimeout(() => {
      onComplete();
    }, 2000);
  };

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <p>Loading booking…</p>
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

  const basePrice = testPrice ?? lab.startingFromEgp ?? lab.price ?? 0;

  if (showConfirmation) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="bg-white rounded-xl shadow-lg p-8 max-w-md text-center">
          <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <CheckCircle className="w-10 h-10 text-green-600" />
          </div>
          <h2 className="text-2xl text-gray-900 mb-2">Booking Confirmed!</h2>
          <p className="text-gray-600 mb-4">
            Your appointment has been successfully booked. You will receive a confirmation email shortly.
          </p>
          <div className="bg-blue-50 rounded-lg p-4 text-left">
            <div className="text-gray-900 mb-2">{lab.name}</div>
            <div className="text-gray-600">{selectedDate} at {selectedTime}</div>
            <div className="text-gray-600">
              {bookingType === 'home' ? 'Home Collection' : 'Lab Visit'}
            </div>
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
        {/* Lab Info Summary */}
        <div className="bg-white rounded-xl shadow-sm p-6 mb-6">
          <div className="flex items-start justify-between">
            <div>
              <h2 className="text-xl text-gray-900 mb-2">{lab.name}</h2>
              <div className="flex items-center gap-2 text-gray-600 mb-2">
                <MapPin className="w-4 h-4" />
                <span>{lab.address}</span>
              </div>
              <div className="text-gray-600">{test?.name || 'Complete Blood Count (CBC)'}</div>
            </div>
            <div className="text-right">
              <div className="text-3xl text-blue-600">EGP {basePrice}</div>
            </div>
          </div>
        </div>

        {/* Booking Type Selection */}
        <div className="bg-white rounded-xl shadow-sm p-6 mb-6">
          <h3 className="text-lg text-gray-900 mb-4">Choose Collection Type</h3>
          <div className="grid grid-cols-2 gap-4">
            <button
              onClick={() => setBookingType('lab')}
              className={`p-6 rounded-lg border-2 transition ${
                bookingType === 'lab'
                  ? 'border-blue-600 bg-blue-50'
                  : 'border-gray-200 hover:border-gray-300'
              }`}
            >
              <MapPin className={`w-8 h-8 mx-auto mb-3 ${bookingType === 'lab' ? 'text-blue-600' : 'text-gray-400'}`} />
              <div className="text-gray-900 mb-1">Visit Lab</div>
              <div className="text-gray-600">Come to our facility</div>
            </button>
            
            {lab.homeCollection && (
              <button
                onClick={() => setBookingType('home')}
                className={`p-6 rounded-lg border-2 transition ${
                  bookingType === 'home'
                    ? 'border-blue-600 bg-blue-50'
                    : 'border-gray-200 hover:border-gray-300'
                }`}
              >
                <Home className={`w-8 h-8 mx-auto mb-3 ${bookingType === 'home' ? 'text-blue-600' : 'text-gray-400'}`} />
                <div className="text-gray-900 mb-1">Home Collection</div>
                <div className="text-gray-600">We come to you (+EGP 100)</div>
              </button>
            )}
          </div>
        </div>

        {/* Date Selection */}
        <div className="bg-white rounded-xl shadow-sm p-6 mb-6">
          <h3 className="text-lg text-gray-900 mb-4">Select Date</h3>
          <div className="grid grid-cols-4 gap-3">
            {['Dec 7', 'Dec 8', 'Dec 9', 'Dec 10', 'Dec 11', 'Dec 12', 'Dec 13', 'Dec 14'].map((date, index) => (
              <button
                key={date}
                onClick={() => setSelectedDate(`2025-12-${7 + index}`)}
                className={`p-4 rounded-lg border-2 transition ${
                  selectedDate === `2025-12-${7 + index}`
                    ? 'border-blue-600 bg-blue-50'
                    : 'border-gray-200 hover:border-gray-300'
                }`}
              >
                <div className="text-gray-600">Sat</div>
                <div className="text-gray-900">{date}</div>
              </button>
            ))}
          </div>
        </div>

        {/* Time Slot Selection */}
        <div className="bg-white rounded-xl shadow-sm p-6 mb-6">
          <h3 className="text-lg text-gray-900 mb-4">Select Time Slot</h3>
          <div className="grid grid-cols-4 gap-3">
            {lab.timeSlots?.map((time: string) => (
              <button
                key={time}
                onClick={() => setSelectedTime(time)}
                className={`p-4 rounded-lg border-2 transition ${
                  selectedTime === time
                    ? 'border-blue-600 bg-blue-50'
                    : 'border-gray-200 hover:border-gray-300'
                }`}
              >
                <Clock className={`w-5 h-5 mx-auto mb-2 ${selectedTime === time ? 'text-blue-600' : 'text-gray-400'}`} />
                <div className="text-gray-900">{time}</div>
              </button>
            ))}
          </div>
        </div>

        {/* Home Address if home collection */}
        {bookingType === 'home' && (
          <div className="bg-white rounded-xl shadow-sm p-6 mb-6">
            <h3 className="text-lg text-gray-900 mb-4">Home Address</h3>
            <textarea
              value={homeAddress}
              onChange={(e) => setHomeAddress(e.target.value)}
              placeholder="Enter your complete address for sample collection"
              className="w-full px-4 py-3 border border-gray-300 rounded-lg resize-none"
              rows={3}
            />
          </div>
        )}

        {/* Summary and Confirm */}
        <div className="bg-white rounded-xl shadow-sm p-6">
          <h3 className="text-lg text-gray-900 mb-4">Booking Summary</h3>
          <div className="space-y-3 mb-6">
            <div className="flex justify-between">
              <span className="text-gray-600">Test Price</span>
              <span className="text-gray-900">EGP {basePrice}</span>
            </div>
            {bookingType === 'home' && (
              <div className="flex justify-between">
                <span className="text-gray-600">Home Collection Fee</span>
                <span className="text-gray-900">EGP 100</span>
              </div>
            )}
            <div className="border-t pt-3 flex justify-between">
              <span className="text-gray-900">Total Amount</span>
              <span className="text-2xl text-blue-600">
                EGP {basePrice + (bookingType === 'home' ? 100 : 0)}
              </span>
            </div>
          </div>
          <button
            onClick={handleBooking}
            disabled={!selectedTime}
            className="w-full py-4 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed"
          >
            Confirm Booking
          </button>
        </div>
      </div>
    </div>
  );
}
