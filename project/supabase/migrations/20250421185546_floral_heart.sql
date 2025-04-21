/*
  # Add multi-property support

  1. New Tables
    - `properties`
      - `id` (uuid, primary key)
      - `name` (text)
      - `address` (text)
      - `city` (text)
      - `phone` (text)
      - `email` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
      - `owner_id` (uuid, foreign key to auth.users)
    - `rooms`
      - `id` (uuid, primary key)
      - `number` (text)
      - `floor` (text)
      - `type` (text)
      - `price` (numeric)
      - `status` (text)
      - `facilities` (text[])
      - `tenant_id` (uuid)
      - `property_id` (uuid)
    - `tenants`
      - `id` (uuid, primary key)
      - `name` (text)
      - `phone` (text)
      - `email` (text)
      - `room_id` (uuid)
      - `start_date` (date)
      - `end_date` (date)
      - `status` (text)
      - `payment_status` (text)
      - `property_id` (uuid)
    - `payments`
      - `id` (uuid, primary key)
      - `tenant_id` (uuid)
      - `room_id` (uuid)
      - `amount` (numeric)
      - `date` (date)
      - `due_date` (date)
      - `status` (text)
      - `payment_method` (text)
      - `notes` (text)
      - `property_id` (uuid)
    - `maintenance_requests`
      - `id` (uuid, primary key)
      - `room_id` (uuid)
      - `tenant_id` (uuid)
      - `title` (text)
      - `description` (text)
      - `date` (date)
      - `status` (text)
      - `priority` (text)
      - `property_id` (uuid)

  2. Security
    - Enable RLS on all tables
    - Add policies for property access
*/

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

-- Enable RLS on all tables
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_requests ENABLE ROW LEVEL SECURITY;

-- Create policies for properties
CREATE POLICY "Users can view their own properties"
  ON properties
  FOR SELECT
  TO authenticated
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can create properties"
  ON properties
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update their own properties"
  ON properties
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = owner_id);

-- Create policies for rooms
CREATE POLICY "Users can access rooms for their properties"
  ON rooms
  FOR ALL
  TO authenticated
  USING (
    property_id IN (
      SELECT id FROM properties WHERE owner_id = auth.uid()
    )
  );

-- Create policies for tenants
CREATE POLICY "Users can access tenants for their properties"
  ON tenants
  FOR ALL
  TO authenticated
  USING (
    property_id IN (
      SELECT id FROM properties WHERE owner_id = auth.uid()
    )
  );

-- Create policies for payments
CREATE POLICY "Users can access payments for their properties"
  ON payments
  FOR ALL
  TO authenticated
  USING (
    property_id IN (
      SELECT id FROM properties WHERE owner_id = auth.uid()
    )
  );

-- Create policies for maintenance requests
CREATE POLICY "Users can access maintenance requests for their properties"
  ON maintenance_requests
  FOR ALL
  TO authenticated
  USING (
    property_id IN (
      SELECT id FROM properties WHERE owner_id = auth.uid()
    )
  );