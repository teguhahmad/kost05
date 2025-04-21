/*
  # Backoffice System Schema

  1. New Tables
    - `backoffice_users`
      - `id` (uuid, primary key)
      - `email` (text, unique)
      - `role` (text) - superadmin, admin, support
      - `name` (text)
      - `created_at` (timestamptz)
      - `last_login` (timestamptz)
      - `status` (text) - active, inactive

    - `backoffice_notifications`
      - `id` (uuid, primary key)
      - `title` (text)
      - `message` (text)
      - `type` (text) - system, user, property, payment
      - `status` (text) - unread, read
      - `created_at` (timestamptz)
      - `target_user_id` (uuid, nullable)
      - `target_property_id` (uuid, nullable)

    - `backoffice_audit_logs`
      - `id` (uuid, primary key)
      - `user_id` (uuid)
      - `action` (text)
      - `entity_type` (text)
      - `entity_id` (uuid)
      - `changes` (jsonb)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS
    - Add policies for backoffice access
*/

-- Backoffice Users Table
CREATE TABLE IF NOT EXISTS backoffice_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  role text NOT NULL CHECK (role IN ('superadmin', 'admin', 'support')),
  name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  last_login timestamptz,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive'))
);

-- Backoffice Notifications Table
CREATE TABLE IF NOT EXISTS backoffice_notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  message text NOT NULL,
  type text NOT NULL CHECK (type IN ('system', 'user', 'property', 'payment')),
  status text NOT NULL DEFAULT 'unread' CHECK (status IN ('unread', 'read')),
  created_at timestamptz DEFAULT now(),
  target_user_id uuid REFERENCES auth.users(id),
  target_property_id uuid REFERENCES properties(id)
);

-- Backoffice Audit Logs Table
CREATE TABLE IF NOT EXISTS backoffice_audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES backoffice_users(id) NOT NULL,
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id uuid NOT NULL,
  changes jsonb,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE backoffice_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE backoffice_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE backoffice_audit_logs ENABLE ROW LEVEL SECURITY;

-- Create policies for backoffice users
CREATE POLICY "Backoffice users can view all users"
  ON backoffice_users
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM backoffice_users bu
      WHERE bu.id = auth.uid() AND bu.status = 'active'
    )
  );

CREATE POLICY "Only superadmins can manage users"
  ON backoffice_users
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM backoffice_users bu
      WHERE bu.id = auth.uid() AND bu.role = 'superadmin' AND bu.status = 'active'
    )
  );

-- Create policies for notifications
CREATE POLICY "Backoffice users can view all notifications"
  ON backoffice_notifications
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM backoffice_users bu
      WHERE bu.id = auth.uid() AND bu.status = 'active'
    )
  );

CREATE POLICY "Backoffice users can manage notifications"
  ON backoffice_notifications
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM backoffice_users bu
      WHERE bu.id = auth.uid() AND bu.status = 'active'
    )
  );

-- Create policies for audit logs
CREATE POLICY "Backoffice users can view audit logs"
  ON backoffice_audit_logs
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM backoffice_users bu
      WHERE bu.id = auth.uid() AND bu.status = 'active'
    )
  );

CREATE POLICY "System can create audit logs"
  ON backoffice_audit_logs
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM backoffice_users bu
      WHERE bu.id = auth.uid() AND bu.status = 'active'
    )
  );