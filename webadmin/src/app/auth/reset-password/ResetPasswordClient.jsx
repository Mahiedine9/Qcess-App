'use client'

import React from 'react';
import {FaEye, FaRegEyeSlash} from "react-icons/fa";
import {useRouter, useSearchParams } from 'next/navigation'
import { API_BASE_URL } from '@/lib/api';
const ResetPassword = () => {
    const searchParams = useSearchParams()

    const router = useRouter() ;
    const tokenParam  = searchParams.get("token");
    const token = tokenParam ?? "";

    const [newPassword, setNewPassword] = React.useState("");
    const [confirmPassword, setConfirmPassword] = React.useState("");
    const [loading, setLoading] = React.useState(false);
    const [error, setError] = React.useState(null);
    const [message, setMessage] = React.useState(null);
    const [show, setShow] = React.useState(false);

    async  function handleSubmit(e) {
        e.preventDefault();
        setMessage(null);
        setError(null);
        if (!token) {
            setError("Lien de réinistialisation invalide ou manquant");
            return ;
        }
        if (newPassword !== confirmPassword) {
            setError("Les mots de passe ne correspondent pas.") ;
            return ;
        }
        setLoading(true);

        try {
            const res = await fetch(`${API_BASE_URL}/auth/reset-password`, {
                method: 'POST',
                headers: {"Content-Type": "application/json"},
                body: JSON.stringify({token, newPassword}),
            });
            const body =await  res.json().catch(() => null);
            if (!res.ok) {
                throw new Error(body?.message || "Une erreur est survenue.");
            }

            setMessage("Mot de passe réinitialisé avec succès. Vous pouvez maintenant vous connecter.");
        }catch (err) {
            setError(err.message || "Erreur lors de la réinitialisation du mot de passe");

        }finally {
            setLoading(false);
        }
    }

    if (!token) {
        return (

            <div className="h-screen w-full bg-[#E0E7FF] flex items-center justify-center">
                <div className="w-full max-w-md rounded-2xl bg-white p-6 shadow-md border border-white text-center">
                    <h1 className="text-2xl font-bold text-[#155DFC] mb-2">Qcess</h1>
                    <p className="text-md text-gray-400 mb-4">
                        Système de gestion de bâtiment modulaire
                    </p>
                    <p className="text-sm text-red-600 mb-4">
                        Lien de réinitialisation invalide ou expiré.
                    </p>
                    <button
                        type="button"
                        onClick={() => router.push("/auth/forgot-password")}
                        className="text-sm text-[#030213] hover:underline"
                    >
                        Demander un nouveau lien
                    </button>
                </div>
            </div>
        );
    }
    return (
        <div className="h-screen w-full bg-[#E0E7FF] flex items-center justify-center">
            <div className="w-full max-w-md rounded-2xl bg-white p-6 shadow-md border border-white">

                <div className="text-center mb-4">
                    <h1 className=" text-2xl font-bold text-[#155DFC]">Qcess</h1>
                    <p className="text-md text-gray-400">
                        Système de gestion de bâtiment modulaire

                    </p>

                </div>

                <h2 className=" text-lg font-semibold mb-2 text-center text-gray-500">
                    Nouveau mot de passe
                </h2>
                <p className="text-sm text-gray-600 mb-4 text-center">
                    Choisissez un nouveau mot de passe pour votre compte administrateur.

                </p>

                <form className="flex flex-col gap-4">

                    <div className="flex flex-col gap-1 relative">
                        <label className="block text-md font-medium">
                            Nouveau mot de passe
                        </label>
                        <input
                            id="newPassword"
                            name="newPassword"
                            type={show?"text" : "password"}
                            required
                            value={newPassword}
                            onChange={(e) => setNewPassword(e.target.value)}
                            className="w-full rounded-md bg-[#F3F3F5] px-3 py-2
                focus:outline-none focus:ring-1 focus:border-gray-300 transition"

                        />
                        <button
                            type="button"
                            onClick={() => setShow(!show)}
                            className="absolute right-3 top-9 text-gray-500 hover:text-black transition" aria-label={show ? "Masquer le mot de passe" : "Afficher le mot de passe"}
                        >
                            {show ? <FaRegEyeSlash/> : <FaEye/>}
                        </button>
                    </div>

                    <div className="flex flex-col gap-1 relative ">
                        <label htmlFor="confirmPassword" className="block text-md font-medium">
                            Confirmer le mot de passe
                        </label>
                        <input
                            id="confirmPassword"
                            name="confirmPassword"
                            type={show ? "text" : "password"}
                            required
                            value={confirmPassword}
                            onChange={(e) => setConfirmPassword(e.target.value)}
                            className="w-full rounded-md bg-[#F3F3F5] px-3 py-2
                focus:outline-none focus:ring-1 focus:border-gray-300 transition"

                        />
                        <button
                            type="button"

                            onClick={() => setShow(!show)}
                            className="absolute right-3 top-9 text-gray-500 hover:text-black transition" aria-label={show ? "Masquer le mot de passe" : "Afficher le mot de passe"}
                        >
                            {show ? <FaRegEyeSlash/> : <FaEye/>}
                        </button>
                    </div>
                    {message && <p className="text-sm text-green-600">{message}</p>}
                    {error && <p className="text-sm text-red-600">{error}</p>}

                    <button
                        type="submit"
                        onClick={handleSubmit}
                        disabled={loading}
                        className="w-full rounded-md bg-[#030213] text-white text-lg font-medium py-2
               transition-all duration-300 ease-in-out
               hover:bg-white hover:text-[#030213] hover:border hover:border-[#030213]
               active:scale-95 disabled:opacity-60 disabled:cursor-not-allowed"
                    >
                        {loading ? "Réinitialisation..." : "Changer le mot de passe"}
                    </button>

                </form>

                <div className="mt-4 text-center">
                    <button
                        type="button"
                        onClick={() => router.push("/auth/login-register")}
                        className="text-sm text-gray-600 hover:underline cursor-pointer"
                    >
                        ← Retour à la connexion
                    </button>
                </div>
            </div>


        </div>
    );
};

export default ResetPassword;
