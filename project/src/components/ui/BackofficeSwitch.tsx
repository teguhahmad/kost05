import React from 'react';
import { useBackoffice } from '../../contexts/BackofficeContext';
import { LayoutDashboard } from 'lucide-react';

const BackofficeSwitch: React.FC = () => {
  const { isBackoffice, toggleBackoffice } = useBackoffice();

  return (
    <button
      onClick={toggleBackoffice}
      className={`fixed bottom-24 right-6 z-50 p-3 rounded-full shadow-lg transition-all transform hover:scale-110 ${
        isBackoffice ? 'bg-red-600 hover:bg-red-700' : 'bg-blue-600 hover:bg-blue-700'
      }`}
      title={isBackoffice ? 'Switch to User Interface' : 'Switch to Backoffice'}
    >
      <LayoutDashboard className="w-6 h-6 text-white" />
    </button>
  );
};

export default BackofficeSwitch;