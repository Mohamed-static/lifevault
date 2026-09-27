-- 1. Categories par defaut a l'inscription
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'full_name', ''));

  insert into public.categories (user_id, name, icon, is_default) values
    (new.id, 'Documents', 'description', true),
    (new.id, 'Reçus', 'receipt', true),
    (new.id, 'Garanties', 'verified_user', true),
    (new.id, 'Billets', 'confirmation_number', true),
    (new.id, 'Notes', 'note', true),
    (new.id, 'Autres', 'folder', true);

  return new;
end;
$$ language plpgsql security definer set search_path = public;

-- 2. Rattrapage pour les comptes deja existants sans categories
insert into public.categories (user_id, name, icon, is_default)
select u.id, c.name, c.icon, true
from auth.users u
cross join (values
  ('Documents', 'description'),
  ('Reçus', 'receipt'),
  ('Garanties', 'verified_user'),
  ('Billets', 'confirmation_number'),
  ('Notes', 'note'),
  ('Autres', 'folder')
) as c(name, icon)
where not exists (select 1 from public.categories x where x.user_id = u.id);

-- 3. Limites serveur du bucket (taille + types autorises)
update storage.buckets
set file_size_limit = 10485760,
    allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp', 'application/pdf']
where id = 'vault-files';

-- 4. Policies plus strictes : on ne peut lier que ses propres donnees
drop policy "Users can insert own vault items" on public.vault_items;
drop policy "Users can update own vault items" on public.vault_items;

create policy "Users can insert own vault items" on public.vault_items for insert
with check (
  auth.uid() = user_id
  and (category_id is null or exists (
    select 1 from public.categories c where c.id = category_id and c.user_id = auth.uid()
  ))
);

create policy "Users can update own vault items" on public.vault_items for update
using (auth.uid() = user_id)
with check (
  auth.uid() = user_id
  and (category_id is null or exists (
    select 1 from public.categories c where c.id = category_id and c.user_id = auth.uid()
  ))
);

drop policy "Users can insert own attachments" on public.attachments;
create policy "Users can insert own attachments" on public.attachments for insert
with check (
  auth.uid() = user_id
  and exists (select 1 from public.vault_items v where v.id = vault_item_id and v.user_id = auth.uid())
);

drop policy "Users can insert own reminders" on public.reminders;
create policy "Users can insert own reminders" on public.reminders for insert
with check (
  auth.uid() = user_id
  and exists (select 1 from public.vault_items v where v.id = vault_item_id and v.user_id = auth.uid())
);