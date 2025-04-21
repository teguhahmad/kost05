import React, { createContext, useContext, useState, useEffect } from 'react';
import { Property } from '../types';

interface PropertyContextType {
  properties: Property[];
  selectedProperty: Property | null;
  setSelectedProperty: (property: Property | null) => void;
  isLoading: boolean;
}

const PropertyContext = createContext<PropertyContextType>({
  properties: [],
  selectedProperty: null,
  setSelectedProperty: () => {},
  isLoading: true
});

export const useProperty = () => useContext(PropertyContext);

// Default property for development
const defaultProperty: Property = {
  id: '1',
  name: 'KostManager Property',
  address: 'Jl. Example No. 123',
  city: 'Jakarta',
  phone: '+62123456789',
  email: 'info@kostmanager.com',
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString(),
  owner_id: 'default-owner'
};

export const PropertyProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [properties, setProperties] = useState<Property[]>([defaultProperty]);
  const [selectedProperty, setSelectedProperty] = useState<Property | null>(defaultProperty);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    // In the future, this will fetch from Supabase
    setIsLoading(false);
  }, []);

  return (
    <PropertyContext.Provider 
      value={{ 
        properties, 
        selectedProperty, 
        setSelectedProperty,
        isLoading 
      }}
    >
      {children}
    </PropertyContext.Provider>
  );
};