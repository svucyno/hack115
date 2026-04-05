CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  -- If this is the old app version (missing role metadata), gracefully skip the trigger to avoid crashing
  IF new.raw_user_meta_data IS NULL OR new.raw_user_meta_data->>'role' IS NULL THEN
    RETURN new;
  END IF;

  -- Insert into profiles
  INSERT INTO public.profiles (id, role, name)
  VALUES (
    new.id,
    new.raw_user_meta_data->>'role',
    new.raw_user_meta_data->>'name'
  );

  -- If they are a patient, insert into patients table
  IF new.raw_user_meta_data->>'role' = 'patient' THEN
    INSERT INTO public.patients (profile_id)
    VALUES (new.id);
  END IF;

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
