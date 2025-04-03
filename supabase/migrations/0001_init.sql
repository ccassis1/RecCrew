-- Enable UUID generation
create extension if not exists "uuid-ossp";

-- USERS / PROFILES TABLE (linked to Supabase auth.users)
create table profiles (
  id uuid primary key references auth.users on delete cascade,
  email text not null,
  airline text not null,
  preferences jsonb,
  points int default 0,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- RECOMMENDATIONS TABLE
create table recommendations (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references profiles(id) on delete cascade,
  business_name text not null,
  category text,
  tags text[],
  review text,
  rating int check (rating between 1 and 5),
  crew_discount boolean default false,
  city text,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- LAYOVER EVENTS (detected from calendar or entered manually)
create table layovers (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references profiles(id) on delete cascade,
  city text,
  arrival_time timestamp,
  departure_time timestamp,
  detected boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- POINTS LOG (earn and redeem activity)
create table points_log (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references profiles(id) on delete cascade,
  action text, -- e.g., "add_rec", "upload_photo"
  points int,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- PHOTO STORAGE (you will store media in Supabase Storage and link here)
create table photos (
  id uuid primary key default uuid_generate_v4(),
  recommendation_id uuid references recommendations(id) on delete cascade,
  url text not null,
  uploaded_by uuid references profiles(id),
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- FLAGGED REVIEWS (moderation)
create table flagged_reviews (
  id uuid primary key default uuid_generate_v4(),
  recommendation_id uuid references recommendations(id),
  reason text,
  flagged_by uuid references profiles(id),
  created_at timestamp with time zone default timezone('utc'::text, now())
);

alter table profiles enable row level security;
alter table recommendations enable row level security;
alter table layovers enable row level security;
alter table points_log enable row level security;
alter table photos enable row level security;
alter table flagged_reviews enable row level security;

-- ✅ PROFILES
create policy "Users can view their profile"
on profiles for select
using (auth.uid() = id);

create policy "Users can insert their profile"
on profiles for insert
with check (auth.uid() = id);

create policy "Users can update their profile"
on profiles for update
with check (auth.uid() = id);

-- ✅ RECOMMENDATIONS
create policy "Users can view all recommendations"
on recommendations for select
using (true);

create policy "Users can insert their own recommendation"
on recommendations for insert
with check (auth.uid() = user_id);

create policy "Users can update their own recommendation"
on recommendations for update
using (auth.uid() = user_id);

create policy "Users can delete their own recommendation"
on recommendations for delete
using (auth.uid() = user_id);

-- ✅ LAYOVERS
create policy "Users can view their own layovers"
on layovers for select
using (auth.uid() = user_id);

create policy "Users can insert their layovers"
on layovers for insert
with check (auth.uid() = user_id);

create policy "Users can update their layovers"
on layovers for update
with check (auth.uid() = user_id);

create policy "Users can delete their layovers"
on layovers for delete
using (auth.uid() = user_id);


-- ✅ POINTS LOG
create policy "Users can view their points history"
on points_log for select
using (auth.uid() = user_id);

create policy "System can insert log entries"
on points_log for insert
with check (auth.uid() = user_id);

-- ✅ PHOTOS
create policy "Users can view all photos"
on photos for select
using (true);

create policy "Users can upload photos to their recs"
on photos for insert
with check (auth.uid() = uploaded_by);

create policy "Users can delete their photos"
on photos for delete
using (auth.uid() = uploaded_by);

-- ✅ FLAGGED REVIEWS
create policy "Users can flag reviews"
on flagged_reviews for insert
with check (auth.uid() = flagged_by);

create policy "Moderators can view all flags"
on flagged_reviews for select
using (true);  -- Add role check later


-- Trigger function to create profile
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, airline)
  values (new.id, new.email, split_part(new.email, '@', 2));
  return new;
end;
$$ language plpgsql security definer;

-- Trigger
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();
