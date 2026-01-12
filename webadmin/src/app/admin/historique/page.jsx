'use client';

import React, { useState, useEffect } from 'react';
import { API_BASE_URL, API_URL } from '@/lib/api';
import { HiOutlineUsers } from "react-icons/hi";
import { FaHistory } from "react-icons/fa";
export default function LogsPage() {
    const [logs, setLogs] = useState([]);
    const [filteredLogs, setFilteredLogs] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const [searchUser, setSearchUser] = useState('');
    const [searchZone, setSearchZone] = useState('');
    const [searchDate, setSearchDate] = useState('');

    useEffect(() => {
        fetchLogs();
    }, []);

    useEffect(() => {
        filterLogs();
    }, [searchUser, searchZone, searchDate, logs]);

    const fetchLogs = async () => {
        try {
            setLoading(true);
            const res = await fetch(`${API_BASE_URL}/access/logs`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                },
                credentials: 'include',
            });

            if (!res.ok) {
                throw new Error('Erreur lors du chargement des logs');
            }

            const data = await res.json();
            // Sort by timestamp desc
            const sortedData = data.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
            setLogs(sortedData);
            setFilteredLogs(sortedData);
        } catch (err) {
            console.error(err);
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

        useEffect(() => {
        fetchLogs();

        const streamUrl = `${API_BASE_URL}/access/stream-logs`;
        const eventSource = new EventSource(streamUrl, { withCredentials: true });

        eventSource.addEventListener('access-log', (event) => {
            try {
                const newLog = JSON.parse(event.data);
                console.log("Nouveau log reçu:", newLog);
                
                setLogs(prevLogs => [newLog, ...prevLogs]);
                setFilteredLogs(prevFiltered => [newLog, ...prevFiltered]);
            } catch (err) {
                console.error("Erreur SSE log", err);
            }
        });

        eventSource.onerror = () => {
            console.warn("SSE déconnecté");
            eventSource.close();
        };

        return () => eventSource.close();
    }, []);
    const filterLogs = () => {
        let tempLogs = [...logs];

        if (searchUser) {
            tempLogs = tempLogs.filter(log => 
                log.userName && log.userName.toLowerCase().includes(searchUser.toLowerCase())
            );
        }

        if (searchZone) {
            tempLogs = tempLogs.filter(log => 
                log.zoneName && log.zoneName.toLowerCase().includes(searchZone.toLowerCase())
            );
        }

        if (searchDate) {
            tempLogs = tempLogs.filter(log => {
                if (!log.timestamp) return false;
                const logDate = new Date(log.timestamp).toISOString().split('T')[0];
                return logDate === searchDate;
            });
        }

        setFilteredLogs(tempLogs);
    };

    const formatDate = (isoString) => {
        if (!isoString) return '-';
        return new Date(isoString).toLocaleString('fr-FR', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        });
    };

    return (
        <div className=" space-y-6 ">
                            <div className="flex items-center gap-3">
                                <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-indigo-50 dark:bg-indigo-900">
                                    <FaHistory className="h-6 w-6 text-indigo-600 dark:text-indigo-300" />
                                </div>
                                <div>
                                    <h1 className="text-2xl font-semibold text-gray-900 dark:text-gray-100">Historique des accès</h1>
                                    <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">
                                        Des logs en temps réel de toutes les tentatives d'accès aux zones sécurisées.
                                    </p>
                                </div>
                            </div>

            {/* Filters Section */}
            <div className="bg-white dark:bg-[#181818] p-4 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-400 mb-1">Utilisateur</label>
                    <input
                        type="text"
                        placeholder="Rechercher un utilisateur..."
                        value={searchUser}
                        onChange={(e) => setSearchUser(e.target.value)}
className="w-full px-4 py-2 rounded-lg outline-none transition-all
border border-gray-300 dark:border-gray-700
bg-white dark:bg-[#23232b]
text-gray-900 dark:text-gray-100
placeholder:text-gray-400 dark:placeholder:text-gray-500
focus:ring-2 focus:ring-blue-500 focus:border-blue-500"                    />
                </div>
                <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-400 mb-1">Zone</label>
                    <input
                        type="text"
                        placeholder="Rechercher une zone..."
                        value={searchZone}
                        onChange={(e) => setSearchZone(e.target.value)}
className="w-full px-4 py-2 rounded-lg outline-none transition-all
border border-gray-300 dark:border-gray-700
bg-white dark:bg-[#23232b]
text-gray-900 dark:text-gray-100
placeholder:text-gray-400 dark:placeholder:text-gray-500
focus:ring-2 focus:ring-blue-500 focus:border-blue-500"                    />
                </div>
                <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-400 mb-1">Date</label>
                    <input
                        type="date"
                        value={searchDate}
                        onChange={(e) => setSearchDate(e.target.value)}
className="w-full px-4 py-2 rounded-lg outline-none transition-all
border border-gray-300 dark:border-gray-700
bg-white dark:bg-[#23232b]
text-gray-900 dark:text-gray-100
placeholder:text-gray-400 dark:placeholder:text-gray-500
focus:ring-2 focus:ring-blue-500 focus:border-blue-500"                    />
                </div>
            </div>

            {/* Table Section */}
            <div className="bg-white dark:bg-[#23232b] rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 overflow-hidden">
                {loading ? (
                    <div className="p-8 text-center text-gray-500">Chargement des données...</div>
                ) : error ? (
                    <div className="p-8 text-center text-red-500">Erreur: {error}</div>
                ) : filteredLogs.length === 0 ? (
                    <div className="p-8 text-center text-gray-500">Aucun historique trouvé.</div>
                ) : (
                    <div className="overflow-x-auto">
                        <table className="w-full table-fixed text-left border-collapse">
                            <thead>
                                <tr className="bg-gray-50 dark:bg-[#23232b] border-b border-gray-100 dark:border-gray-700">
                                    <th className="px-6 py-4 text-left font-semibold text-gray-700 dark:text-gray-200 text-xs uppercase tracking-wider">Date & Heure</th>
                                    <th className="px-6 py-4 text-left font-semibold text-gray-700 dark:text-gray-200 text-xs uppercase tracking-wider">Utilisateur</th>
                                    <th className="px-6 py-4 text-left font-semibold text-gray-700 dark:text-gray-200 text-xs uppercase tracking-wider">Zone</th>
                                    <th className="px-6 py-4 text-center font-semibold text-gray-700 dark:text-gray-200 text-xs uppercase tracking-wider">Statut</th>
                                    <th className="px-6 py-4 text-center font-semibold text-gray-700 dark:text-gray-200 text-xs uppercase tracking-wider">Détails</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-100 dark:divide-gray-700">
                                {filteredLogs.map((log) => (
                                    <tr key={log.id} className="hover:bg-gray-50 dark:hover:bg-[#2b2b33] transition-colors">
                                        <td className="px-6 py-4 text-sm text-gray-600 dark:text-gray-100">
                                            {formatDate(log.timestamp)}
                                        </td>
                                        <td className="px-6 py-4 text-sm font-medium text-gray-900 dark:text-gray-100">
                                            {log.userName || <span className="text-gray-400  italic">Inconnu (ID: {log.userId})</span>}
                                        </td>
                                        <td className="px-6 py-4 text-sm text-gray-600 dark:text-gray-100">
                                            {log.zoneName || <span className="text-gray-400 italic">Inconnue (ID: {log.zoneId})</span>}
                                        </td>
                                        <td className="px-6 py-4 text-center">
                                            <span className={`inline-flex items-center justify-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
log.accessGranted
  ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-200'
  : 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-200'                                            }`}>
                                                {log.accessGranted ? 'AUTORISÉ' : 'REFUSÉ'}
                                            </span>
                                        </td>
                                                <td className="px-6 py-4 text-sm text-center text-gray-500 dark:text-gray-300">                                            {!log.accessGranted && log.reason ? (
                                                <span className="text-red-600 dark:text-red-300">{log.reason}</span>
                                            ) : (
                                                '-'
                                            )}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>
        </div>
    );
}