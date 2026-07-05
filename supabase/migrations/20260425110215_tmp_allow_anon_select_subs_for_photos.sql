CREATE POLICY "tmp_photos_anon_select" ON activity_submissions FOR SELECT TO anon USING (true);
