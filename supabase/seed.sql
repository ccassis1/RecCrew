insert into profiles (id, email, airline, points)
values
  ('00000000-0000-0000-0000-000000000001', 'jane@delta.com', 'delta.com', 50),
  ('00000000-0000-0000-0000-000000000002', 'mark@united.com', 'united.com', 70);

insert into recommendations (user_id, business_name, category, rating, city)
values
  ('00000000-0000-0000-0000-000000000001', 'Crew Cafe', 'Food', 5, 'New York'),
  ('00000000-0000-0000-0000-000000000002', 'Sky Bar', 'Nightlife', 4, 'San Diego');
