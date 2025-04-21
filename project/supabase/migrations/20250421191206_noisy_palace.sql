/*
  # Initial Database Schema

  1. Tables
    - Properties
    - Rooms
    - Tenants
    - Payments
    - Maintenance Requests
    - Subscription Plans
    - Subscriptions
    - Backoffice Users
    - Backoffice Notifications
    - Backoffice Audit Logs

  2. Enums
    - Notification Types
    - Notification Status
    - User Roles
    - User Status
*/

-- Create enums
DO $$ BEGIN
    CREATE TYPE notification_type AS ENUM ('system', 'user', 'property', 'payment');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE notification_status AS ENUM ('unread', 'read');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('superadmin', 'admin', 'support');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE user_status AS ENUM ('active', 'inactive');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create properties table
CREATE TABLE IF NOT EXISTS properties (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  address text NOT NULL,
  city text NOT NULL,
  phone text,
  email text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  owner_id uuid REFERENCES auth.users(id) NOT NULL
);

-- Create rooms table
CREATE TABLE IF NOT EXISTS rooms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  number text NOT NULL,
  floor text NOT NULL,
  type text NOT NULL,
  price numeric NOT NULL,
  status text NOT NULL,
  facilities text[],
  tenant_id uuid,
  property_id uuid REFERENCES properties(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create tenants table
CREATE TABLE IF NOT EXISTS tenants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  phone text NOT NULL,
  email text NOT NULL,
  room_id uuid REFERENCES rooms(id),
  start_date date NOT NULL,
  end_date date NOT NULL,
  status text NOT NULL,
  payment_status text NOT NULL,
  property_id uuid REFERENCES properties(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create payments table
CREATE TABLE IF NOT EXISTS payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid REFERENCES tenants(id),
  room_id uuid REFERENCES rooms(id),
  amount numeric NOT NULL,
  date date,
  due_date date NOT NULL,
  status text NOT NULL,
  payment_method text,
  notes text,
  property_id uuid REFERENCES properties(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create maintenance_requests table
CREATE TABLE IF NOT EXISTS maintenance_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid REFERENCES rooms(id),
  tenant_id uuid REFERENCES tenants(id),
  title text NOT NULL,
  description text NOT NULL,
  date date NOT NULL,
  status text NOT NULL,
  priority text NOT NULL,
  property_id uuid REFERENCES properties(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create subscription_plans table
CREATE TABLE IF NOT EXISTS subscription_plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  price integer NOT NULL,
  max_properties integer NOT NULL,
  max_rooms_per_property integer NOT NULL,
  features jsonb NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create subscriptions table
CREATE TABLE IF NOT EXISTS subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) NOT NULL,
  plan_id uuid REFERENCES subscription_plans(id) NOT NULL,
  status text NOT NULL CHECK (status IN ('active', 'cancelled', 'expired')),
  current_period_start timestamptz NOT NULL,
  current_period_end timestamptz NOT NULL,
  cancel_at_period_end boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create backoffice_users table
CREATE TABLE IF NOT EXISTS backoffice_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  role user_role NOT NULL,
  name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  last_login timestamptz,
  status user_status NOT NULL DEFAULT 'active'
);

-- Create backoffice_notifications table
CREATE TABLE IF NOT EXISTS backoffice_notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  message text NOT NULL,
  type notification_type NOT NULL,
  status notification_status NOT NULL DEFAULT 'unread',
  created_at timestamptz DEFAULT now(),
  target_user_id uuid REFERENCES auth.users(id),
  target_property_id uuid REFERENCES properties(id) DEFERRABLE INITIALLY DEFERRED
);

-- Create backoffice_audit_logs table
CREATE TABLE IF NOT EXISTS backoffice_audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES backoffice_users(id) NOT NULL,
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id uuid NOT NULL,
  changes jsonb,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS on all tables
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE backoffice_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE backoffice_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE backoffice_audit_logs ENABLE ROW LEVEL SECURITY;