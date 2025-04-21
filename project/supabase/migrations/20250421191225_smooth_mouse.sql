/*
  # Initial RLS Policies

  This migration creates the initial Row Level Security (RLS) policies for all tables.
*/

-- Drop existing policies to avoid conflicts
DO $$ 
DECLARE
  table_names text[] := ARRAY['properties', 'rooms', 'tenants', 'payments', 'maintenance_requests', 
                             'subscription_plans', 'subscriptions', 'backoffice_users', 
                             'backoffice_notifications', 'backoffice_audit_logs'];
  table_name text;
BEGIN
  FOREACH table_name IN ARRAY table_names
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS "Users can view their own properties" ON %I', table_name);
    EXECUTE format('DROP POLICY IF EXISTS "Users can create properties" ON %I', table_name);
    EXECUTE format('DROP POLICY IF EXISTS "Users can update their own properties" ON %I', table_name);
    EXECUTE format('DROP POLICY IF EXISTS "Users can access rooms for their properties" ON %I', table_name);
    EXECUTE format('DROP POLICY IF EXISTS "Users can access tenants for their properties" ON %I', table_name);
    EXECUTE format('DROP POLICY IF EXISTS "Users can access payments for their properties" ON %I', table_name);
    EXECUTE format('DROP POLICY IF EXISTS "Users can access maintenance requests for their properties" ON %I', table_name);
    EXECUTE format('DROP POLICY IF EXISTS "Anyone can view subscription plans" ON %I', table_name);
    EXECUTE format('DROP POLICY IF EXISTS "Users can view their own subscriptions" ON %I', table_name);
    EXECUTE format('DROP POLICY IF EXISTS "Users can update their own subscriptions" ON %I', table_name);
    EXECUTE format('DROP POLICY IF EXISTS "Backoffice users can view all users" ON %I', table_name);
    EXECUTE format('DROP POLICY IF EXISTS "Only superadmins can manage users" ON %I', table_name);
    EXECUTE format('DROP POLICY IF EXISTS "Backoffice users can view all notifications" ON %I', table_name);
    EXECUTE format('DROP POLICY IF EXISTS "Backoffice users can manage notifications" ON %I', table_name);
    EXECUTE format('DROP POLICY IF EXISTS "Backoffice users can view audit logs" ON %I', table_name);
    EXECUTE format('DROP POLICY IF EXISTS "System can create audit logs" ON %I', table_name);
  END LOOP;
END $$;

-- Create policies for properties
CREATE POLICY "Users can view their own properties"
  ON properties FOR SELECT
  TO authenticated
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can create properties"
  ON properties FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update their own properties"
  ON properties FOR UPDATE
  TO authenticated
  USING (auth.uid() = owner_id);

-- Create policies for rooms
CREATE POLICY "Users can access rooms for their properties"
  ON rooms FOR ALL
  TO authenticated
  USING (property_id IN (SELECT id FROM properties WHERE owner_id = auth.uid()));

-- Create policies for tenants
CREATE POLICY "Users can access tenants for their properties"
  ON tenants FOR ALL
  TO authenticated
  USING (property_id IN (SELECT id FROM properties WHERE owner_id = auth.uid()));

-- Create policies for payments
CREATE POLICY "Users can access payments for their properties"
  ON payments FOR ALL
  TO authenticated
  USING (property_id IN (SELECT id FROM properties WHERE owner_id = auth.uid()));

-- Create policies for maintenance requests
CREATE POLICY "Users can access maintenance requests for their properties"
  ON maintenance_requests FOR ALL
  TO authenticated
  USING (property_id IN (SELECT id FROM properties WHERE owner_id = auth.uid()));

-- Create policies for subscription plans
CREATE POLICY "Anyone can view subscription plans"
  ON subscription_plans FOR SELECT
  TO authenticated
  USING (true);

-- Create policies for subscriptions
CREATE POLICY "Users can view their own subscriptions"
  ON subscriptions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own subscriptions"
  ON subscriptions FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

-- Create policies for backoffice users
CREATE POLICY "Backoffice users can view all users"
  ON backoffice_users FOR SELECT
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM backoffice_users bu
    WHERE bu.id = auth.uid() AND bu.status = 'active'
  ));

CREATE POLICY "Only superadmins can manage users"
  ON backoffice_users FOR ALL
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM backoffice_users bu
    WHERE bu.id = auth.uid() AND bu.role = 'superadmin' AND bu.status = 'active'
  ));

-- Create policies for notifications
CREATE POLICY "Backoffice users can view all notifications"
  ON backoffice_notifications FOR SELECT
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM backoffice_users bu
    WHERE bu.id = auth.uid() AND bu.status = 'active'
  ));

CREATE POLICY "Backoffice users can manage notifications"
  ON backoffice_notifications FOR ALL
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM backoffice_users bu
    WHERE bu.id = auth.uid() AND bu.status = 'active'
  ));

-- Create policies for audit logs
CREATE POLICY "Backoffice users can view audit logs"
  ON backoffice_audit_logs FOR SELECT
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM backoffice_users bu
    WHERE bu.id = auth.uid() AND bu.status = 'active'
  ));

CREATE POLICY "System can create audit logs"
  ON backoffice_audit_logs FOR INSERT
  TO authenticated
  WITH CHECK (EXISTS (
    SELECT 1 FROM backoffice_users bu
    WHERE bu.id = auth.uid() AND bu.status = 'active'
  ));