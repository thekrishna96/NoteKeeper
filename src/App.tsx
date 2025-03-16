import React, { useEffect, useState } from 'react';
import { supabase } from './lib/supabase';
import { Toaster } from 'react-hot-toast';
import Auth from './components/Auth';
import Notes from './components/Notes';
import { LogOut } from 'lucide-react';

function App() {
  const [session, setSession] = useState<any>(null);

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
    });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
    });

    return () => subscription.unsubscribe();
  }, []);

  const handleSignOut = async () => {
    await supabase.auth.signOut();
  };

  return (
    <>
      <Toaster position="top-right" />
      {!session ? (
        <Auth />
      ) : (
        <div className="min-h-screen bg-gray-100">
          <nav className="bg-white shadow-sm">
            <div className="max-w-4xl mx-auto px-4 py-3 flex justify-between items-center">
              <h1 className="text-xl font-bold text-gray-800">CloudNoteKeeper</h1>
              <div className="flex items-center gap-4">
                <span className="text-gray-600">{session.user.email}</span>
                <button
                  onClick={handleSignOut}
                  className="flex items-center gap-2 text-gray-600 hover:text-gray-800"
                >
                  <LogOut className="h-5 w-5" />
                  Sign Out
                </button>
              </div>
            </div>
          </nav>
          <Notes />
        </div>
      )}
    </>
  );
}

export default App;