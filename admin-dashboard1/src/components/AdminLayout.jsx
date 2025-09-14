import React from 'react';
import { NavLink, Outlet } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

const AdminLayout = () => {
    const { logout, user } = useAuth();

    const navLinkClasses = 'flex items-center px-4 py-3 text-gray-300 hover:bg-gray-700 hover:text-white rounded-md transition-colors duration-200';
    const activeNavLinkClasses = 'bg-gray-900 text-white';

    const navItems = [
        { text: 'Dashboard', path: '/dashboard' },
        { text: 'Manage Users', path: '/users' },
        { text: 'Reports', path: '/reports' },
    ];

    return (
        <div className="flex h-screen bg-gray-100">
            {/* Sidebar */}
            <aside className="fixed inset-y-0 left-0 w-64 bg-gray-800 text-white flex-shrink-0 z-20">
                <div className="p-4 text-2xl font-bold border-b border-gray-700">Admin Panel</div>
                <nav className="p-4 space-y-2">
                    {navItems.map((item) => (
                        <NavLink
                            key={item.text}
                            to={item.path}
                            className={({ isActive }) =>
                                `${navLinkClasses} ${isActive ? activeNavLinkClasses : ''}`
                            }
                        >
                            {item.text}
                        </NavLink>
                    ))}
                </nav>
            </aside>

            <div className="flex-1 flex flex-col ml-64">
                {/* Header */}
                <header className="fixed top-0 left-64 right-0 bg-white shadow-md p-4 z-10">
                    <div className="flex justify-between items-center">
                        <span className="text-gray-700">Welcome, {user?.name || 'Admin'}</span>
                        <button
                            onClick={logout}
                            className="bg-red-500 text-white px-4 py-2 rounded-md hover:bg-red-600 transition-colors"
                        >
                            Logout
                        </button>
                    </div>
                </header>

                {/* Main Content */}
                <main className="flex-1 p-8 mt-16">
                    <Outlet /> {/* Child routes will render here */}
                </main>
            </div>
        </div>
    );
};

export default AdminLayout;