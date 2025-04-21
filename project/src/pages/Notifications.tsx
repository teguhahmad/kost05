import React, { useState } from 'react';
import { format } from 'date-fns';
import Card, { CardHeader, CardContent } from '../components/ui/Card';
import Badge from '../components/ui/Badge';
import Button from '../components/ui/Button';
import { Bell, CheckCircle, AlertTriangle, Clock, Settings, X } from 'lucide-react';

interface Notification {
  id: string;
  title: string;
  message: string;
  type: 'payment' | 'maintenance' | 'system' | 'tenant';
  priority: 'high' | 'normal' | 'low';
  date: string;
  read: boolean;
}

const initialNotifications: Notification[] = [
  {
    id: '1',
    title: 'Pembayaran Terlambat',
    message: 'Pembayaran Kamar 201 terlambat 5 hari',
    type: 'payment',
    priority: 'high',
    date: '2024-03-15T10:00:00',
    read: false
  },
  {
    id: '2',
    title: 'Pembaruan Permintaan Pemeliharaan',
    message: 'Perbaikan AC di Kamar 103 telah selesai',
    type: 'maintenance',
    priority: 'normal',
    date: '2024-03-15T09:30:00',
    read: false
  },
  {
    id: '3',
    title: 'Check-in Penyewa Baru',
    message: 'Penyewa baru akan check-in ke Kamar 302 besok',
    type: 'tenant',
    priority: 'normal',
    date: '2024-03-15T08:45:00',
    read: true
  },
  {
    id: '4',
    title: 'Pemeliharaan Sistem',
    message: 'Sistem akan mengalami pemeliharaan malam ini pukul 00:00',
    type: 'system',
    priority: 'low',
    date: '2024-03-14T20:00:00',
    read: true
  }
];

const Notifications: React.FC = () => {
  const [notifications, setNotifications] = useState<Notification[]>(initialNotifications);
  const [filter, setFilter] = useState('all');
  const [showUnreadOnly, setShowUnreadOnly] = useState(false);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [selectedNotification, setSelectedNotification] = useState<Notification | null>(null);

  const getNotificationIcon = (type: string) => {
    switch (type) {
      case 'payment':
        return <AlertTriangle className="text-red-500" size={20} />;
      case 'maintenance':
        return <Clock className="text-blue-500" size={20} />;
      case 'system':
        return <Settings className="text-gray-500" size={20} />;
      case 'tenant':
        return <Bell className="text-green-500" size={20} />;
      default:
        return <Bell className="text-gray-500" size={20} />;
    }
  };

  const getNotificationColor = (priority: string) => {
    switch (priority) {
      case 'high':
        return 'bg-red-100 text-red-800';
      case 'normal':
        return 'bg-blue-100 text-blue-800';
      case 'low':
        return 'bg-gray-100 text-gray-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const filteredNotifications = notifications.filter(notification => {
    if (showUnreadOnly && notification.read) return false;
    if (filter === 'all') return true;
    return notification.type === filter;
  });

  const handleMarkAsRead = (id: string) => {
    setNotifications(notifications.map(notification =>
      notification.id === id ? { ...notification, read: true } : notification
    ));
  };

  const handleMarkAllAsRead = () => {
    setNotifications(notifications.map(notification => ({ ...notification, read: true })));
  };

  const handleDeleteNotification = (notification: Notification) => {
    setSelectedNotification(notification);
    setShowDeleteConfirm(true);
  };

  const confirmDelete = () => {
    if (selectedNotification) {
      setNotifications(notifications.filter(n => n.id !== selectedNotification.id));
    }
    setShowDeleteConfirm(false);
    setSelectedNotification(null);
  };

  const unreadCount = notifications.filter(n => !n.read).length;

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-900">Notifikasi</h1>
        <Button 
          variant="outline" 
          size="sm" 
          icon={<CheckCircle size={16} />}
          onClick={handleMarkAllAsRead}
          disabled={unreadCount === 0}
        >
          Tandai Semua Dibaca
        </Button>
      </div>

      <Card>
        <CardHeader className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
          <div className="flex items-center gap-2">
            <h2 className="text-lg font-semibold text-gray-800">Notifikasi Terbaru</h2>
            {unreadCount > 0 && (
              <Badge className="bg-blue-100 text-blue-800">
                {unreadCount} Baru
              </Badge>
            )}
          </div>
          <div className="flex flex-wrap gap-2">
            <Button 
              variant={filter === 'all' ? 'primary' : 'outline'} 
              size="sm"
              onClick={() => setFilter('all')}
            >
              Semua
            </Button>
            <Button 
              variant={filter === 'payment' ? 'primary' : 'outline'} 
              size="sm"
              onClick={() => setFilter('payment')}
            >
              Pembayaran
            </Button>
            <Button 
              variant={filter === 'maintenance' ? 'primary' : 'outline'} 
              size="sm"
              onClick={() => setFilter('maintenance')}
            >
              Pemeliharaan
            </Button>
            <Button 
              variant={filter === 'tenant' ? 'primary' : 'outline'} 
              size="sm"
              onClick={() => setFilter('tenant')}
            >
              Penyewa
            </Button>
            <Button 
              variant={filter === 'system' ? 'primary' : 'outline'} 
              size="sm"
              onClick={() => setFilter('system')}
            >
              Sistem
            </Button>
          </div>
        </CardHeader>

        <div className="px-6 pb-4">
          <label className="flex items-center">
            <input
              type="checkbox"
              checked={showUnreadOnly}
              onChange={(e) => setShowUnreadOnly(e.target.checked)}
              className="rounded border-gray-300 text-blue-600 shadow-sm focus:border-blue-300 focus:ring focus:ring-blue-200 focus:ring-opacity-50"
            />
            <span className="ml-2 text-sm text-gray-600">Tampilkan hanya yang belum dibaca</span>
          </label>
        </div>

        <CardContent className="p-0">
          {filteredNotifications.length > 0 ? (
            <div className="divide-y divide-gray-100">
              {filteredNotifications.map((notification) => (
                <div 
                  key={notification.id} 
                  className={`p-4 hover:bg-gray-50 ${!notification.read ? 'bg-blue-50' : ''}`}
                >
                  <div className="flex items-start gap-4">
                    <div className="p-2 bg-white rounded-full shadow-sm">
                      {getNotificationIcon(notification.type)}
                    </div>
                    <div className="flex-1">
                      <div className="flex items-start justify-between">
                        <div>
                          <h3 className="font-medium text-gray-900">{notification.title}</h3>
                          <p className="mt-1 text-sm text-gray-600">{notification.message}</p>
                        </div>
                        <Badge className={getNotificationColor(notification.priority)}>
                          {notification.priority === 'high' ? 'Tinggi' : 
                           notification.priority === 'normal' ? 'Normal' : 'Rendah'}
                        </Badge>
                      </div>
                      <div className="mt-2 flex items-center justify-between">
                        <span className="text-xs text-gray-500">
                          {format(new Date(notification.date), 'dd MMM yyyy HH:mm')}
                        </span>
                        <div className="flex gap-2">
                          {!notification.read && (
                            <Button 
                              variant="outline" 
                              size="sm"
                              onClick={() => handleMarkAsRead(notification.id)}
                            >
                              Tandai Dibaca
                            </Button>
                          )}
                          <Button 
                            variant="danger" 
                            size="sm"
                            onClick={() => handleDeleteNotification(notification)}
                          >
                            Hapus
                          </Button>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="p-8 text-center text-gray-500">
              Tidak ada notifikasi ditemukan
            </div>
          )}
        </CardContent>
      </Card>

      {/* Delete Confirmation Modal */}
      {showDeleteConfirm && selectedNotification && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl w-full max-w-md p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-900">Hapus Notifikasi</h3>
              <button onClick={() => setShowDeleteConfirm(false)} className="text-gray-500">
                <X size={24} />
              </button>
            </div>
            <p className="text-gray-600 mb-6">
              Apakah Anda yakin ingin menghapus notifikasi ini? Tindakan ini tidak dapat dibatalkan.
            </p>
            <div className="flex justify-end gap-3">
              <Button variant="outline" onClick={() => setShowDeleteConfirm(false)}>
                Batal
              </Button>
              <Button variant="danger" onClick={confirmDelete}>
                Hapus
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Notifications;