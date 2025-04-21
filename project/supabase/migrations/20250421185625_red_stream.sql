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

-- Create an enum for notification types
DO $$ BEGIN
    CREATE TYPE notification_type AS ENUM ('system', 'user', 'property', 'payment');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create an enum for notification status
DO $$ BEGIN
    CREATE TYPE notification_status AS ENUM ('unread', 'read');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create an enum for user roles
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('superadmin', 'admin', 'support');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create an enum for user status
DO $$ BEGIN
    CREATE TYPE user_status AS ENUM ('active', 'inactive');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Backoffice Users Table
CREATE TABLE IF NOT EXISTS backoffice_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  role user_role NOT NULL,
  name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  last_login timestamptz,
  status user_status NOT NULL DEFAULT 'active'
);

-- Backoffice Notifications Table
CREATE TABLE IF NOT EXISTS backoffice_notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  message text NOT NULL,
  type notification_type NOT NULL,
  status notification_status NOT NULL DEFAULT 'unread',
  created_at timestamptz DEFAULT now(),
  target_user_id uuid REFERENCES auth.users(id),
  -- We'll add the target_property_id reference after creating the properties table
  target_property_id uuid
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

-- Add a deferred foreign key constraint for target_property_id
-- This will be validated after all tables are created
ALTER TABLE backoffice_notifications
ADD CONSTRAINT backoffice_notifications_target_property_id_fkey
FOREIGN KEY (target_property_id) REFERENCES properties(id) DEFERRABLE INITIALLY DEFERRED;