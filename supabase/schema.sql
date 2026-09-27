-- ============================================
-- LIFEVAULT — SCHEMA COMPLET
-- ============================================

-- Extension pour UUID
create extension if not exists "uuid-ossp";

-- ============================================
-- TABLE: profiles (liée à auth.users de Supabase)
-- ============================================
create table public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  full_name text,
  email text not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.profiles enable row level security;

create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

create policy "Users can insert own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

-- ============================================
-- TABLE: categories
-- ============================================
create table public.categories (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  icon text,
  is_default boolean default false,
  created_at timestamptz default now()
);

alter table public.categories enable row level security;

create policy "Users can view own categories"
  on public.categories for select
  using (auth.uid() = user_id);

create policy "Users can insert own categories"
  on public.categories for insert
  with check (auth.uid() = user_id);

create policy "Users can update own categories"
  on public.categories for update
  using (auth.uid() = user_id);

create policy "Users can delete own categories"
  on public.categories for delete
  using (auth.uid() = user_id);

-- ============================================
-- TABLE: vault_items
-- ============================================
create table public.vault_items (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  category_id uuid references public.categories(id) on delete set null,
  title text not null,
  description text,
  expiration_date date,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index idx_vault_items_user_id on public.vault_items(user_id);
create index idx_vault_items_expiration on public.vault_items(expiration_date);
create index idx_vault_items_category on public.vault_items(category_id);

alter table public.vault_items enable row level security;

create policy "Users can view own vault items"
  on public.vault_items for select
  using (auth.uid() = user_id);

create policy "Users can insert own vault items"
  on public.vault_items for insert
  with check (auth.uid() = user_id);

create policy "Users can update own vault items"
  on public.vault_items for update
  using (auth.uid() = user_id);

create policy "Users can delete own vault items"
  on public.vault_items for delete
  using (auth.uid() = user_id);

-- ============================================
-- TABLE: tags
-- ============================================
create table public.tags (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  created_at timestamptz default now(),
  unique(user_id, name)
);

alter table public.tags enable row level security;

create policy "Users can view own tags"
  on public.tags for select
  using (auth.uid() = user_id);

create policy "Users can insert own tags"
  on public.tags for insert
  with check (auth.uid() = user_id);

create policy "Users can delete own tags"
  on public.tags for delete
  using (auth.uid() = user_id);

-- ============================================
-- TABLE: vault_item_tags (relation many-to-many)
-- ============================================
create table public.vault_item_tags (
  vault_item_id uuid references public.vault_items(id) on delete cascade,
  tag_id uuid references public.tags(id) on delete cascade,
  primary key (vault_item_id, tag_id)
);

alter table public.vault_item_tags enable row level security;

create policy "Users can view own item tags"
  on public.vault_item_tags for select
  using (
    exists (
      select 1 from public.vault_items
      where vault_items.id = vault_item_tags.vault_item_id
      and vault_items.user_id = auth.uid()
    )
  );

create policy "Users can insert own item tags"
  on public.vault_item_tags for insert
  with check (
    exists (
      select 1 from public.vault_items
      where vault_items.id = vault_item_tags.vault_item_id
      and vault_items.user_id = auth.uid()
    )
  );

create policy "Users can delete own item tags"
  on public.vault_item_tags for delete
  using (
    exists (
      select 1 from public.vault_items
      where vault_items.id = vault_item_tags.vault_item_id
      and vault_items.user_id = auth.uid()
    )
  );

-- ============================================
-- TABLE: attachments (métadonnées des fichiers)
-- ============================================
create table public.attachments (
  id uuid default uuid_generate_v4() primary key,
  vault_item_id uuid references public.vault_items(id) on delete cascade not null,
  user_id uuid references auth.users(id) on delete cascade not null,
  file_path text not null,
  file_name text not null,
  mime_type text not null,
  file_size bigint not null,
  created_at timestamptz default now()
);

create index idx_attachments_vault_item on public.attachments(vault_item_id);

alter table public.attachments enable row level security;

create policy "Users can view own attachments"
  on public.attachments for select
  using (auth.uid() = user_id);

create policy "Users can insert own attachments"
  on public.attachments for insert
  with check (auth.uid() = user_id);

create policy "Users can delete own attachments"
  on public.attachments for delete
  using (auth.uid() = user_id);

-- ============================================
-- TABLE: reminders
-- ============================================
create table public.reminders (
  id uuid default uuid_generate_v4() primary key,
  vault_item_id uuid references public.vault_items(id) on delete cascade not null,
  user_id uuid references auth.users(id) on delete cascade not null,
  days_before integer not null,
  is_sent boolean default false,
  scheduled_date date,
  created_at timestamptz default now()
);

create index idx_reminders_vault_item on public.reminders(vault_item_id);
create index idx_reminders_user on public.reminders(user_id);
create index idx_reminders_scheduled on public.reminders(scheduled_date);

alter table public.reminders enable row level security;

create policy "Users can view own reminders"
  on public.reminders for select
  using (auth.uid() = user_id);

create policy "Users can insert own reminders"
  on public.reminders for insert
  with check (auth.uid() = user_id);

create policy "Users can update own reminders"
  on public.reminders for update
  using (auth.uid() = user_id);

create policy "Users can delete own reminders"
  on public.reminders for delete
  using (auth.uid() = user_id);

-- ============================================
-- TRIGGER: création automatique du profil à l'inscription
-- ============================================
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'full_name', ''));
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ============================================
-- TRIGGER: updated_at automatique
-- ============================================
create function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger set_updated_at_vault_items
  before update on public.vault_items
  for each row execute procedure public.handle_updated_at();

create trigger set_updated_at_profiles
  before update on public.profiles
  for each row execute procedure public.handle_updated_at();