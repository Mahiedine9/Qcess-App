"use client";

import React, { useState, useEffect, useCallback } from "react";
import { HiOutlineUsers, HiOutlineLocationMarker } from "react-icons/hi";
import { RiTicketLine } from "react-icons/ri";
import { AiOutlineQrcode } from "react-icons/ai";

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL;

function StatusBadge({ status }) {
    const base = "inline-flex items-center rounded-full px-3 py-1 text-xs font-medium";
    
    if (status === "OPEN" || status === "IN_PROGRESS") {
        return <span className={`${base} ${status === "OPEN" ? "bg-blue-100 text-blue-700" : "bg-amber-100 text-amber-700"}`}>
            {status === "OPEN" ? "ouvert" : "en cours"}
        </span>;
    }
    return <span className={`${base} bg-gray-100 text-gray-700`}>fermé</span>;
}

export default function DashboardPage() {
    const [stats, setStats] = useState(null);
    const [recentAccess, setRecentAccess] = useState([]);
    const [recentTickets, setRecentTickets] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const loadDashboardData = useCallback(async () => {
        try {
            setLoading(true);
            
            // Charger les statistiques
            const statsRes = await fetch(`${API_BASE_URL}/dashboard/stats`, {
                credentials: "include",
            });
            if (!statsRes.ok) throw new Error("Impossible de charger les statistiques");
            const statsData = await statsRes.json();
            setStats(statsData);

            // Charger les 4 derniers accès
            const accessRes = await fetch(`${API_BASE_URL}/access/logs?limit=4`, {
                credentials: "include",
            });
            if (!accessRes.ok) throw new Error("Impossible de charger l'historique des accès");
            const accessData = await accessRes.json();
            setRecentAccess(accessData);

            // Charger les 3 derniers tickets
            const ticketsRes = await fetch(`${API_BASE_URL}/maintenance/tickets/organization`, {
                credentials: "include",
            });
            if (!ticketsRes.ok) throw new Error("Impossible de charger les tickets");
            const ticketsData = await ticketsRes.json();
            // Filtrer les tickets ouverts/en cours et prendre les 3 plus récents
            const openTickets = ticketsData
                .filter(t => t.status === "OPEN" || t.status === "IN_PROGRESS")
                .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
                .slice(0, 3);
            setRecentTickets(openTickets);

        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        loadDashboardData();
        
        // Rafraîchir toutes les 30 secondes
        const interval = setInterval(loadDashboardData, 30000);
        
        // Recharger quand la page devient visible
        const handleVisibilityChange = () => {
            if (!document.hidden) {
                loadDashboardData();
            }
        };
        document.addEventListener('visibilitychange', handleVisibilityChange);
        
        // SSE pour les mises à jour en temps réel
        const streamUrl = `${API_BASE_URL}/access/stream-logs`;
        const eventSource = new EventSource(streamUrl, { withCredentials: true });
        
        // Écouter les événements de mise à jour de ressources
        eventSource.addEventListener('resource-update', (event) => {
            try {
                const msg = JSON.parse(event.data);
                console.log("📩 Dashboard SSE resource-update:", msg);
                
                // Si un utilisateur est créé, suspendu ou activé, recharger le dashboard
                if (msg.resourceType === 'USER') {
                    console.log("Rechargement du dashboard suite à modification USER");
                    loadDashboardData();
                }
                
                // Si un ticket est créé ou modifié, recharger le dashboard
                if (msg.resourceType === 'TICKET') {
                    console.log("✅ Rechargement du dashboard suite à modification TICKET");
                    loadDashboardData();
                }
            } catch (err) {
                console.error("Erreur parsing resource-update dans dashboard:", err);
            }
        });
        
        // Écouter les nouveaux access-logs pour mettre à jour les accès
        eventSource.addEventListener('access-log', (event) => {
            try {
                const newLog = JSON.parse(event.data);
                console.log(" Dashboard SSE access-log:", newLog);
                
                // Ajouter le nouveau log au début et limiter à 4 éléments
                setRecentAccess(prev => [newLog, ...prev].slice(0, 4));
                
                // Incrémenter le compteur d'accès du jour
                setStats(prev => prev ? {
                    ...prev,
                    accessToday: (prev.accessToday || 0) + 1
                } : null);
            } catch (err) {
                console.error("Erreur parsing access-log dans dashboard:", err);
            }
        });
        
        eventSource.onerror = (err) => {
            console.warn("SSE déconnecté (Dashboard)", err);
            eventSource.close();
        };
        
        return () => {
            clearInterval(interval);
            document.removeEventListener('visibilitychange', handleVisibilityChange);
            eventSource.close();
        };
    }, [loadDashboardData]);

    if (loading && !stats) {
        return (
            <div className="flex items-center justify-center h-64">
                <div className="h-12 w-12 animate-spin rounded-full border-4 border-slate-200 border-t-indigo-600"></div>
            </div>
        );
    }

    if (error) {
        return (
            <div className="flex items-center justify-center h-64">
                <p className="text-red-600">{error}</p>
            </div>
        );
    }

    const statsCards = stats ? [
        {
            id: "access-today",
            label: "Accès aujourd'hui",
            value: stats.accessToday?.toString() || "0",
            subLabel: `${stats.accessPercentageChange >= 0 ? '+' : ''}${stats.accessPercentageChange}% par rapport à hier`,
            icon: <AiOutlineQrcode className="text-xl" />,
        },
        {
            id: "active-users",
            label: "Utilisateurs actifs",
            value: stats.activeUsers?.toString() || "0",
            subLabel: `${stats.newUsersThisWeek} nouveau${stats.newUsersThisWeek > 1 ? 'x' : ''} cette semaine`,
            icon: <HiOutlineUsers className="text-xl" />,
        },
        {
            id: "open-tickets",
            label: "Tickets ouverts",
            value: stats.openTickets?.toString() || "0",
            subLabel: `${stats.urgentTickets} urgent${stats.urgentTickets > 1 ? 's' : ''}`,
            icon: <RiTicketLine className="text-xl" />,
        },
        {
            id: "zones-configured",
            label: "Zones configurées",
            value: stats.configuredZones?.toString() || "0",
            subLabel: stats.topZones || "Aucune zone",
            icon: <HiOutlineLocationMarker className="text-xl" />,
        },
    ] : [];

    return (
        <main className="space-y-8 ">
            {/* Header */}
            <div className="flex items-baseline justify-between ">
                <div>
                    <h1 className="text-2xl font-semibold text-gray-900 dark:text-gray-100">Dashboard</h1>
                    <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">
                        Vue d’ensemble des accès, utilisateurs et tickets de maintenance.
                    </p>
                </div>

            </div>

            {/* Stat cards */}
            <section className="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
                {statsCards.map((stat) => (
                    <div
                        key={stat.id}
                        className="flex items-center justify-between rounded-2xl bg-white dark:bg-[#23232b] px-5 py-4 shadow-sm border border-slate-100 dark:border-gray-700"
                    >
                        <div className="flex items-center gap-3">
                            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-indigo-50 dark:bg-indigo-900 text-indigo-600 dark:text-indigo-300">
                                {stat.icon}
                            </div>
                            <div>
                                <p className="text-xs font-medium uppercase tracking-wide text-gray-400 dark:text-gray-400">
                                    {stat.label}
                                </p>
                                <p className="mt-1 text-2xl font-semibold text-gray-900 dark:text-gray-100">
                                    {stat.value}
                                </p>
                            </div>
                        </div>
                        <p className="text-xs text-gray-500 dark:text-gray-400 text-right max-w-[120px]">
                            {stat.subLabel}
                        </p>
                    </div>
                ))}
            </section>

            {/* Bottom panels */}
            <section className="grid grid-cols-1 gap-6 lg:grid-cols-2">
                {/* Accès récents */}
                <div className="rounded-2xl bg-white dark:bg-[#23232b] p-6 shadow-sm border border-slate-100 dark:border-gray-700">
                    <div className="mb-4 flex items-center justify-between">
                        <div>
                            <h2 className="text-base font-semibold text-gray-900 dark:text-gray-100">
                                Accès récents
                            </h2>
                            <p className="text-sm text-gray-500 dark:text-gray-400">
                                Derniers accès enregistrés
                            </p>
                        </div>
                    </div>

                    <ul className="divide-y divide-gray-100 dark:divide-gray-800">
                        {recentAccess.length === 0 ? (
                            <li className="py-8 text-center text-sm text-gray-500 dark:text-gray-400">
                                Aucun accès récent
                            </li>
                        ) : (
                            recentAccess.map((access) => (
                                <li
                                    key={access.id}
                                    className="flex items-center justify-between py-3"
                                >
                                    <div>
                                        <p className="text-sm font-medium text-gray-900 dark:text-gray-100">
                                            {access.userName || "Utilisateur inconnu"}
                                        </p>
                                        <p className="text-xs text-gray-500 dark:text-gray-400">{access.zoneName || "Zone inconnue"}</p>
                                    </div>
                                    <div className="text-right">
                                        <p className="text-sm text-gray-900 dark:text-gray-100">
                                            {new Date(access.timestamp).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })}
                                        </p>
                                        <p className={`text-xs ${access.accessGranted ? "text-green-600" : "text-red-600"}`}>
                                            {access.accessGranted ? "Autorisé" : "Refusé"}
                                        </p>
                                    </div>
                                </li>
                            ))
                        )}
                    </ul>
                </div>

                {/* Tickets récents */}
                <div className="rounded-2xl bg-white dark:bg-[#23232b] p-6 shadow-sm border border-slate-100 dark:border-gray-700">
                    <div className="mb-4 flex items-center justify-between">
                        <div>
                            <h2 className="text-base font-semibold text-gray-900 dark:text-gray-100">
                                Tickets récents
                            </h2>
                            <p className="text-sm text-gray-500 dark:text-gray-400">
                                Dernières demandes de maintenance
                            </p>
                        </div>
                    </div>

                    <ul className="divide-y divide-gray-100 dark:divide-gray-800">
                        {recentTickets.length === 0 ? (
                            <li className="py-8 text-center text-sm text-gray-500 dark:text-gray-400">
                                Aucun ticket récent
                            </li>
                        ) : (
                            recentTickets.map((ticket) => (
                                <li
                                    key={ticket.id}
                                    className="flex items-center justify-between py-3"
                                >
                                    <div>
                                        <p className="text-sm font-medium text-indigo-700 dark:text-indigo-300 hover:underline cursor-pointer">
                                            {ticket.title}
                                        </p>
                                        <p className="text-xs text-gray-500 dark:text-gray-400">
                                            Par {ticket.createdByUserName || "Utilisateur"} - {new Date(ticket.createdAt).toLocaleDateString('fr-FR')}
                                        </p>
                                    </div>
                                    <StatusBadge status={ticket.status} />
                                </li>
                            ))
                        )}
                    </ul>
                </div>
            </section>
        </main>
    );
}
