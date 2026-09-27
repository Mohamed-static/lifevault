-- ============================================
-- POLICIES DU BUCKET vault-files
-- ============================================

-- Les utilisateurs peuvent voir uniquement leurs propres fichiers
-- (fichiers rangés sous un dossier nommé avec leur user_id)
create policy "Users can view own files"
on storage.objects for select
using (
  bucket_id = 'vault-files'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- Les utilisateurs peuvent uploader uniquement dans leur propre dossier
create policy "Users can upload own files"
on storage.objects for insert
with check (
  bucket_id = 'vault-files'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- Les utilisateurs peuvent supprimer uniquement leurs propres fichiers
create policy "Users can delete own files"
on storage.objects for delete
using (
  bucket_id = 'vault-files'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- Les utilisateurs peuvent mettre à jour uniquement leurs propres fichiers
create policy "Users can update own files"
on storage.objects for update
using (
  bucket_id = 'vault-files'
  and (storage.foldername(name))[1] = auth.uid()::text
);