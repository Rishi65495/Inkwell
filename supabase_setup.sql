-- 1. Ensure the 'articles' table exists and contains all required columns
CREATE TABLE IF NOT EXISTS public.articles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT,
  content TEXT,
  excerpt TEXT,
  category TEXT,
  status TEXT DEFAULT 'pending',
  author_id UUID,
  author_name TEXT,
  author_initials TEXT,
  cover_url TEXT,
  seo_title TEXT,
  seo_desc TEXT,
  read_time INTEGER DEFAULT 1,
  is_admin BOOLEAN DEFAULT false,
  published_at TIMESTAMPTZ,
  likes INTEGER DEFAULT 0,
  views INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Ensure individual columns exist if the table already existed but was missing columns
ALTER TABLE public.articles ADD COLUMN IF NOT EXISTS cover_url TEXT;
ALTER TABLE public.articles ADD COLUMN IF NOT EXISTS seo_title TEXT;
ALTER TABLE public.articles ADD COLUMN IF NOT EXISTS seo_desc TEXT;
ALTER TABLE public.articles ADD COLUMN IF NOT EXISTS read_time INTEGER DEFAULT 1;
ALTER TABLE public.articles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT false;
ALTER TABLE public.articles ADD COLUMN IF NOT EXISTS published_at TIMESTAMPTZ;
ALTER TABLE public.articles ADD COLUMN IF NOT EXISTS likes INTEGER DEFAULT 0;
ALTER TABLE public.articles ADD COLUMN IF NOT EXISTS views INTEGER DEFAULT 0;

-- 2. Create the Storage Buckets in Supabase if they do not exist
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('covers', 'covers', true),
  ('inline-images', 'inline-images', true),
  ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Drop policies if they already exist to avoid duplicate name conflicts
DROP POLICY IF EXISTS "Public Read Access" ON storage.objects;
DROP POLICY IF EXISTS "Allow Public Uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow Public Updates" ON storage.objects;
DROP POLICY IF EXISTS "Allow Public Deletions" ON storage.objects;

-- 3. Set up Storage Policies to allow public read access
CREATE POLICY "Public Read Access" 
ON storage.objects FOR SELECT 
USING (bucket_id IN ('covers', 'inline-images', 'avatars'));

-- 4. Set up Storage Policies to allow image uploads (inserts)
CREATE POLICY "Allow Public Uploads" 
ON storage.objects FOR INSERT 
WITH CHECK (bucket_id IN ('covers', 'inline-images', 'avatars'));

-- 5. Set up Storage Policies to allow image updates
CREATE POLICY "Allow Public Updates" 
ON storage.objects FOR UPDATE 
WITH CHECK (bucket_id IN ('covers', 'inline-images', 'avatars'));

-- 6. Set up Storage Policies to allow image deletions
CREATE POLICY "Allow Public Deletions" 
ON storage.objects FOR DELETE 
USING (bucket_id IN ('covers', 'inline-images', 'avatars'));
