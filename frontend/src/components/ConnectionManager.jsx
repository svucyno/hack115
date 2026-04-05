import { useState, useEffect } from "react";
import { supabase } from "../supabaseClient";

export default function ConnectionManager() {
  const [connections, setConnections] = useState([]);
  const [availableUsers, setAvailableUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [patientRecord, setPatientRecord] = useState(null);
  const [debugInfo, setDebugInfo] = useState("");

  useEffect(() => {
    async function loadData() {
      setLoading(true);
      let debug = "";

      const { data: { session } } = await supabase.auth.getSession();
      if (!session) {
        debug += "No session found.\n";
        setDebugInfo(debug);
        setLoading(false);
        return;
      }

      const patientProfileId = session.user.id;
      debug += `User ID: ${patientProfileId}\n`;

      // Get the patients.id first
      const { data: patientData, error: patientErr } = await supabase
        .from('patients')
        .select('id')
        .eq('profile_id', patientProfileId)
        .single();

      if (patientErr || !patientData) {
        debug += `Patient record error: ${patientErr?.message || "No patient record found"}\n`;
        debug += `Hint: The profiles/patients table may have RLS blocking reads. Run the supabase_rls_policies.sql script.\n`;
        setDebugInfo(debug);
        setLoading(false);
        return;
      }

      debug += `Patient record ID: ${patientData.id}\n`;
      setPatientRecord(patientData);
      const pid = patientData.id;

      // Fetch Family Links
      const { data: familyLinks, error: famErr } = await supabase
        .from('family_patient_links')
        .select('id, family_profile_id')
        .eq('patient_id', pid);

      debug += `Family links: ${familyLinks?.length || 0} (error: ${famErr?.message || "none"})\n`;

      // Fetch Doctor Links
      const { data: doctorLinks, error: docErr } = await supabase
        .from('doctor_patient_links')
        .select('id, doctor_profile_id')
        .eq('patient_id', pid);

      debug += `Doctor links: ${doctorLinks?.length || 0} (error: ${docErr?.message || "none"})\n`;

      // For each link, fetch the profile name separately (avoids join issues with RLS)
      const allConns = [];

      for (const link of (familyLinks || [])) {
        const { data: prof } = await supabase
          .from('profiles')
          .select('id, name, role')
          .eq('id', link.family_profile_id)
          .single();
        allConns.push({ id: link.id, type: 'family', profile: prof || { name: 'Unknown', role: 'family' } });
      }

      for (const link of (doctorLinks || [])) {
        const { data: prof } = await supabase
          .from('profiles')
          .select('id, name, role')
          .eq('id', link.doctor_profile_id)
          .single();
        allConns.push({ id: link.id, type: 'doctor', profile: prof || { name: 'Unknown', role: 'doctor' } });
      }

      setConnections(allConns);

      // Fetch all eligible users to link (family & doctors)
      const { data: otherUsers, error: profilesErr } = await supabase
        .from('profiles')
        .select('id, name, role')
        .in('role', ['family', 'doctor']);

      debug += `Available users query: ${otherUsers?.length || 0} found (error: ${profilesErr?.message || "none"})\n`;

      if (profilesErr) {
        debug += `⚠ RLS is blocking the profiles read. Run supabase_rls_policies.sql in your Supabase SQL Editor!\n`;
      }

      setAvailableUsers(otherUsers || []);
      setDebugInfo(debug);
      setLoading(false);
    }

    loadData();
  }, []);

  const handleLinkUser = async (userId, role) => {
    if (!patientRecord) return;

    try {
      let result;
      if (role === 'family') {
        result = await supabase.from('family_patient_links').insert([{
          family_profile_id: userId,
          patient_id: patientRecord.id,
          relationship: 'Family Member'
        }]);
      } else if (role === 'doctor') {
        result = await supabase.from('doctor_patient_links').insert([{
          doctor_profile_id: userId,
          patient_id: patientRecord.id
        }]);
      }

      if (result?.error) {
        alert('Error linking user: ' + result.error.message);
        return;
      }

      alert('Successfully linked user!');
      window.location.reload();
    } catch (e) {
      alert('Error linking user: ' + e.message);
    }
  };

  const handleRemoveLink = async (id, type) => {
    try {
      let result;
      if (type === 'family') {
        result = await supabase.from('family_patient_links').delete().eq('id', id);
      } else {
        result = await supabase.from('doctor_patient_links').delete().eq('id', id);
      }

      if (result?.error) {
        alert("Error removing link: " + result.error.message);
        return;
      }

      setConnections(c => c.filter(x => x.id !== id));
    } catch (e) {
      alert("Error removing link: " + e.message);
    }
  };

  if (loading) return <div className="card">Loading connections...</div>;

  // Filter out already linked users
  const linkedProfileIds = connections.map(c => c.profile?.id);
  const unlinkedAvailable = availableUsers.filter(u => !linkedProfileIds.includes(u.id));

  return (
    <div className="card">
      <div className="section-header">
        <span className="icon">🔗</span>
        Manage Permissions
      </div>
      <p style={{ fontSize: '0.85rem', color: 'var(--muted)', marginBottom: '1rem' }}>
        Control who can view your live vitals and receive emergency alerts.
      </p>

      {connections.length > 0 ? (
        <ul style={{ listStyle: 'none', padding: 0, marginBottom: '1rem' }}>
          {connections.map(c => (
            <li key={c.id} style={{ display: 'flex', justifyContent: 'space-between', background: 'rgba(255,255,255,0.05)', padding: '0.5rem 0.75rem', borderRadius: '6px', marginBottom: '0.5rem', alignItems: 'center' }}>
              <div>
                <strong style={{ color: 'var(--text-bright)' }}>{c.profile?.name}</strong>{' '}
                <span style={{ fontSize: '0.75rem', color: 'var(--neon-cyan)', background: 'rgba(0,255,255,0.08)', padding: '0.1rem 0.4rem', borderRadius: '4px' }}>
                  {c.type}
                </span>
              </div>
              <button
                onClick={() => handleRemoveLink(c.id, c.type)}
                style={{ background: 'none', border: '1px solid var(--danger)', color: 'var(--danger)', cursor: 'pointer', fontSize: '0.75rem', padding: '0.2rem 0.5rem', borderRadius: '4px' }}
              >
                Revoke
              </button>
            </li>
          ))}
        </ul>
      ) : (
        <p style={{ fontSize: '0.85rem', color: 'var(--warn)', marginBottom: '1rem' }}>No connections linked yet!</p>
      )}

      <div style={{ marginTop: '1rem', borderTop: '1px solid rgba(255,255,255,0.1)', paddingTop: '1rem' }}>
        <strong style={{ fontSize: '0.85rem', color: 'var(--text-bright)' }}>Add Connection</strong>
        {unlinkedAvailable.length > 0 ? (
          <ul style={{ listStyle: 'none', padding: 0, marginTop: '0.5rem' }}>
            {unlinkedAvailable.map(u => (
              <li key={u.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem', padding: '0.4rem 0', borderBottom: '1px solid rgba(255,255,255,0.05)' }}>
                <div style={{ fontSize: '0.85rem' }}>
                  <span style={{ color: 'var(--text-bright)' }}>{u.name}</span>{' '}
                  <span style={{ fontSize: '0.72rem', color: 'var(--muted)' }}>({u.role})</span>
                </div>
                <button
                  type="button"
                  onClick={() => handleLinkUser(u.id, u.role)}
                  style={{ background: 'var(--neon-cyan)', color: 'black', border: 'none', padding: '0.25rem 0.6rem', borderRadius: '4px', fontSize: '0.75rem', cursor: 'pointer', fontWeight: 600 }}
                >
                  Authorize
                </button>
              </li>
            ))}
          </ul>
        ) : (
          <p style={{ fontSize: '0.8rem', color: 'var(--muted)', marginTop: '0.5rem' }}>No other users available to link.</p>
        )}
      </div>

      {/* Debug info - shows what's happening with queries */}
      {debugInfo && (
        <details style={{ marginTop: '1rem', borderTop: '1px solid rgba(255,255,255,0.05)', paddingTop: '0.5rem' }}>
          <summary style={{ fontSize: '0.72rem', color: 'var(--muted-dim)', cursor: 'pointer' }}>
            Debug Info
          </summary>
          <pre style={{ fontSize: '0.7rem', color: 'var(--muted)', whiteSpace: 'pre-wrap', marginTop: '0.5rem', background: 'rgba(0,0,0,0.3)', padding: '0.5rem', borderRadius: '4px' }}>
            {debugInfo}
          </pre>
        </details>
      )}
    </div>
  );
}
