import { supabase } from '../lib/supabase';
import { Property, Room, Tenant, Payment, MaintenanceRequest } from '../types';

export const propertyService = {
  async getAll() {
    const { data, error } = await supabase
      .from('properties')
      .select('*');
    if (error) throw error;
    return data as Property[];
  },

  async getById(id: string) {
    const { data, error } = await supabase
      .from('properties')
      .select('*')
      .eq('id', id)
      .single();
    if (error) throw error;
    return data as Property;
  }
};

export const roomService = {
  async getByPropertyId(propertyId: string) {
    const { data, error } = await supabase
      .from('rooms')
      .select('*')
      .eq('property_id', propertyId);
    if (error) throw error;
    return data as Room[];
  }
};

export const tenantService = {
  async getByPropertyId(propertyId: string) {
    const { data, error } = await supabase
      .from('tenants')
      .select('*')
      .eq('property_id', propertyId);
    if (error) throw error;
    return data as Tenant[];
  }
};

export const paymentService = {
  async getByPropertyId(propertyId: string) {
    const { data, error } = await supabase
      .from('payments')
      .select('*')
      .eq('property_id', propertyId);
    if (error) throw error;
    return data as Payment[];
  }
};

export const maintenanceService = {
  async getByPropertyId(propertyId: string) {
    const { data, error } = await supabase
      .from('maintenance_requests')
      .select('*')
      .eq('property_id', propertyId);
    if (error) throw error;
    return data as MaintenanceRequest[];
  }
};