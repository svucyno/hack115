-- ============================================================
-- Lifeguard AI: RLS Policies for Multi-User Dashboard
-- Run this ENTIRE script in your Supabase SQL Editor
-- (Dashboard → SQL Editor → New Query → Paste → Run)
-- ============================================================

-- ── 1. PROFILES TABLE ──
-- Allow all authenticated users to read all profiles
-- (needed so patients can see family/doctor names in ConnectionManager)
DROP POLICY IF EXISTS "Authenticated users can read all profiles" ON public.profiles;
CREATE POLICY "Authenticated users can read all profiles"
  ON public.profiles FOR SELECT
  USING (auth.role() = 'authenticated');

-- Allow users to update their own profile
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- Allow insert (needed by the trigger, but also by direct signup fallback)
DROP POLICY IF EXISTS "Allow insert for authenticated" ON public.profiles;
CREATE POLICY "Allow insert for authenticated"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ── 2. PATIENTS TABLE ──
DROP POLICY IF EXISTS "Patients can read own record" ON public.patients;
CREATE POLICY "Patients can read own record"
  ON public.patients FOR SELECT
  USING (auth.uid() = profile_id);

DROP POLICY IF EXISTS "Allow insert for own patient record" ON public.patients;
CREATE POLICY "Allow insert for own patient record"
  ON public.patients FOR INSERT
  WITH CHECK (auth.uid() = profile_id);

-- ── 3. VITALS TABLE ──
-- Patient can insert their own vitals
DROP POLICY IF EXISTS "Patient can insert own vitals" ON public.vitals;
CREATE POLICY "Patient can insert own vitals"
  ON public.vitals FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.patients
      WHERE patients.id = vitals.patient_id
        AND patients.profile_id = auth.uid()
    )
  );

-- Patient can read own vitals
DROP POLICY IF EXISTS "Patient can read own vitals" ON public.vitals;
CREATE POLICY "Patient can read own vitals"
  ON public.vitals FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.patients
      WHERE patients.id = vitals.patient_id
        AND patients.profile_id = auth.uid()
    )
  );

-- Family can read linked patient's vitals
DROP POLICY IF EXISTS "Family can read linked patient vitals" ON public.vitals;
CREATE POLICY "Family can read linked patient vitals"
  ON public.vitals FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.family_patient_links
      WHERE family_patient_links.patient_id = vitals.patient_id
        AND family_patient_links.family_profile_id = auth.uid()
    )
  );

-- Doctor can read linked patient's vitals
DROP POLICY IF EXISTS "Doctor can read linked patient vitals" ON public.vitals;
CREATE POLICY "Doctor can read linked patient vitals"
  ON public.vitals FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.doctor_patient_links
      WHERE doctor_patient_links.patient_id = vitals.patient_id
        AND doctor_patient_links.doctor_profile_id = auth.uid()
    )
  );

-- ── 4. LOCATIONS TABLE ──
DROP POLICY IF EXISTS "Patient can insert own locations" ON public.locations;
CREATE POLICY "Patient can insert own locations"
  ON public.locations FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.patients
      WHERE patients.id = locations.patient_id
        AND patients.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Patient can read own locations" ON public.locations;
CREATE POLICY "Patient can read own locations"
  ON public.locations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.patients
      WHERE patients.id = locations.patient_id
        AND patients.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Family can read linked patient locations" ON public.locations;
CREATE POLICY "Family can read linked patient locations"
  ON public.locations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.family_patient_links
      WHERE family_patient_links.patient_id = locations.patient_id
        AND family_patient_links.family_profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Doctor can read linked patient locations" ON public.locations;
CREATE POLICY "Doctor can read linked patient locations"
  ON public.locations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.doctor_patient_links
      WHERE doctor_patient_links.patient_id = locations.patient_id
        AND doctor_patient_links.doctor_profile_id = auth.uid()
    )
  );

-- ── 5. EMERGENCY ALERTS TABLE ──
DROP POLICY IF EXISTS "Patient can insert own alerts" ON public.emergency_alerts;
CREATE POLICY "Patient can insert own alerts"
  ON public.emergency_alerts FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.patients
      WHERE patients.id = emergency_alerts.patient_id
        AND patients.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Patient can read own alerts" ON public.emergency_alerts;
CREATE POLICY "Patient can read own alerts"
  ON public.emergency_alerts FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.patients
      WHERE patients.id = emergency_alerts.patient_id
        AND patients.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Family can read linked patient alerts" ON public.emergency_alerts;
CREATE POLICY "Family can read linked patient alerts"
  ON public.emergency_alerts FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.family_patient_links
      WHERE family_patient_links.patient_id = emergency_alerts.patient_id
        AND family_patient_links.family_profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Doctor can read linked patient alerts" ON public.emergency_alerts;
CREATE POLICY "Doctor can read linked patient alerts"
  ON public.emergency_alerts FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.doctor_patient_links
      WHERE doctor_patient_links.patient_id = emergency_alerts.patient_id
        AND doctor_patient_links.doctor_profile_id = auth.uid()
    )
  );

-- ── 6. FAMILY_PATIENT_LINKS TABLE ──
-- Patient can manage their own links
DROP POLICY IF EXISTS "Patient can read own family links" ON public.family_patient_links;
CREATE POLICY "Patient can read own family links"
  ON public.family_patient_links FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.patients
      WHERE patients.id = family_patient_links.patient_id
        AND patients.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Patient can insert family links" ON public.family_patient_links;
CREATE POLICY "Patient can insert family links"
  ON public.family_patient_links FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.patients
      WHERE patients.id = family_patient_links.patient_id
        AND patients.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Patient can delete family links" ON public.family_patient_links;
CREATE POLICY "Patient can delete family links"
  ON public.family_patient_links FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.patients
      WHERE patients.id = family_patient_links.patient_id
        AND patients.profile_id = auth.uid()
    )
  );

-- Family member can read their own links
DROP POLICY IF EXISTS "Family can read own links" ON public.family_patient_links;
CREATE POLICY "Family can read own links"
  ON public.family_patient_links FOR SELECT
  USING (family_profile_id = auth.uid());

-- ── 7. DOCTOR_PATIENT_LINKS TABLE ──
DROP POLICY IF EXISTS "Patient can read own doctor links" ON public.doctor_patient_links;
CREATE POLICY "Patient can read own doctor links"
  ON public.doctor_patient_links FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.patients
      WHERE patients.id = doctor_patient_links.patient_id
        AND patients.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Patient can insert doctor links" ON public.doctor_patient_links;
CREATE POLICY "Patient can insert doctor links"
  ON public.doctor_patient_links FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.patients
      WHERE patients.id = doctor_patient_links.patient_id
        AND patients.profile_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Patient can delete doctor links" ON public.doctor_patient_links;
CREATE POLICY "Patient can delete doctor links"
  ON public.doctor_patient_links FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.patients
      WHERE patients.id = doctor_patient_links.patient_id
        AND patients.profile_id = auth.uid()
    )
  );

-- Doctor can read their own links
DROP POLICY IF EXISTS "Doctor can read own links" ON public.doctor_patient_links;
CREATE POLICY "Doctor can read own links"
  ON public.doctor_patient_links FOR SELECT
  USING (doctor_profile_id = auth.uid());

-- ── 8. ENABLE RLS ON ALL TABLES (idempotent) ──
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vitals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.emergency_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_patient_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.doctor_patient_links ENABLE ROW LEVEL SECURITY;

-- ── 9. ENABLE REALTIME (skip if already added) ──
DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.vitals;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.locations;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.emergency_alerts;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
