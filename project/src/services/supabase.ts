import { supabase } from '../lib/supabase';
import { Property, Room, Tenant, Payment, MaintenanceRequest, Notification } from '../types';

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

export const notificationService = {
  async getAll() {
    const { data, error } = await supabase
      .from('notifications')
      .select('*')
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data as Notification[];
  },

  async markAsRead(id: string) {
    const { error } = await supabase
      .from('notifications')
      .update({ status: 'read' })
      .eq('id', id);
    if (error) throw error;
  },

  async markAllAsRead() {
    const { error } = await supabase
      .from('notifications')
      .update({ status: 'read' })
      .eq('status', 'unread');
    if (error) throw error;
  },

  async delete(id: string) {
    const { error } = await supabase
      .from('notifications')
      .delete()
      .eq('id', id);
    if (error) throw error;
  },

  async create(notification: Omit<Notification, 'id' | 'created_at' | 'status'>) {
    const { data, error } = await supabase
      .from('notifications')
      .insert([{ ...notification, status: 'unread' }])
      .select()
      .single();
    if (error) throw error;
    return data as Notification;
  }
};