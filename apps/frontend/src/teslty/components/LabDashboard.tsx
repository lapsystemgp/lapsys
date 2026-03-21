import { useState } from 'react';
import { TestTube, Calendar, FileText, LogOut, BarChart3, Plus, Upload, CheckCircle, X, Edit2, Save, Trash2, Archive, MoreVertical, Clock } from 'lucide-react';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from './ui/dialog';
import { Label } from './ui/label';
import { Input } from './ui/input';

interface LabDashboardProps {
  onLogout: () => void;
}

interface Test {
  id: number;
  name: string;
  price: number;
  turnaround: string;
  active: boolean;
}

interface Booking {
  id: number;
  patientName: string;
  testName: string;
  date: string;
  time: string;
  type: string;
  status: 'Confirmed' | 'Pending' | 'Rejected';
  phone: string;
  address?: string;
  archived?: boolean;
}

export function LabDashboard({ onLogout }: LabDashboardProps) {
  const [activeTab, setActiveTab] = useState<'bookings' | 'tests' | 'results' | 'analytics' | 'schedule'>('bookings');
  const [tests, setTests] = useState<Test[]>([
    { id: 1, name: 'Complete Blood Count (CBC)', price: 450, turnaround: '24 hours', active: true },
    { id: 2, name: 'Lipid Profile', price: 650, turnaround: '24 hours', active: true },
    { id: 3, name: 'Thyroid Panel (TSH, T3, T4)', price: 580, turnaround: '48 hours', active: true },
    { id: 4, name: 'Liver Function Test (LFT)', price: 520, turnaround: '24 hours', active: true },
    { id: 5, name: 'Kidney Function Test', price: 490, turnaround: '24 hours', active: false }
  ]);
  
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
  const [editingTest, setEditingTest] = useState<Test | null>(null);
  const [newTest, setNewTest] = useState({ name: '', price: '', turnaround: '' });
  
  const [isConfirmDialogOpen, setIsConfirmDialogOpen] = useState(false);
  const [isRejectDialogOpen, setIsRejectDialogOpen] = useState(false);
  const [isEditBookingDialogOpen, setIsEditBookingDialogOpen] = useState(false);
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
  const [selectedBooking, setSelectedBooking] = useState<Booking | null>(null);
  const [editingBooking, setEditingBooking] = useState<Booking | null>(null);
  const [showArchivedBookings, setShowArchivedBookings] = useState(false);

  const [isEditHoursDialogOpen, setIsEditHoursDialogOpen] = useState(false);
  const [isAddSlotDialogOpen, setIsAddSlotDialogOpen] = useState(false);
  const [newTimeSlot, setNewTimeSlot] = useState('');
  const [operatingHours, setOperatingHours] = useState([
    { day: 'Monday', hours: '8:00 AM - 8:00 PM', status: 'Open' },
    { day: 'Tuesday', hours: '8:00 AM - 8:00 PM', status: 'Open' },
    { day: 'Wednesday', hours: '8:00 AM - 8:00 PM', status: 'Open' },
    { day: 'Thursday', hours: '8:00 AM - 8:00 PM', status: 'Open' },
    { day: 'Friday', hours: '8:00 AM - 8:00 PM', status: 'Open' },
    { day: 'Saturday', hours: '8:00 AM - 2:00 PM', status: 'Open' },
    { day: 'Sunday', hours: 'Closed', status: 'Closed' }
  ]);
  const [editingHours, setEditingHours] = useState(operatingHours);
  const [timeSlots, setTimeSlots] = useState({
    morning: ['8:00 AM', '8:30 AM', '9:00 AM', '9:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM'],
    afternoon: ['12:00 PM', '12:30 PM', '1:00 PM', '1:30 PM', '2:00 PM', '2:30 PM', '3:00 PM', '3:30 PM'],
    evening: ['4:00 PM', '4:30 PM', '5:00 PM', '5:30 PM', '6:00 PM', '6:30 PM', '7:00 PM', '7:30 PM']
  });

  const [bookings, setBookings] = useState<Booking[]>([
    {
      id: 1,
      patientName: 'Mazen Amir',
      testName: 'Complete Blood Count (CBC)',
      date: '2025-12-07',
      time: '9:00 AM',
      type: 'Lab Visit',
      status: 'Confirmed',
      phone: '+20 10 1234 5678'
    },
    {
      id: 2,
      patientName: 'Yehia',
      testName: 'Lipid Profile',
      date: '2025-12-07',
      time: '10:30 AM',
      type: 'Home Collection',
      address: '28 El Nozha Street, Apartment 3C, Heliopolis, Cairo',
      status: 'Pending',
      phone: '+20 11 2345 6789'
    },
    {
      id: 3,
      patientName: 'Eslam',
      testName: 'Thyroid Panel',
      date: '2025-12-07',
      time: '2:00 PM',
      type: 'Lab Visit',
      status: 'Pending',
      phone: '+20 12 3456 7890'
    }
  ]);

  const stats = {
    totalBookings: 156,
    completedTests: 142,
    pendingResults: 8,
    revenue: 68450
  };

  const handleEditClick = (test: Test) => {
    setEditingTest({ ...test });
    setIsEditDialogOpen(true);
  };

  const handleSaveEdit = () => {
    if (editingTest) {
      setTests(tests.map(t => t.id === editingTest.id ? editingTest : t));
      setIsEditDialogOpen(false);
      setEditingTest(null);
    }
  };

  const handleAddTest = () => {
    if (newTest.name && newTest.price && newTest.turnaround) {
      const test: Test = {
        id: Math.max(...tests.map(t => t.id)) + 1,
        name: newTest.name,
        price: parseFloat(newTest.price),
        turnaround: newTest.turnaround,
        active: true
      };
      setTests([...tests, test]);
      setIsAddDialogOpen(false);
      setNewTest({ name: '', price: '', turnaround: '' });
    }
  };

  const toggleTestStatus = (id: number) => {
    setTests(tests.map(t => t.id === id ? { ...t, active: !t.active } : t));
  };

  const handleConfirmBooking = () => {
    if (selectedBooking) {
      setBookings(bookings.map(b => b.id === selectedBooking.id ? { ...b, status: 'Confirmed' } : b));
      setIsConfirmDialogOpen(false);
      setSelectedBooking(null);
    }
  };

  const handleRejectBooking = () => {
    if (selectedBooking) {
      setBookings(bookings.map(b => b.id === selectedBooking.id ? { ...b, status: 'Rejected' } : b));
      setIsRejectDialogOpen(false);
      setSelectedBooking(null);
    }
  };

  const handleEditBookingClick = (booking: Booking) => {
    setEditingBooking({ ...booking });
    setIsEditBookingDialogOpen(true);
  };

  const handleSaveEditBooking = () => {
    if (editingBooking) {
      setBookings(bookings.map(b => b.id === editingBooking.id ? editingBooking : b));
      setIsEditBookingDialogOpen(false);
      setEditingBooking(null);
    }
  };

  const handleDeleteBooking = () => {
    if (selectedBooking) {
      setBookings(bookings.filter(b => b.id !== selectedBooking.id));
      setIsDeleteDialogOpen(false);
      setSelectedBooking(null);
    }
  };

  const handleArchiveBooking = () => {
    if (selectedBooking) {
      setBookings(bookings.map(b => b.id === selectedBooking.id ? { ...b, archived: true } : b));
      setIsDeleteDialogOpen(false);
      setSelectedBooking(null);
    }
  };

  const handleUnarchiveBooking = (bookingId: number) => {
    setBookings(bookings.map(b => b.id === bookingId ? { ...b, archived: false } : b));
  };

  const handleEditHours = () => {
    setEditingHours([...operatingHours]);
    setIsEditHoursDialogOpen(true);
  };

  const handleSaveHours = () => {
    setOperatingHours(editingHours);
    setIsEditHoursDialogOpen(false);
  };

  const handleAddTimeSlot = () => {
    if (!newTimeSlot.trim()) return;
    
    // Determine which category the slot belongs to based on time
    const hour = parseInt(newTimeSlot.split(':')[0]);
    const isPM = newTimeSlot.includes('PM');
    const actualHour = isPM && hour !== 12 ? hour + 12 : !isPM && hour === 12 ? 0 : hour;
    
    let category: 'morning' | 'afternoon' | 'evening' = 'morning';
    if (actualHour >= 12 && actualHour < 16) {
      category = 'afternoon';
    } else if (actualHour >= 16) {
      category = 'evening';
    }
    
    setTimeSlots({
      ...timeSlots,
      [category]: [...timeSlots[category], newTimeSlot].sort()
    });
    setNewTimeSlot('');
    setIsAddSlotDialogOpen(false);
  };

  const handleRemoveTimeSlot = (slot: string, category: 'morning' | 'afternoon' | 'evening') => {
    setTimeSlots({
      ...timeSlots,
      [category]: timeSlots[category].filter(s => s !== slot)
    });
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <TestTube className="w-8 h-8 text-blue-600" />
            <div>
              <div className="text-xl text-blue-600">Alaf labs</div>
              <div className="text-gray-600">Lab Dashboard</div>
            </div>
          </div>
          <button
            onClick={onLogout}
            className="flex items-center gap-2 px-4 py-2 text-gray-600 hover:text-gray-900"
          >
            <LogOut className="w-5 h-5" />
            Logout
          </button>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Stats Overview */}
        <div className="grid grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-xl shadow-sm p-6">
            <div className="text-gray-600 mb-2">Total Bookings</div>
            <div className="text-3xl text-gray-900">{stats.totalBookings}</div>
            <div className="text-green-600 mt-2">+12% this month</div>
          </div>
          <div className="bg-white rounded-xl shadow-sm p-6">
            <div className="text-gray-600 mb-2">Completed Tests</div>
            <div className="text-3xl text-gray-900">{stats.completedTests}</div>
            <div className="text-blue-600 mt-2">91% completion rate</div>
          </div>
          <div className="bg-white rounded-xl shadow-sm p-6">
            <div className="text-gray-600 mb-2">Pending Results</div>
            <div className="text-3xl text-gray-900">{stats.pendingResults}</div>
            <div className="text-orange-600 mt-2">Upload required</div>
          </div>
          <div className="bg-white rounded-xl shadow-sm p-6">
            <div className="text-gray-600 mb-2">Total Revenue</div>
            <div className="text-3xl text-gray-900">EGP {stats.revenue.toLocaleString()}</div>
            <div className="text-green-600 mt-2">+18% this month</div>
          </div>
        </div>

        {/* Tabs */}
        <div className="bg-white rounded-xl shadow-sm">
          <div className="border-b border-gray-200">
            <nav className="flex gap-8 px-6">
              <button
                onClick={() => setActiveTab('bookings')}
                className={`py-4 border-b-2 transition ${
                  activeTab === 'bookings'
                    ? 'border-blue-600 text-blue-600'
                    : 'border-transparent text-gray-600 hover:text-gray-900'
                }`}
              >
                <div className="flex items-center gap-2">
                  <Calendar className="w-5 h-5" />
                  Bookings
                </div>
              </button>
              <button
                onClick={() => setActiveTab('tests')}
                className={`py-4 border-b-2 transition ${
                  activeTab === 'tests'
                    ? 'border-blue-600 text-blue-600'
                    : 'border-transparent text-gray-600 hover:text-gray-900'
                }`}
              >
                <div className="flex items-center gap-2">
                  <TestTube className="w-5 h-5" />
                  Test Catalog
                </div>
              </button>
              <button
                onClick={() => setActiveTab('results')}
                className={`py-4 border-b-2 transition ${
                  activeTab === 'results'
                    ? 'border-blue-600 text-blue-600'
                    : 'border-transparent text-gray-600 hover:text-gray-900'
                }`}
              >
                <div className="flex items-center gap-2">
                  <FileText className="w-5 h-5" />
                  Upload Results
                </div>
              </button>
              <button
                onClick={() => setActiveTab('analytics')}
                className={`py-4 border-b-2 transition ${
                  activeTab === 'analytics'
                    ? 'border-blue-600 text-blue-600'
                    : 'border-transparent text-gray-600 hover:text-gray-900'
                }`}
              >
                <div className="flex items-center gap-2">
                  <BarChart3 className="w-5 h-5" />
                  Analytics
                </div>
              </button>
              <button
                onClick={() => setActiveTab('schedule')}
                className={`py-4 border-b-2 transition ${
                  activeTab === 'schedule'
                    ? 'border-blue-600 text-blue-600'
                    : 'border-transparent text-gray-600 hover:text-gray-900'
                }`}
              >
                <div className="flex items-center gap-2">
                  <Clock className="w-5 h-5" />
                  Schedule
                </div>
              </button>
            </nav>
          </div>

          {/* Tab Content */}
          <div className="p-6">
            {activeTab === 'bookings' && (
              <div className="space-y-4">
                {bookings.filter(b => !b.archived).map((booking) => (
                  <div key={booking.id} className="border border-gray-200 rounded-lg p-6">
                    <div className="flex items-start justify-between mb-4">
                      <div>
                        <h3 className="text-lg text-gray-900 mb-1">{booking.patientName}</h3>
                        <p className="text-gray-600">{booking.testName}</p>
                        <p className="text-gray-500">{booking.phone}</p>
                      </div>
                      <span
                        className={`px-3 py-1 rounded-full ${
                          booking.status === 'Confirmed'
                            ? 'bg-green-100 text-green-700'
                            : booking.status === 'Rejected'
                            ? 'bg-red-100 text-red-700'
                            : 'bg-yellow-100 text-yellow-700'
                        }`}
                      >
                        {booking.status}
                      </span>
                    </div>
                    <div className="grid grid-cols-3 gap-4 mb-4 text-gray-600">
                      <div>
                        <div className="text-gray-500 mb-1">Date & Time</div>
                        <div>{booking.date} at {booking.time}</div>
                      </div>
                      <div>
                        <div className="text-gray-500 mb-1">Type</div>
                        <div>{booking.type}</div>
                      </div>
                      {booking.address && (
                        <div>
                          <div className="text-gray-500 mb-1">Address</div>
                          <div>{booking.address}</div>
                        </div>
                      )}
                    </div>
                    {booking.status === 'Pending' && (
                      <div className="flex gap-3">
                        <button
                          onClick={() => {
                            setSelectedBooking(booking);
                            setIsConfirmDialogOpen(true);
                          }}
                          className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
                        >
                          <CheckCircle className="w-4 h-4" />
                          Confirm
                        </button>
                        <button
                          onClick={() => {
                            setSelectedBooking(booking);
                            setIsRejectDialogOpen(true);
                          }}
                          className="flex items-center gap-2 px-4 py-2 border border-red-300 text-red-600 rounded-lg hover:bg-red-50"
                        >
                          <X className="w-4 h-4" />
                          Reject
                        </button>
                      </div>
                    )}
                    {(booking.status === 'Confirmed' || booking.status === 'Rejected') && (
                      <div className="flex gap-3">
                        <button
                          onClick={() => {
                            setEditingBooking({ ...booking });
                            setIsEditBookingDialogOpen(true);
                          }}
                          className="flex items-center gap-2 px-4 py-2 border border-gray-300 text-gray-600 rounded-lg hover:bg-gray-50"
                        >
                          <Edit2 className="w-4 h-4" />
                          Edit Status
                        </button>
                        <button
                          onClick={() => {
                            setBookings(bookings.map(b => b.id === booking.id ? { ...b, archived: true } : b));
                          }}
                          className="flex items-center gap-2 px-4 py-2 border border-gray-300 text-gray-600 rounded-lg hover:bg-gray-50"
                        >
                          <Archive className="w-4 h-4" />
                          Archive
                        </button>
                        <button
                          onClick={() => {
                            setSelectedBooking(booking);
                            setIsDeleteDialogOpen(true);
                          }}
                          className="flex items-center gap-2 px-4 py-2 border border-red-300 text-red-600 rounded-lg hover:bg-red-50"
                        >
                          <Trash2 className="w-4 h-4" />
                          Delete
                        </button>
                      </div>
                    )}
                  </div>
                ))}
                <div className="mt-4">
                  <button
                    onClick={() => setShowArchivedBookings(!showArchivedBookings)}
                    className="flex items-center gap-2 px-4 py-2 border border-gray-300 text-gray-600 rounded-lg hover:bg-gray-50"
                  >
                    <Archive className="w-4 h-4" />
                    {showArchivedBookings ? 'Hide' : 'Show'} Archived Bookings
                  </button>
                </div>
                {showArchivedBookings && (
                  <div className="space-y-4 mt-4">
                    {bookings.filter(b => b.archived).map((booking) => (
                      <div key={booking.id} className="border border-gray-200 rounded-lg p-6">
                        <div className="flex items-start justify-between mb-4">
                          <div>
                            <h3 className="text-lg text-gray-900 mb-1">{booking.patientName}</h3>
                            <p className="text-gray-600">{booking.testName}</p>
                            <p className="text-gray-500">{booking.phone}</p>
                          </div>
                          <span
                            className={`px-3 py-1 rounded-full ${
                              booking.status === 'Confirmed'
                                ? 'bg-green-100 text-green-700'
                                : booking.status === 'Rejected'
                                ? 'bg-red-100 text-red-700'
                                : 'bg-yellow-100 text-yellow-700'
                            }`}
                          >
                            {booking.status}
                          </span>
                        </div>
                        <div className="grid grid-cols-3 gap-4 mb-4 text-gray-600">
                          <div>
                            <div className="text-gray-500 mb-1">Date & Time</div>
                            <div>{booking.date} at {booking.time}</div>
                          </div>
                          <div>
                            <div className="text-gray-500 mb-1">Type</div>
                            <div>{booking.type}</div>
                          </div>
                          {booking.address && (
                            <div>
                              <div className="text-gray-500 mb-1">Address</div>
                              <div>{booking.address}</div>
                            </div>
                          )}
                        </div>
                        <div className="flex gap-3">
                          <button
                            onClick={() => handleUnarchiveBooking(booking.id)}
                            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                          >
                            <Archive className="w-4 h-4" />
                            Unarchive
                          </button>
                          <button
                            onClick={() => {
                              setSelectedBooking(booking);
                              setIsDeleteDialogOpen(true);
                            }}
                            className="flex items-center gap-2 px-4 py-2 border border-red-300 text-red-600 rounded-lg hover:bg-red-50"
                          >
                            <Trash2 className="w-4 h-4" />
                            Delete
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}

            {activeTab === 'tests' && (
              <div>
                <div className="flex justify-between items-center mb-6">
                  <h3 className="text-xl text-gray-900">Test Catalog</h3>
                  <button 
                    onClick={() => setIsAddDialogOpen(true)}
                    className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                  >
                    <Plus className="w-4 h-4" />
                    Add New Test
                  </button>
                </div>
                <div className="space-y-3">
                  {tests.map((test) => (
                    <div key={test.id} className="border border-gray-200 rounded-lg p-4 flex items-center justify-between">
                      <div>
                        <h4 className="text-gray-900 mb-1">{test.name}</h4>
                        <div className="flex gap-6 text-gray-600">
                          <span>Price: EGP {test.price}</span>
                          <span>Turnaround: {test.turnaround}</span>
                        </div>
                      </div>
                      <div className="flex items-center gap-4">
                        <label className="relative inline-flex items-center cursor-pointer">
                          <input 
                            type="checkbox" 
                            checked={test.active} 
                            onChange={() => toggleTestStatus(test.id)}
                            className="sr-only peer" 
                          />
                          <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                        </label>
                        <span className={test.active ? 'text-green-600' : 'text-gray-500'}>
                          {test.active ? 'Active' : 'Inactive'}
                        </span>
                        <button
                          onClick={() => handleEditClick(test)}
                          className="p-2 hover:bg-gray-100 rounded-lg"
                        >
                          <Edit2 className="w-4 h-4 text-gray-600" />
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {activeTab === 'results' && (
              <div>
                <h3 className="text-xl text-gray-900 mb-6">Upload Test Results</h3>
                <div className="space-y-4">
                  {bookings.filter(b => b.status === 'Confirmed').map((booking) => (
                    <div key={booking.id} className="border border-gray-200 rounded-lg p-6 flex items-center justify-between">
                      <div>
                        <h4 className="text-gray-900 mb-1">{booking.patientName}</h4>
                        <div className="text-gray-600">{booking.testName}</div>
                        <div className="text-gray-500">{booking.date} at {booking.time}</div>
                      </div>
                      <button className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
                        <Upload className="w-4 h-4" />
                        Upload Results
                      </button>
                    </div>
                  ))}
                  {bookings.filter(b => b.status === 'Confirmed').length === 0 && (
                    <div className="text-center py-12 text-gray-500">
                      No confirmed bookings to upload results for
                    </div>
                  )}
                </div>
              </div>
            )}

            {activeTab === 'analytics' && (
              <div>
                <h3 className="text-xl text-gray-900 mb-6">Analytics Overview</h3>
                <div className="grid grid-cols-2 gap-6">
                  <div className="border border-gray-200 rounded-lg p-6">
                    <h4 className="text-gray-900 mb-4">Popular Tests</h4>
                    <div className="space-y-3">
                      {tests.slice(0, 4).map((test, index) => (
                        <div key={test.id} className="flex items-center justify-between">
                          <span className="text-gray-600">{test.name}</span>
                          <span className="text-blue-600">{45 - index * 8} bookings</span>
                        </div>
                      ))}
                    </div>
                  </div>
                  <div className="border border-gray-200 rounded-lg p-6">
                    <h4 className="text-gray-900 mb-4">Monthly Revenue</h4>
                    <div className="text-3xl text-blue-600 mb-2">EGP 68,450</div>
                    <div className="text-green-600">+18% from last month</div>
                  </div>
                  <div className="border border-gray-200 rounded-lg p-6">
                    <h4 className="text-gray-900 mb-4">Customer Satisfaction</h4>
                    <div className="text-3xl text-blue-600 mb-2">4.7/5</div>
                    <div className="text-gray-600">Average rating</div>
                  </div>
                  <div className="border border-gray-200 rounded-lg p-6">
                    <h4 className="text-gray-900 mb-4">Completion Rate</h4>
                    <div className="text-3xl text-blue-600 mb-2">91%</div>
                    <div className="text-gray-600">Tests completed on time</div>
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'schedule' && (
              <div>
                <div className="flex items-center justify-between mb-6">
                  <h3 className="text-xl text-gray-900">Schedule Management</h3>
                  <div className="flex items-center gap-3">
                    <button
                      onClick={() => setIsEditHoursDialogOpen(true)}
                      className="flex items-center gap-2 px-4 py-2 border border-gray-300 text-gray-600 rounded-lg hover:bg-gray-50"
                    >
                      <Edit2 className="w-4 h-4" />
                      Edit Hours
                    </button>
                    <button
                      onClick={() => setIsAddSlotDialogOpen(true)}
                      className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                    >
                      <Plus className="w-4 h-4" />
                      Add Time Slot
                    </button>
                  </div>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
                  {/* Operating Hours */}
                  <div className="border border-gray-200 rounded-lg p-6">
                    <h4 className="text-gray-900 mb-4">Operating Hours</h4>
                    <div className="space-y-3">
                      {operatingHours.map((schedule, index) => (
                        <div key={index} className="flex items-center justify-between">
                          <div>
                            <div className="text-gray-900">{schedule.day}</div>
                            <div className="text-gray-600">{schedule.hours}</div>
                          </div>
                          <span className={`px-2 py-1 rounded-full text-xs ${schedule.status === 'Open' ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-600'}`}>
                            {schedule.status}
                          </span>
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Time Slots */}
                  <div className="border border-gray-200 rounded-lg p-6">
                    <h4 className="text-gray-900 mb-4">Available Time Slots</h4>
                    <div className="space-y-4">
                      {Object.entries(timeSlots).map(([category, slots]) => (
                        <div key={category}>
                          <div className="text-gray-600 mb-2 capitalize">{category}</div>
                          <div className="flex flex-wrap gap-2">
                            {slots.map((slot) => (
                              <div key={slot} className="flex items-center gap-1 px-3 py-1 bg-blue-50 text-blue-700 rounded-lg">
                                {slot}
                                <button
                                  onClick={() => handleRemoveTimeSlot(slot, category as 'morning' | 'afternoon' | 'evening')}
                                  className="text-blue-700 hover:text-blue-900"
                                >
                                  <X className="w-3 h-3" />
                                </button>
                              </div>
                            ))}
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>

                {/* Weekly Schedule */}
                <div className="border border-gray-200 rounded-lg p-6">
                  <h4 className="text-gray-900 mb-4">Weekly Schedule Overview</h4>
                  <div className="grid grid-cols-7 gap-4">
                    {['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) => (
                      <div key={day} className="text-center">
                        <div className="text-gray-600 mb-2">{day}</div>
                        <div className="bg-blue-50 rounded-lg p-4">
                          <div className="text-blue-600">8 slots</div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Current Appointments */}
                <div className="border border-gray-200 rounded-lg p-6 mt-6">
                  <h4 className="text-gray-900 mb-4">Today's Appointments</h4>
                  <div className="space-y-3">
                    {bookings
                      .filter(b => b.date === '2025-12-07' && b.status === 'Confirmed')
                      .map((booking) => (
                        <div key={booking.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                          <div>
                            <div className="text-gray-900">{booking.patientName}</div>
                            <div className="text-gray-600">{booking.testName}</div>
                          </div>
                          <div className="text-right">
                            <div className="text-gray-900">{booking.date}</div>
                            <div className="text-gray-600">{booking.time}</div>
                          </div>
                        </div>
                      ))}
                    {bookings.filter(b => b.status === 'Confirmed').length === 0 && (
                      <div className="text-center py-8 text-gray-500">
                        No upcoming appointments
                      </div>
                    )}
                  </div>
                </div>

                {/* Capacity Management */}
                <div className="border border-gray-200 rounded-lg p-6 lg:col-span-2">
                  <h4 className="text-gray-900 mb-4">Daily Capacity Management</h4>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div className="p-4 bg-blue-50 rounded-lg">
                      <div className="text-gray-600 mb-1">Maximum Daily Capacity</div>
                      <div className="text-2xl text-blue-600 mb-2">50 tests</div>
                      <div className="flex items-center gap-2">
                        <button className="text-blue-600 hover:text-blue-700">
                          <Edit2 className="w-4 h-4" />
                        </button>
                        <span className="text-gray-500">Edit capacity</span>
                      </div>
                    </div>
                    <div className="p-4 bg-green-50 rounded-lg">
                      <div className="text-gray-600 mb-1">Tests Scheduled Today</div>
                      <div className="text-2xl text-green-600 mb-2">
                        {bookings.filter(b => b.date === '2025-12-07' && b.status === 'Confirmed').length} tests
                      </div>
                      <div className="text-gray-500">
                        {Math.round((bookings.filter(b => b.date === '2025-12-07' && b.status === 'Confirmed').length / 50) * 100)}% capacity used
                      </div>
                    </div>
                    <div className="p-4 bg-orange-50 rounded-lg">
                      <div className="text-gray-600 mb-1">Available Slots Today</div>
                      <div className="text-2xl text-orange-600 mb-2">
                        {50 - bookings.filter(b => b.date === '2025-12-07' && b.status === 'Confirmed').length} slots
                      </div>
                      <div className="text-gray-500">
                        Ready for new bookings
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Edit Test Dialog */}
      <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit Test</DialogTitle>
            <DialogDescription>
              Update the price and turnaround time for this test.
            </DialogDescription>
          </DialogHeader>
          {editingTest && (
            <div className="space-y-4 py-4">
              <div>
                <Label htmlFor="edit-name">Test Name</Label>
                <Input
                  id="edit-name"
                  value={editingTest.name}
                  disabled
                  className="mt-1 bg-gray-50"
                />
              </div>
              <div>
                <Label htmlFor="edit-price">Price (EGP)</Label>
                <Input
                  id="edit-price"
                  type="number"
                  value={editingTest.price}
                  onChange={(e) => setEditingTest({ ...editingTest, price: parseFloat(e.target.value) || 0 })}
                  className="mt-1"
                  placeholder="Enter price"
                />
              </div>
              <div>
                <Label htmlFor="edit-turnaround">Turnaround Time</Label>
                <Input
                  id="edit-turnaround"
                  value={editingTest.turnaround}
                  onChange={(e) => setEditingTest({ ...editingTest, turnaround: e.target.value })}
                  className="mt-1"
                  placeholder="e.g., 24 hours, 2-3 days"
                />
              </div>
            </div>
          )}
          <DialogFooter>
            <button
              onClick={() => setIsEditDialogOpen(false)}
              className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              onClick={handleSaveEdit}
              className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
            >
              <Save className="w-4 h-4" />
              Save Changes
            </button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Add Test Dialog */}
      <Dialog open={isAddDialogOpen} onOpenChange={setIsAddDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Add New Test</DialogTitle>
            <DialogDescription>
              Add a new test to your catalog with pricing and turnaround time.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div>
              <Label htmlFor="add-name">Test Name</Label>
              <Input
                id="add-name"
                value={newTest.name}
                onChange={(e) => setNewTest({ ...newTest, name: e.target.value })}
                className="mt-1"
                placeholder="e.g., Complete Blood Count (CBC)"
              />
            </div>
            <div>
              <Label htmlFor="add-price">Price (EGP)</Label>
              <Input
                id="add-price"
                type="number"
                value={newTest.price}
                onChange={(e) => setNewTest({ ...newTest, price: e.target.value })}
                className="mt-1"
                placeholder="Enter price"
              />
            </div>
            <div>
              <Label htmlFor="add-turnaround">Turnaround Time</Label>
              <Input
                id="add-turnaround"
                value={newTest.turnaround}
                onChange={(e) => setNewTest({ ...newTest, turnaround: e.target.value })}
                className="mt-1"
                placeholder="e.g., 24 hours, 2-3 days"
              />
            </div>
          </div>
          <DialogFooter>
            <button
              onClick={() => {
                setIsAddDialogOpen(false);
                setNewTest({ name: '', price: '', turnaround: '' });
              }}
              className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              onClick={handleAddTest}
              disabled={!newTest.name || !newTest.price || !newTest.turnaround}
              className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <Plus className="w-4 h-4" />
              Add Test
            </button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Confirm Booking Dialog */}
      <Dialog open={isConfirmDialogOpen} onOpenChange={setIsConfirmDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Confirm Booking</DialogTitle>
            <DialogDescription>
              Are you sure you want to confirm this booking?
            </DialogDescription>
          </DialogHeader>
          {selectedBooking && (
            <div className="space-y-4 py-4">
              <div>
                <Label htmlFor="confirm-name">Patient Name</Label>
                <Input
                  id="confirm-name"
                  value={selectedBooking.patientName}
                  disabled
                  className="mt-1 bg-gray-50"
                />
              </div>
              <div>
                <Label htmlFor="confirm-test">Test Name</Label>
                <Input
                  id="confirm-test"
                  value={selectedBooking.testName}
                  disabled
                  className="mt-1 bg-gray-50"
                />
              </div>
              <div>
                <Label htmlFor="confirm-date">Date & Time</Label>
                <Input
                  id="confirm-date"
                  value={`${selectedBooking.date} at ${selectedBooking.time}`}
                  disabled
                  className="mt-1 bg-gray-50"
                />
              </div>
              <div>
                <Label htmlFor="confirm-type">Type</Label>
                <Input
                  id="confirm-type"
                  value={selectedBooking.type}
                  disabled
                  className="mt-1 bg-gray-50"
                />
              </div>
              {selectedBooking.address && (
                <div>
                  <Label htmlFor="confirm-address">Address</Label>
                  <Input
                    id="confirm-address"
                    value={selectedBooking.address}
                    disabled
                    className="mt-1 bg-gray-50"
                  />
                </div>
              )}
            </div>
          )}
          <DialogFooter>
            <button
              onClick={() => setIsConfirmDialogOpen(false)}
              className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              onClick={handleConfirmBooking}
              className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
            >
              <CheckCircle className="w-4 h-4" />
              Confirm
            </button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Reject Booking Dialog */}
      <Dialog open={isRejectDialogOpen} onOpenChange={setIsRejectDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Reject Booking</DialogTitle>
            <DialogDescription>
              Are you sure you want to reject this booking?
            </DialogDescription>
          </DialogHeader>
          {selectedBooking && (
            <div className="space-y-4 py-4">
              <div>
                <Label htmlFor="reject-name">Patient Name</Label>
                <Input
                  id="reject-name"
                  value={selectedBooking.patientName}
                  disabled
                  className="mt-1 bg-gray-50"
                />
              </div>
              <div>
                <Label htmlFor="reject-test">Test Name</Label>
                <Input
                  id="reject-test"
                  value={selectedBooking.testName}
                  disabled
                  className="mt-1 bg-gray-50"
                />
              </div>
              <div>
                <Label htmlFor="reject-date">Date & Time</Label>
                <Input
                  id="reject-date"
                  value={`${selectedBooking.date} at ${selectedBooking.time}`}
                  disabled
                  className="mt-1 bg-gray-50"
                />
              </div>
              <div>
                <Label htmlFor="reject-type">Type</Label>
                <Input
                  id="reject-type"
                  value={selectedBooking.type}
                  disabled
                  className="mt-1 bg-gray-50"
                />
              </div>
              {selectedBooking.address && (
                <div>
                  <Label htmlFor="reject-address">Address</Label>
                  <Input
                    id="reject-address"
                    value={selectedBooking.address}
                    disabled
                    className="mt-1 bg-gray-50"
                  />
                </div>
              )}
            </div>
          )}
          <DialogFooter>
            <button
              onClick={() => setIsRejectDialogOpen(false)}
              className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              onClick={handleRejectBooking}
              className="flex items-center gap-2 px-4 py-2 border border-red-300 text-red-600 rounded-lg hover:bg-red-50"
            >
              <X className="w-4 h-4" />
              Reject
            </button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Edit Booking Dialog */}
      <Dialog open={isEditBookingDialogOpen} onOpenChange={setIsEditBookingDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit Booking Status</DialogTitle>
            <DialogDescription>
              Update the status of this booking to Confirmed or Rejected.
            </DialogDescription>
          </DialogHeader>
          {editingBooking && (
            <div className="space-y-4 py-4">
              <div>
                <Label htmlFor="edit-booking-name">Patient Name</Label>
                <Input
                  id="edit-booking-name"
                  value={editingBooking.patientName}
                  disabled
                  className="mt-1 bg-gray-50"
                />
              </div>
              <div>
                <Label htmlFor="edit-booking-test">Test Name</Label>
                <Input
                  id="edit-booking-test"
                  value={editingBooking.testName}
                  disabled
                  className="mt-1 bg-gray-50"
                />
              </div>
              <div>
                <Label htmlFor="edit-booking-date">Date & Time</Label>
                <Input
                  id="edit-booking-date"
                  value={`${editingBooking.date} at ${editingBooking.time}`}
                  disabled
                  className="mt-1 bg-gray-50"
                />
              </div>
              <div>
                <Label htmlFor="edit-booking-type">Type</Label>
                <Input
                  id="edit-booking-type"
                  value={editingBooking.type}
                  disabled
                  className="mt-1 bg-gray-50"
                />
              </div>
              {editingBooking.address && (
                <div>
                  <Label htmlFor="edit-booking-address">Address</Label>
                  <Input
                    id="edit-booking-address"
                    value={editingBooking.address}
                    disabled
                    className="mt-1 bg-gray-50"
                  />
                </div>
              )}
              <div>
                <Label htmlFor="edit-booking-status">Status</Label>
                <select
                  id="edit-booking-status"
                  value={editingBooking.status}
                  onChange={(e) => setEditingBooking({ ...editingBooking, status: e.target.value as 'Confirmed' | 'Pending' | 'Rejected' })}
                  className="mt-1 w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value="Pending">Pending</option>
                  <option value="Confirmed">Confirmed</option>
                  <option value="Rejected">Rejected</option>
                </select>
              </div>
            </div>
          )}
          <DialogFooter>
            <button
              onClick={() => setIsEditBookingDialogOpen(false)}
              className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              onClick={handleSaveEditBooking}
              className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
            >
              <Save className="w-4 h-4" />
              Save Changes
            </button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete Booking Dialog */}
      <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Delete Booking</DialogTitle>
            <DialogDescription>
              Are you sure you want to delete this booking?
            </DialogDescription>
          </DialogHeader>
          {selectedBooking && (
            <div className="space-y-4 py-4">
              <div>
                <Label htmlFor="delete-name">Patient Name</Label>
                <Input
                  id="delete-name"
                  value={selectedBooking.patientName}
                  disabled
                  className="mt-1 bg-gray-50"
                />
              </div>
              <div>
                <Label htmlFor="delete-test">Test Name</Label>
                <Input
                  id="delete-test"
                  value={selectedBooking.testName}
                  disabled
                  className="mt-1 bg-gray-50"
                />
              </div>
              <div>
                <Label htmlFor="delete-date">Date & Time</Label>
                <Input
                  id="delete-date"
                  value={`${selectedBooking.date} at ${selectedBooking.time}`}
                  disabled
                  className="mt-1 bg-gray-50"
                />
              </div>
              <div>
                <Label htmlFor="delete-type">Type</Label>
                <Input
                  id="delete-type"
                  value={selectedBooking.type}
                  disabled
                  className="mt-1 bg-gray-50"
                />
              </div>
              {selectedBooking.address && (
                <div>
                  <Label htmlFor="delete-address">Address</Label>
                  <Input
                    id="delete-address"
                    value={selectedBooking.address}
                    disabled
                    className="mt-1 bg-gray-50"
                  />
                </div>
              )}
            </div>
          )}
          <DialogFooter>
            <button
              onClick={() => setIsDeleteDialogOpen(false)}
              className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              onClick={handleDeleteBooking}
              className="flex items-center gap-2 px-4 py-2 border border-red-300 text-red-600 rounded-lg hover:bg-red-50"
            >
              <Trash2 className="w-4 h-4" />
              Delete
            </button>
            <button
              onClick={handleArchiveBooking}
              className="flex items-center gap-2 px-4 py-2 border border-gray-300 text-gray-600 rounded-lg hover:bg-gray-50"
            >
              <Archive className="w-4 h-4" />
              Archive
            </button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Edit Hours Dialog */}
      <Dialog open={isEditHoursDialogOpen} onOpenChange={setIsEditHoursDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit Operating Hours</DialogTitle>
            <DialogDescription>
              Update the operating hours for each day.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            {editingHours.map((schedule, index) => (
              <div key={index} className="flex items-center justify-between">
                <div>
                  <span className="text-gray-900">{schedule.day}</span>
                </div>
                <div className="flex items-center gap-3">
                  <input
                    type="text"
                    value={schedule.hours}
                    onChange={(e) => setEditingHours(editingHours.map((h, i) => i === index ? { ...h, hours: e.target.value } : h))}
                    className="px-3 py-1.5 bg-gray-50 text-gray-700 rounded-lg"
                  />
                  <span className={`px-2 py-1 rounded-full text-xs ${schedule.status === 'Open' ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-600'}`}>
                    {schedule.status}
                  </span>
                </div>
              </div>
            ))}
          </div>
          <DialogFooter>
            <button
              onClick={() => setIsEditHoursDialogOpen(false)}
              className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              onClick={handleSaveHours}
              className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
            >
              <Save className="w-4 h-4" />
              Save Changes
            </button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Add Time Slot Dialog */}
      <Dialog open={isAddSlotDialogOpen} onOpenChange={setIsAddSlotDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Add Time Slot</DialogTitle>
            <DialogDescription>
              Add a new time slot for available appointments.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div>
              <Label htmlFor="add-slot">Time Slot</Label>
              <Input
                id="add-slot"
                value={newTimeSlot}
                onChange={(e) => setNewTimeSlot(e.target.value)}
                className="mt-1"
                placeholder="e.g., 9:00 AM"
              />
            </div>
          </div>
          <DialogFooter>
            <button
              onClick={() => setIsAddSlotDialogOpen(false)}
              className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              onClick={handleAddTimeSlot}
              disabled={!newTimeSlot.trim()}
              className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <Plus className="w-4 h-4" />
              Add Slot
            </button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
