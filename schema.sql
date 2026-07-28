create extension if not exists pgcrypto;

create type user_role as enum ('owner','admin','pricing_manager','operator','viewer');
create type product_kind as enum ('single','bundle');
create type identifier_kind as enum ('ean','sku','manufacturer_code','supplier_code','other');
create type channel_kind as enum ('own_store','marketplace','retailer','manufacturer','comparison_site');
create type rule_status as enum ('draft','pending_approval','active','suspended','expired','archived');
create type rule_source as enum ('contract','manual_verified','official_source','api','ai_proposal','estimate');
create type proposal_status as enum ('draft','pending','approved','rejected','applied','failed','expired','blocked','rolled_back');
create type workflow_event_kind as enum ('created','validated','assigned','approved','rejected','applied','failed','rolled_back','commented');
create type fee_kind as enum ('percentage','fixed','percentage_plus_fixed','tiered','formula');
create type percentage_base as enum ('gross_item','gross_order','net_tax_item','net_tax_order','shipping','custom');
create type confidence_level as enum ('low','medium','high','verified');
create type bundle_match_kind as enum ('exact','equivalent','partial','incompatible','unverified');

create table organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  default_currency char(3) not null default 'EUR',
  timezone text not null default 'Europe/Rome',
  created_at timestamptz not null default now()
);

create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  organization_id uuid not null references organizations(id) on delete cascade,
  email text not null,
  full_name text,
  role user_role not null default 'viewer',
  is_active boolean not null default true,
  invited_by uuid references profiles(id),
  created_at timestamptz not null default now(),
  unique (organization_id, email)
);

create table stores (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  name text not null,
  platform text not null,
  external_store_id text,
  base_country_code char(2) not null,
  currency char(3) not null default 'EUR',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (organization_id, platform, external_store_id)
);

create table countries (
  code char(2) primary key,
  name text not null,
  currency char(3) not null,
  is_active boolean not null default true
);

create table sales_channels (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  store_id uuid references stores(id) on delete cascade,
  name text not null,
  kind channel_kind not null,
  country_code char(2) references countries(code),
  external_id text,
  reliability_score numeric(5,2) not null default 50 check (reliability_score between 0 and 100),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table products (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  store_id uuid not null references stores(id) on delete cascade,
  external_product_id text,
  external_variant_id text,
  kind product_kind not null default 'single',
  title text not null,
  brand text,
  category text,
  supplier_code text,
  list_price numeric(14,4) not null check (list_price >= 0),
  current_discount_pct numeric(9,6) not null default 0 check (current_discount_pct between 0 and 100),
  currency char(3) not null default 'EUR',
  weight_kg numeric(14,4),
  length_cm numeric(14,4),
  width_cm numeric(14,4),
  height_cm numeric(14,4),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (store_id, external_variant_id)
);

create table product_identifiers (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete cascade,
  kind identifier_kind not null,
  value text not null,
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  unique (kind, value)
);

create table bundle_components (
  id uuid primary key default gen_random_uuid(),
  bundle_product_id uuid not null references products(id) on delete cascade,
  component_product_id uuid references products(id),
  component_identifier text,
  description text,
  quantity numeric(14,4) not null default 1 check (quantity > 0),
  unit_cost_override numeric(14,4),
  unit_weight_override_kg numeric(14,4),
  is_required boolean not null default true,
  created_at timestamptz not null default now(),
  check (component_product_id is not null or component_identifier is not null),
  check (bundle_product_id is distinct from component_product_id)
);

create table cost_entries (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  product_id uuid references products(id) on delete cascade,
  cost_type text not null,
  country_code char(2) references countries(code),
  channel_id uuid references sales_channels(id) on delete cascade,
  amount numeric(14,4) not null,
  currency char(3) not null default 'EUR',
  valid_from date not null,
  valid_to date,
  source rule_source not null default 'manual_verified',
  source_reference text,
  is_verified boolean not null default false,
  created_by uuid references profiles(id),
  created_at timestamptz not null default now(),
  check (valid_to is null or valid_to >= valid_from)
);

create table tax_rates (
  id uuid primary key default gen_random_uuid(),
  country_code char(2) not null references countries(code),
  tax_category text not null default 'standard',
  rate_pct numeric(9,6) not null check (rate_pct >= 0),
  valid_from date not null,
  valid_to date,
  source rule_source not null default 'official_source',
  source_reference text,
  is_verified boolean not null default false,
  unique (country_code, tax_category, valid_from)
);

create table payment_providers (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  name text not null,
  external_id text,
  is_active boolean not null default true,
  unique (organization_id, name)
);

create table carriers (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  name text not null,
  external_id text,
  is_active boolean not null default true,
  unique (organization_id, name)
);

create table carrier_services (
  id uuid primary key default gen_random_uuid(),
  carrier_id uuid not null references carriers(id) on delete cascade,
  name text not null,
  service_code text,
  volumetric_divisor numeric(14,4),
  max_weight_kg numeric(14,4),
  is_active boolean not null default true,
  unique (carrier_id, service_code)
);

create table carrier_zones (
  id uuid primary key default gen_random_uuid(),
  carrier_id uuid not null references carriers(id) on delete cascade,
  country_code char(2) not null references countries(code),
  name text not null,
  region_codes text[] not null default '{}',
  postal_code_patterns text[] not null default '{}',
  is_remote boolean not null default false
);

create table fee_schedules (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  name text not null,
  fee_domain text not null check (fee_domain in ('payment','marketplace','advertising','returns','currency','carrier','other')),
  provider_id uuid references payment_providers(id) on delete cascade,
  channel_id uuid references sales_channels(id) on delete cascade,
  carrier_service_id uuid references carrier_services(id) on delete cascade,
  carrier_zone_id uuid references carrier_zones(id) on delete cascade,
  country_code char(2) references countries(code),
  category text,
  brand text,
  fee_kind fee_kind not null,
  percentage_base percentage_base,
  percentage_value numeric(12,8),
  fixed_amount numeric(14,4),
  minimum_amount numeric(14,4),
  maximum_amount numeric(14,4),
  currency char(3) not null default 'EUR',
  formula jsonb not null default '{}'::jsonb,
  min_order_value numeric(14,4),
  max_order_value numeric(14,4),
  min_weight_kg numeric(14,4),
  max_weight_kg numeric(14,4),
  min_volumetric_weight_kg numeric(14,4),
  max_volumetric_weight_kg numeric(14,4),
  min_packages integer,
  max_packages integer,
  valid_from date not null,
  valid_to date,
  version integer not null default 1,
  source rule_source not null default 'manual_verified',
  source_reference text,
  status rule_status not null default 'draft',
  approved_by uuid references profiles(id),
  approved_at timestamptz,
  created_by uuid references profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (valid_to is null or valid_to >= valid_from)
);

create table rules (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  name text not null,
  rule_type text not null,
  safety_level integer not null default 50 check (safety_level between 0 and 100),
  scope jsonb not null default '{}'::jsonb,
  conditions jsonb not null default '{}'::jsonb,
  effect jsonb not null default '{}'::jsonb,
  priority integer not null default 100,
  specificity integer not null default 0,
  valid_from timestamptz not null,
  valid_to timestamptz,
  version integer not null default 1,
  source rule_source not null default 'manual_verified',
  source_reference text,
  status rule_status not null default 'draft',
  approval_required boolean not null default true,
  approved_by uuid references profiles(id),
  approved_at timestamptz,
  created_by uuid references profiles(id),
  updated_by uuid references profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (valid_to is null or valid_to >= valid_from)
);

create table competitors (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  name text not null,
  domain text,
  channel_kind channel_kind not null,
  country_code char(2) references countries(code),
  reliability_score numeric(5,2) not null default 50 check (reliability_score between 0 and 100),
  is_whitelisted boolean not null default false,
  is_blacklisted boolean not null default false,
  notes text
);

create table competitor_offers (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  product_id uuid references products(id) on delete cascade,
  competitor_id uuid not null references competitors(id) on delete cascade,
  seller_name text,
  condition text not null default 'new',
  price numeric(14,4) not null,
  shipping_price numeric(14,4) not null default 0,
  currency char(3) not null default 'EUR',
  in_stock boolean not null default true,
  source_url text,
  observed_at timestamptz not null default now(),
  expires_at timestamptz,
  match_score numeric(5,2),
  reliability_score numeric(5,2),
  bundle_match bundle_match_kind,
  raw_payload jsonb not null default '{}'::jsonb
);

create table competitor_offer_components (
  id uuid primary key default gen_random_uuid(),
  offer_id uuid not null references competitor_offers(id) on delete cascade,
  identifier text,
  description text,
  quantity numeric(14,4) not null default 1,
  matched_product_id uuid references products(id),
  match_score numeric(5,2)
);

create table calculation_runs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  product_id uuid not null references products(id) on delete cascade,
  country_code char(2) not null references countries(code),
  channel_id uuid not null references sales_channels(id),
  payment_provider_id uuid references payment_providers(id),
  carrier_service_id uuid references carrier_services(id),
  calculated_at timestamptz not null default now(),
  engine_version text not null,
  rule_set_hash text not null,
  input_snapshot jsonb not null,
  applied_rules jsonb not null,
  cost_breakdown jsonb not null,
  result_snapshot jsonb not null,
  confidence_score numeric(5,2) not null check (confidence_score between 0 and 100),
  confidence_level confidence_level not null,
  warnings jsonb not null default '[]'::jsonb,
  explanation jsonb not null default '{}'::jsonb
);

create table price_proposals (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  calculation_run_id uuid not null references calculation_runs(id),
  product_id uuid not null references products(id) on delete cascade,
  country_code char(2) not null references countries(code),
  channel_id uuid not null references sales_channels(id),
  current_discount_pct numeric(9,6) not null,
  proposed_discount_pct numeric(9,6) not null,
  current_price numeric(14,4) not null,
  proposed_price numeric(14,4) not null,
  projected_margin_amount numeric(14,4),
  projected_margin_pct numeric(9,6),
  status proposal_status not null default 'draft',
  risk_level text not null default 'medium',
  requires_owner boolean not null default false,
  assigned_to uuid references profiles(id),
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  decided_at timestamptz,
  decided_by uuid references profiles(id),
  decision_reason text
);

create table workflow_events (
  id bigint generated always as identity primary key,
  organization_id uuid not null references organizations(id) on delete cascade,
  proposal_id uuid references price_proposals(id) on delete cascade,
  event_kind workflow_event_kind not null,
  actor_id uuid references profiles(id),
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table integration_connections (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  adapter_type text not null,
  provider text not null,
  display_name text not null,
  configuration jsonb not null default '{}'::jsonb,
  secret_reference text,
  status text not null default 'disconnected',
  last_success_at timestamptz,
  last_error_at timestamptz,
  last_error text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table ai_suggestions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  suggestion_type text not null,
  target_type text not null,
  target_id text,
  summary text not null,
  evidence jsonb not null default '[]'::jsonb,
  proposed_change jsonb not null default '{}'::jsonb,
  confidence_score numeric(5,2),
  status text not null default 'open',
  reviewed_by uuid references profiles(id),
  reviewed_at timestamptz,
  review_note text,
  created_at timestamptz not null default now()
);

create table audit_log (
  id bigint generated always as identity primary key,
  organization_id uuid not null references organizations(id) on delete cascade,
  actor_id uuid references profiles(id),
  entity_type text not null,
  entity_id text not null,
  action text not null,
  old_values jsonb,
  new_values jsonb,
  reason text,
  correlation_id uuid,
  created_at timestamptz not null default now()
);

create index products_org_store_idx on products(organization_id, store_id) where is_active;
create index identifiers_lookup_idx on product_identifiers(kind, value);
create index bundle_components_idx on bundle_components(bundle_product_id);
create index cost_entries_lookup_idx on cost_entries(product_id, country_code, channel_id, valid_from desc);
create index fee_schedules_lookup_idx on fee_schedules(fee_domain, country_code, channel_id, valid_from desc) where status = 'active';
create index rules_lookup_idx on rules(rule_type, status, priority desc, specificity desc, valid_from desc);
create index rules_scope_gin_idx on rules using gin(scope);
create index rules_conditions_gin_idx on rules using gin(conditions);
create index offers_product_observed_idx on competitor_offers(product_id, observed_at desc);
create index calculation_runs_product_idx on calculation_runs(product_id, calculated_at desc);
create index proposals_status_idx on price_proposals(organization_id, status, created_at desc);
create index workflow_events_proposal_idx on workflow_events(proposal_id, created_at);

create or replace function current_organization_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select organization_id from profiles where id = auth.uid() and is_active = true
$$;

alter table organizations enable row level security;
alter table profiles enable row level security;
alter table stores enable row level security;
alter table sales_channels enable row level security;
alter table products enable row level security;
alter table product_identifiers enable row level security;
alter table bundle_components enable row level security;
alter table cost_entries enable row level security;
alter table payment_providers enable row level security;
alter table carriers enable row level security;
alter table carrier_services enable row level security;
alter table carrier_zones enable row level security;
alter table fee_schedules enable row level security;
alter table rules enable row level security;
alter table competitors enable row level security;
alter table competitor_offers enable row level security;
alter table competitor_offer_components enable row level security;
alter table calculation_runs enable row level security;
alter table price_proposals enable row level security;
alter table workflow_events enable row level security;
alter table integration_connections enable row level security;
alter table ai_suggestions enable row level security;
alter table audit_log enable row level security;

create policy organization_read on organizations for select using (id = current_organization_id());
create policy profiles_org_access on profiles for select using (organization_id = current_organization_id());

-- Per l'MVP, applicare policy equivalenti organization_id = current_organization_id()
-- alle tabelle operative. Le operazioni di scrittura devono essere limitate per ruolo
-- tramite funzioni RPC security definer e non esposte direttamente al frontend.
