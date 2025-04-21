import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, useNavigate } from 'react-router-dom';
import Layout from './components/layout/Layout';
import Dashboard from './pages/Dashboard';
import Tenants from './pages/Tenants';
import Rooms from './pages/Rooms';
import Payments from './pages/Payments';
import Maintenance from './pages/Maintenance';
import Reports from './pages/Reports';
import Notifications from './pages/Notifications';
import Settings from './pages/Settings';
import Properties from './pages/Properties';
import { PropertyProvider, useProperty } from './contexts/PropertyContext';

const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { selectedProperty } = useProperty();
  const navigate = useNavigate();

  useEffect(() => {
    if (!selectedProperty && window.location.pathname !== '/properties') {
      navigate('/properties');
    }
  }, [selectedProperty, navigate]);

  if (!selectedProperty && window.location.pathname !== '/properties') {
    return null;
  }

  return <>{children}</>;
};

const AppContent: React.FC = () => {
  const [activePage, setActivePage] = useState('dashboard');
  const { selectedProperty } = useProperty();

  // Map page IDs to titles
  const pageTitles: Record<string, string> = {
    dashboard: 'Dashboard',
    tenants: 'Tenants Management',
    rooms: 'Room Management',
    payments: 'Payment Records',
    maintenance: 'Maintenance Requests',
    reports: 'Financial Reports',
    notifications: 'Notifications',
    settings: 'System Settings',
    properties: 'Properties'
  };

  return (
    <Layout 
      title={pageTitles[activePage]} 
      activeItem={activePage}
      onNavigate={setActivePage}
    >
      <Routes>
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        <Route 
          path="/dashboard" 
          element={
            <ProtectedRoute>
              <Dashboard onNavigate={setActivePage} />
            </ProtectedRoute>
          } 
        />
        <Route 
          path="/tenants" 
          element={
            <ProtectedRoute>
              <Tenants />
            </ProtectedRoute>
          } 
        />
        <Route 
          path="/rooms" 
          element={
            <ProtectedRoute>
              <Rooms />
            </ProtectedRoute>
          } 
        />
        <Route 
          path="/payments" 
          element={
            <ProtectedRoute>
              <Payments />
            </ProtectedRoute>
          } 
        />
        <Route 
          path="/maintenance" 
          element={
            <ProtectedRoute>
              <Maintenance />
            </ProtectedRoute>
          } 
        />
        <Route 
          path="/reports" 
          element={
            <ProtectedRoute>
              <Reports />
            </ProtectedRoute>
          } 
        />
        <Route 
          path="/notifications" 
          element={
            <ProtectedRoute>
              <Notifications />
            </ProtectedRoute>
          } 
        />
        <Route 
          path="/settings" 
          element={
            <ProtectedRoute>
              <Settings />
            </ProtectedRoute>
          } 
        />
        <Route path="/properties" element={<Properties />} />
      </Routes>
    </Layout>
  );
};

function App() {
  return (
    <Router>
      <PropertyProvider>
        <AppContent />
      </PropertyProvider>
    </Router>
  );
}

export default App;