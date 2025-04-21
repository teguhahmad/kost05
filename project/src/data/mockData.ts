import { Tenant, Room, Payment, MaintenanceRequest, FinancialSummary, OccupancySummary } from '../types';

export const tenants: Tenant[] = [
  {
    id: '1',
    name: 'Budi Santoso',
    phone: '081234567890',
    email: 'budi@example.com',
    roomId: '101',
    startDate: '2023-01-15',
    endDate: '2024-01-15',
    status: 'active',
    paymentStatus: 'paid',
    lastPaymentDate: '2023-10-01'
  },
  {
    id: '2',
    name: 'Dewi Putri',
    phone: '081234567891',
    email: 'dewi@example.com',
    roomId: '102',
    startDate: '2023-02-01',
    endDate: '2024-02-01',
    status: 'active',
    paymentStatus: 'pending',
    lastPaymentDate: '2023-09-05'
  },
  {
    id: '3',
    name: 'Andi Wijaya',
    phone: '081234567892',
    email: 'andi@example.com',
    roomId: '201',
    startDate: '2023-03-10',
    endDate: '2024-03-10',
    status: 'active',
    paymentStatus: 'overdue',
    lastPaymentDate: '2023-08-15'
  },
  {
    id: '4',
    name: 'Siti Rahayu',
    phone: '081234567893',
    email: 'siti@example.com',
    roomId: '202',
    startDate: '2023-04-01',
    endDate: '2024-04-01',
    status: 'active',
    paymentStatus: 'paid',
    lastPaymentDate: '2023-10-02'
  },
  {
    id: '5',
    name: 'Rudi Hermawan',
    phone: '081234567894',
    email: 'rudi@example.com',
    roomId: '301',
    startDate: '2023-05-15',
    endDate: '2024-05-15',
    status: 'inactive',
    paymentStatus: 'paid',
    lastPaymentDate: '2023-09-25'
  }
];

export const rooms: Room[] = [
  {
    id: '101',
    number: '101',
    floor: '1',
    type: 'single',
    price: 1500000,
    status: 'occupied',
    facilities: ['AC', 'Bathroom', 'Wifi'],
    tenantId: '1'
  },
  {
    id: '102',
    number: '102',
    floor: '1',
    type: 'single',
    price: 1500000,
    status: 'occupied',
    facilities: ['AC', 'Bathroom', 'Wifi'],
    tenantId: '2'
  },
  {
    id: '103',
    number: '103',
    floor: '1',
    type: 'single',
    price: 1500000,
    status: 'vacant',
    facilities: ['AC', 'Bathroom', 'Wifi']
  },
  {
    id: '201',
    number: '201',
    floor: '2',
    type: 'double',
    price: 2000000,
    status: 'occupied',
    facilities: ['AC', 'Bathroom', 'Wifi', 'TV'],
    tenantId: '3'
  },
  {
    id: '202',
    number: '202',
    floor: '2',
    type: 'double',
    price: 2000000,
    status: 'occupied',
    facilities: ['AC', 'Bathroom', 'Wifi', 'TV'],
    tenantId: '4'
  },
  {
    id: '203',
    number: '203',
    floor: '2',
    type: 'double',
    price: 2000000,
    status: 'maintenance',
    facilities: ['AC', 'Bathroom', 'Wifi', 'TV']
  },
  {
    id: '301',
    number: '301',
    floor: '3',
    type: 'deluxe',
    price: 2500000,
    status: 'vacant',
    facilities: ['AC', 'Bathroom', 'Wifi', 'TV', 'Refrigerator']
  },
  {
    id: '302',
    number: '302',
    floor: '3',
    type: 'deluxe',
    price: 2500000,
    status: 'vacant',
    facilities: ['AC', 'Bathroom', 'Wifi', 'TV', 'Refrigerator']
  }
];

export const payments: Payment[] = [
  {
    id: '1',
    tenantId: '1',
    roomId: '101',
    amount: 1500000,
    date: '2023-10-01',
    dueDate: '2023-10-05',
    status: 'paid',
    paymentMethod: 'transfer',
    notes: 'Payment for October 2023'
  },
  {
    id: '2',
    tenantId: '2',
    roomId: '102',
    amount: 1500000,
    date: '',
    dueDate: '2023-10-05',
    status: 'pending',
    notes: 'Payment for October 2023'
  },
  {
    id: '3',
    tenantId: '3',
    roomId: '201',
    amount: 2000000,
    date: '',
    dueDate: '2023-09-05',
    status: 'overdue',
    notes: 'Payment for September 2023'
  },
  {
    id: '4',
    tenantId: '4',
    roomId: '202',
    amount: 2000000,
    date: '2023-10-02',
    dueDate: '2023-10-05',
    status: 'paid',
    paymentMethod: 'cash',
    notes: 'Payment for October 2023'
  }
];

export const maintenanceRequests: MaintenanceRequest[] = [
  {
    id: '1',
    roomId: '103',
    title: 'Leaking faucet',
    description: 'The bathroom faucet is leaking and needs to be fixed.',
    date: '2023-09-25',
    status: 'completed',
    priority: 'medium'
  },
  {
    id: '2',
    roomId: '203',
    title: 'AC not working',
    description: 'The air conditioner is not cooling properly.',
    date: '2023-10-02',
    status: 'in-progress',
    priority: 'high'
  },
  {
    id: '3',
    roomId: '202',
    tenantId: '4',
    title: 'Wifi connection issues',
    description: 'Having trouble connecting to the wifi network.',
    date: '2023-10-03',
    status: 'pending',
    priority: 'low'
  }
];

export const getFinancialSummary = (): FinancialSummary => {
  const totalRevenue = payments.reduce((sum, payment) => {
    return payment.status === 'paid' ? sum + payment.amount : sum;
  }, 0);

  const pendingPayments = payments.reduce((sum, payment) => {
    return payment.status === 'pending' ? sum + payment.amount : sum;
  }, 0);

  const overduePayments = payments.reduce((sum, payment) => {
    return payment.status === 'overdue' ? sum + payment.amount : sum;
  }, 0);

  return {
    totalRevenue,
    pendingPayments,
    overduePayments,
    monthlyIncome: 13500000
  };
};

export const getOccupancySummary = (): OccupancySummary => {
  const total = rooms.length;
  const occupied = rooms.filter(room => room.status === 'occupied').length;
  const vacant = rooms.filter(room => room.status === 'vacant').length;
  const maintenance = rooms.filter(room => room.status === 'maintenance').length;
  const occupancyRate = (occupied / total) * 100;

  return {
    total,
    occupied,
    vacant,
    maintenance,
    occupancyRate
  };
};