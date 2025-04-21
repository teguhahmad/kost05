import React, { createContext, useContext, useState } from 'react';

interface BackofficeContextType {
  isBackoffice: boolean;
  toggleBackoffice: () => void;
}

const BackofficeContext = createContext<BackofficeContextType>({
  isBackoffice: false,
  toggleBackoffice: () => {},
});

export const useBackoffice = () => useContext(BackofficeContext);

export const BackofficeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [isBackoffice, setIsBackoffice] = useState(false);

  const toggleBackoffice = () => {
    setIsBackoffice(prev => !prev);
  };

  return (
    <BackofficeContext.Provider value={{ isBackoffice, toggleBackoffice }}>
      {children}
    </BackofficeContext.Provider>
  );
};