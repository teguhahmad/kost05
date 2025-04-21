/*
  # Seed Data

  This migration adds initial data for subscription plans
*/

-- Insert default subscription plans if they don't exist
INSERT INTO subscription_plans (name, description, price, max_properties, max_rooms_per_property, features)
SELECT
  'Free',
  'Perfect for small property owners just getting started',
  0,
  1,
  5,
  '{
    "tenant_data": false,
    "auto_billing": false,
    "billing_notifications": false,
    "financial_reports": "basic",
    "data_backup": false,
    "multi_user": false,
    "analytics": false,
    "support": "basic"
  }'::jsonb
WHERE NOT EXISTS (SELECT 1 FROM subscription_plans WHERE name = 'Free');

INSERT INTO subscription_plans (name, description, price, max_properties, max_rooms_per_property, features)
SELECT
  'Premium',
  'Great for growing property businesses',
  199000,
  3,
  30,
  '{
    "tenant_data": true,
    "auto_billing": true,
    "billing_notifications": true,
    "financial_reports": "advanced",
    "data_backup": "weekly",
    "multi_user": false,
    "analytics": false,
    "support": "priority"
  }'::jsonb
WHERE NOT EXISTS (SELECT 1 FROM subscription_plans WHERE name = 'Premium');

INSERT INTO subscription_plans (name, description, price, max_properties, max_rooms_per_property, features)
SELECT
  'Business',
  'Ideal for established property management companies',
  499000,
  5,
  100,
  '{
    "tenant_data": true,
    "auto_billing": true,
    "billing_notifications": true,
    "financial_reports": "advanced",
    "data_backup": "daily",
    "multi_user": true,
    "analytics": true,
    "support": "priority"
  }'::jsonb
WHERE NOT EXISTS (SELECT 1 FROM subscription_plans WHERE name = 'Business');

INSERT INTO subscription_plans (name, description, price, max_properties, max_rooms_per_property, features)
SELECT
  'Enterprise',
  'Complete solution for large-scale property management',
  999000,
  -1,
  -1,
  '{
    "tenant_data": true,
    "auto_billing": true,
    "billing_notifications": true,
    "financial_reports": "predictive",
    "data_backup": "realtime",
    "multi_user": true,
    "analytics": "predictive",
    "support": "24/7"
  }'::jsonb
WHERE NOT EXISTS (SELECT 1 FROM subscription_plans WHERE name = 'Enterprise');