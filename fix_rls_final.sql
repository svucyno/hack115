-- 1. Safely drop conflicting insert policies on profiles
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Give public insert access to profiles" ON profiles;

-- 2. Create a bulletproof insert policy for profiles that allows the signup trigger
CREATE POLICY "Give public insert access to profiles" ON profiles FOR INSERT WITH CHECK (true);

-- 3. Safely drop conflicting insert policies on patients
DROP POLICY IF EXISTS "Users can insert own patient" ON patients;
DROP POLICY IF EXISTS "Give public insert access to patients" ON patients;

-- 4. Create an insert policy for patients
CREATE POLICY "Give public insert access to patients" ON patients FOR INSERT WITH CHECK (true);
