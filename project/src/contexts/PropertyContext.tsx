import React, { createContext, useContext, useState, useEffect } from 'react';
import { Property } from '../types';
import { propertyService } from '../services/supabase';

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

export const PropertyProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [properties, setProperties] = useState<Property[]>([]);
  const [selectedProperty, setSelectedProperty] = useState<Property | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const loadProperties = async () => {
      try {
        const data = await propertyService.getAll();
        setProperties(data);
        if (data.length > 0 && !selectedProperty) {
          setSelectedProperty(data[0]);
        }
      } catch (error) {
        console.error('Error loading properties:', error);
      } finally {
        setIsLoading(false);
      }
    };

    loadProperties();
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