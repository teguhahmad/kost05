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

  2. Security
    - Enable RLS on properties table
    - Add policies for property access
*/

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

-- Enable RLS
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;

-- Create policies
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

-- Add property_id to existing tables
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS property_id uuid REFERENCES properties(id);
ALTER TABLE tenants ADD COLUMN IF NOT EXISTS property_id uuid REFERENCES properties(id);
ALTER TABLE payments ADD COLUMN IF NOT EXISTS property_id uuid REFERENCES properties(id);
ALTER TABLE maintenance_requests ADD COLUMN IF NOT EXISTS property_id uuid REFERENCES properties(id);

-- Update RLS policies for other tables to include property_id check
CREATE POLICY "Users can access rooms for their properties"
  ON rooms
  TO authenticated
  USING (
    property_id IN (
      SELECT id FROM properties WHERE owner_id = auth.uid()
    )
  );

CREATE POLICY "Users can access tenants for their properties"
  ON tenants
  TO authenticated
  USING (
    property_id IN (
      SELECT id FROM properties WHERE owner_id = auth.uid()
    )
  );

CREATE POLICY "Users can access payments for their properties"
  ON payments
  TO authenticated
  USING (
    property_id IN (
      SELECT id FROM properties WHERE owner_id = auth.uid()
    )
  );

CREATE POLICY "Users can access maintenance requests for their properties"
  ON maintenance_requests
  TO authenticated
  USING (
    property_id IN (
      SELECT id FROM properties WHERE owner_id = auth.uid()
    )
  );