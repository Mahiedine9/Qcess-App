'use client'
import React, {useState} from 'react';
import "../../globals.css";
import { FaEye, FaRegEyeSlash  } from "react-icons/fa";
import {useRouter } from "next/navigation";
import { API_BASE_URL } from '@/lib/api';



const LoginRegister = () => {

    const [tab , setTab ] = useState("login");

    return (
            <div className="h-full w-full bg-[#E0E7FF] dark:bg-[#181818] flex items-center justify-center min-h-screen">
            <div className="w-full max-w-md rounded-2xl bg-white dark:bg-[#23232b] p-6 shadow-md border border-white dark:border-gray-700" >
                <div className =' text-center mb-4 '>
                <h1 className="text-2xl font-bold text-[#155DFC] dark:text-indigo-300">Qcess</h1>
                    <p className="text-md text-gray-400 dark:text-gray-300">Système de gestion de bâtiment modulaire
                    </p>
                </div>
                <div className="rounded-full flex bg-gray-200 dark:bg-gray-800 p-1 mb-4 text-sm">

                    <button onClick={() => setTab("login")} className={`cursor-pointer flex-1 py-2 rounded-full transition ${ tab === "login" ? "bg-white dark:bg-[#23232b] shadow-sm" : "text-gray-600 dark:text-gray-300"}`} >
                    Connexion
                    </button>

                    <button onClick={() => setTab("register")} className={`cursor-pointer flex-1 py-2 rounded-full transition ${ tab === "register" ? "bg-white dark:bg-[#23232b] shadow-sm" : "text-gray-600 dark:text-gray-300"}`} >
                    Inscription
                    </button>
                </div>
                {tab === "login" ? <LoginForm/> : <RegisterForm/> }

            </div>
        </div>
    );
};
function LoginForm() {
    const [form, setForm] = useState({ email: "", password: "", remember: false });
    const [loading, setLoading] = useState(false);
    const [error, setError]   = useState("");
    const router = useRouter()

    async function handleSubmit(e) {
        e.preventDefault();
        setError("");
        setLoading(true);
        console.log("Attempting login to:", `${API_BASE_URL}/auth/login/web`);
        try {
            const res = await fetch(`${API_BASE_URL}/auth/login/web`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(
                    { email: form.email, password: form.password , rememberMe: form.remember}
                ),
                credentials: "include"
            });
            console.log("Response status:", res.status);
            if (!res.ok) {
                const data = await res.json().catch(() => ({}));
                console.error("Login failed:", data);
                throw new Error(data.message || "Identifiants invalides");
            }
            const data = await res.json();

            console.log("Login success:", data);


            const params = new URLSearchParams(window.location.search);
            const next = params.get("next") || "/admin/dashboard";
            console.log("Redirecting to:", next);
            window.location.assign(next);
        } catch (err) {
            console.error("Login error:", err);
            setError(err.message);
        } finally {
            setLoading(false);
        }
    }

    return (
        <div className="flex flex-col items-center gap-4 w-full">
        <form onSubmit={handleSubmit} className="w-full max-w-md flex flex-col gap-4">
            <div className="flex flex-col gap-1">
                <label htmlFor="email" className="block text-md font-medium dark:text-gray-200">Email</label>
                <input
                    id="email"
                    name="email"
                    type="email"
                    required
                    autoComplete="email"
                    value={form.email}
                    onChange={(e) => setForm({ ...form, email: e.target.value })}
                    className="w-full rounded-md bg-[#F3F3F5] dark:bg-[#23232b] dark:text-gray-100 px-3 py-2
                     focus:outline-none focus:ring-1 focus:border-gray-300 dark:focus:border-gray-600 transition"
                    placeholder="you@example.com"
                />
            </div>

            <PasswordField
                id="password"
                name="password"
                label="Mot de passe"
                placeholder="••••••••"
                autoComplete="current-password"
                value={form.password}
                onChange={(v) => setForm({ ...form, password: v })}
            />

            <label className="inline-flex items-center gap-2 text-sm dark:text-gray-200">
                <input
                    type="checkbox"
                    className="size-4"
                    checked={form.remember}
                    onChange={(e) => setForm({ ...form, remember: e.target.checked })}
                    name="remember"
                    id="remember"
                />
                Se souvenir de moi
            </label>

            {error && <p className="text-sm text-red-400">{error}</p>}

            <button
                type="submit"
                disabled={loading}
                className="w-full rounded-md bg-[#030213] text-white text-lg font-medium py-2
                   transition-all duration-300 ease-in-out
                   hover:bg-white hover:text-[#030213] hover:border hover:border-[#030213]
                   dark:bg-indigo-700 dark:hover:bg-indigo-900 dark:hover:text-white dark:border dark:border-indigo-900
                   active:scale-95 disabled:opacity-60 disabled:cursor-not-allowed cursor-pointer"
            >
                {loading ? "Connexion..." : "Se connecter"}
            </button>
        </form>
            <div className="text-sm text-gray-600 dark:text-gray-300">
                <span>Mot de passe oublié ?</span>{" "}
                <button
                    type="button"
                    onClick={() => router.push("/auth/forgot-password")}
                    className="cursor-pointer font-medium text-[#030213] dark:text-indigo-400 hover:underline hover:text-black dark:hover:text-indigo-200 transition"
                >
                    Réinitialiser
                </button>
            </div>        </div>
    );
}


function RegisterForm() {
    const [form, setForm] = useState({
        fullName: "",
        orgName: "",
        email: "",
        password: "",
        confirm: "",
    });
    const [loading, setLoading] = useState(false);
    const [error, setError]   = useState("");

    async function handleSubmit(e) {
        e.preventDefault();
        setError("");

        if (!form.fullName || !form.orgName || !form.email || !form.password) {
            setError("Tous les champs sont requis.");
            return;
        }
        if (form.password !== form.confirm) {
            setError("Les mots de passe ne correspondent pas.");
            return;
        }
        if (form.password.length < 8) {
            setError("Le mot de passe doit contenir au moins 8 caractères.");
            return;
        }

        setLoading(true);
        console.log("Attempting registration to:", `${API_BASE_URL}/auth/register`);
        try {
            const res = await fetch(`${API_BASE_URL}/auth/register`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    fullName: form.fullName,
                    organizationName: form.orgName,
                    email: form.email,
                    password: form.password,
                }),
                credentials: "include"
            });
            console.log("Response status:", res.status);
            if (!res.ok) {
                const data = await res.json().catch(() => ({}));
                console.error("Registration failed:", data);
                throw new Error(data.message || "Inscription impossible.");
            }
            const data = await res.json();
            console.log("Register success:", data);
            console.log("Redirecting to dashboard");
            window.location.assign("/admin/dashboard");

        } catch (err) {
            console.error("Registration error:", err);
            setError(err.message);
        } finally {
            setLoading(false);
        }
    }

    return (
        <form onSubmit={handleSubmit} className="grid grid-cols-2 gap-4">
            <div className="flex flex-col">
                <label htmlFor="fullName" className="block text-md mb-1 dark:text-gray-200">Nom complet</label>
                <input
                    id="fullName"
                    name="fullName"
                    type="text"
                    required
                    autoComplete="name"
                    value={form.fullName}
                    onChange={(e) => setForm({ ...form, fullName: e.target.value })}
                    className="w-full rounded-md bg-[#F3F3F5] dark:bg-[#23232b] dark:text-gray-100 px-3 py-2
                     focus:outline-none focus:ring-1 focus:border-gray-300 dark:focus:border-gray-600 transition"
                />
            </div>

            <div className="flex flex-col">
                <label htmlFor="orgName" className="block text-md mb-1 dark:text-gray-200">Organisation</label>
                <input
                    id="orgName"
                    name="orgName"
                    type="text"
                    required
                    autoComplete="organization"
                    value={form.orgName}
                    onChange={(e) => setForm({ ...form, orgName: e.target.value })}
                    className="w-full rounded-md bg-[#F3F3F5] dark:bg-[#23232b] dark:text-gray-100 px-3 py-2
                     focus:outline-none focus:ring-1 focus:border-gray-300 dark:focus:border-gray-600 transition"
                />
            </div>

            <div className="flex flex-col col-span-2">
                <label htmlFor="emailReg" className="block text-md mb-1 dark:text-gray-200">Email</label>
                <input
                    id="emailReg"
                    name="email"
                    type="email"
                    required
                    autoComplete="email"
                    value={form.email}
                    onChange={(e) => setForm({ ...form, email: e.target.value })}
                    className="w-full rounded-md bg-[#F3F3F5] dark:bg-[#23232b] dark:text-gray-100 px-3 py-2
                     focus:outline-none focus:ring-1 focus:border-gray-300 dark:focus:border-gray-600 transition"
                    placeholder="you@example.com"
                />
            </div>

            <PasswordField
                id="passwordReg"
                name="password"
                label="Mot de passe"
                placeholder="••••••••"
                autoComplete="new-password"
                value={form.password}
                onChange={(v) => setForm({ ...form, password: v })}
            />

            <PasswordField
                id="confirmReg"
                name="confirm"
                label="Confirmer"
                placeholder="••••••••"
                autoComplete="new-password"
                value={form.confirm}
                onChange={(v) => setForm({ ...form, confirm: v })}
            />

            {error && <p className="col-span-2 text-sm text-red-400">{error}</p>}

            <button
                type="submit"
                disabled={loading}
                className="cursor-pointer col-span-2 w-full rounded-md bg-[#030213] text-white text-lg font-medium py-2 transition-all duration-300 ease-in-out hover:bg-white hover:text-[#030213] hover:border hover:border-[#030213] dark:bg-indigo-700 dark:hover:bg-indigo-900 dark:hover:text-white dark:border dark:border-indigo-900 active:scale-95 disabled:opacity-60 disabled:cursor-not-allowed"
            >
                {loading ? "Création..." : "S'inscrire"}
            </button>
        </form>
    );
}




function PasswordField({ id, name, label, value, onChange, placeholder, autoComplete }) {
    const [show, setShow] = useState(false);
    return (
        <div className="flex flex-col gap-1 relative">
            <label htmlFor={id} className="block text-md font-medium dark:text-gray-200">{label}</label>
            <input
                id={id}
                name={name}
                type={show ? "text" : "password"}
                value={value}
                onChange={(e) => onChange(e.target.value)}
                autoComplete={autoComplete}
                placeholder={placeholder}
                className="w-full rounded-md bg-[#F3F3F5] dark:bg-[#23232b] dark:text-gray-100 px-3 py-2 pr-10 border-transparent focus:outline-none focus:ring-1 focus:border-gray-300 dark:focus:border-gray-600 transition"/>
            <button
                type="button"
                onClick={() => setShow(!show)}
                className="absolute right-3 top-9 text-gray-500 hover:text-black dark:text-gray-400 dark:hover:text-white transition" aria-label={show ? "Masquer le mot de passe" : "Afficher le mot de passe"}
            >
                {show ? <FaRegEyeSlash/> : <FaEye/>}
            </button>
        </div>
    );
}




export default LoginRegister;