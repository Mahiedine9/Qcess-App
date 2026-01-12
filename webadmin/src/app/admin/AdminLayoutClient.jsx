"use client";

import React from "react";
import { BsLayoutSidebarReverse } from "react-icons/bs";
import Sidebar from "../../components/Sidebar";

export default function AdminLayout({ admin , children }) {
    console.log("AdminLayout admin =", admin.userName);
    const [isSidebarOpen, setIsSidebarOpen] = React.useState(true);

    const toggleSidebar = () => setIsSidebarOpen((prev) => !prev);

    return (
        <div className="flex min-h-screen bg-slate-50 dark:bg-slate-900">
            {/* Sidebar à gauche */}
            <Sidebar
                isOpen={isSidebarOpen}
                onClose={() => setIsSidebarOpen(false)}
            />

            {/* Contenu principal */}
            <div
                className={`
    flex flex-1 flex-col 
    transition-[margin] duration-300 ease-in-out
    ${isSidebarOpen ? "lg:ml-64" : "lg:ml-0"}
  `}
            >
                {/* Top bar */}
                <header className="flex h-16 items-center justify-between border-b border-slate-200 dark:border-gray-900 bg-white dark:bg-[#23232b] px-4 lg:px-8">
                    {/* Bouton menu (mobile) */}
                    <button
                        className="inline-flex cursor-pointer items-center justify-center rounded-lg p-2 text-gray-600 hover:bg-slate-100 "
                        onClick={toggleSidebar}
                    >
                        <BsLayoutSidebarReverse className="h-5 w-5" />
                    </button>

                    <div className="flex-1 pl-2">

                    </div>
                    <div className="hidden text-sm text-gray-500 md:block">
                        Bienvenue, <span className="font-medium"> {admin?.userName ?? "Administrateur"}
</span>
                    </div>

                </header>

                {/* Zone de contenu */}
                <main className="flex-1 px-4 py-6 lg:px-8 bg-white dark:bg-[#23232b]">
                    {children}
                </main>
            </div>
        </div>
    );
}
