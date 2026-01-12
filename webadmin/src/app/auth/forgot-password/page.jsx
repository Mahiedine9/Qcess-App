'use client';
import React from 'react';
import { API_BASE_URL } from '@/lib/api';

const ForgotPassword = () => {
    const [email, setEmail] = React.useState('');
    const [loading, setLoading] = React.useState(false);
    const [message, setMessage] = React.useState('');
    const [error, setError] = React.useState('');

    async  function handleSubmit(e) {
        e.preventDefault();
        setLoading(true);
        setMessage(null);
        setError(null);

        try {
            const res = await fetch(`${API_BASE_URL}/auth/forgot-password`, {
                method: 'POST',
                headers: {"Content-Type": "application/json"},
                body: JSON.stringify({email}),
            });

            if (!res.ok) {
                const body = await res.json().catch(() => null);
                throw new Error(body?.message || "Une erreur est survenue.");
            }

            setMessage("Si un compte administateur existe avec cet email, un lien de réinitialisation vous a été envoyé. ");
        }catch (err) {
            setError(err.message || "Erreur lors de la demande de réintialisation");
        }finally {
            setLoading(false);
        }
    }



  return (
      <div className="h-screen w-full  bg-[#E0E7FF] flex items-center justify-center">
          <div className=" w-full max-w-md rounded-2xl bg-white p-6 shadow-md border border-white " >
              <div className =' text-center mb-4 '>
                  <h1 className="text-2xl font-bold text-[#155DFC]">Qcess</h1>
                  <p className=" text-md text-gray-400">Système de gestion de bâtiment modulaire

                  </p>
                  <h2 className="text-md text-gray-500 mb-2 text-center">
                      Mot de passe oublié
                  </h2>
                 <p className=" text-sm text-gray-600 mb-4 text-center">
                     Entrez l&apos;adresse email de votre compte administrateur.
                     <br/>

                     Si un compte existe, vous recevrez un lien de réinitialisation.
                 </p>
              </div>
                  <form  className="flex flex-col gap-4">
                      <div className=" flex flex-col gap-1">

                          <label htmlFor="email" className="block text-md font-medium">
                          Email :
                          </label>
                          <input id="email" name="email" type="email" required  autoComplete="email" value={email}
                                 onChange={(e) => setEmail(e.target.value)} className="w-full rounded-md bg-[#F3F3F5]
                                 px-3 py-2  focus:outline-none focus:ring-1 focus:border-gray-300 transition"/>
                      </div>

                      {message && <p className="text-sm text-green-600">{message}</p>}
                      {error && <p className="text-sm text-red-600">{error}</p>}

                      <button onClick={handleSubmit} className=" w-full p-2  rounded-md bg-[#030213] text-lg font-medium text-white transition-all duration-300 ease-in-out
               hover:bg-white hover:text-[#030213] hover:border hover:border-[#030213]
               active:scale-95 disabled:opacity-60 disabled:cursor-not-allowed  ">
                          {loading ? "Envoi de lien ..." : "Envoyer le lien de réinitialisation"}
                      </button>
                  </form>






          </div>
      </div>
  );
};

export default ForgotPassword;