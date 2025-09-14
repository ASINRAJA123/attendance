// src/context/AuthContext.jsx

import React, { createContext, useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../api/axiosConfig';

// 1. Create the context
export const AuthContext = createContext(null);

// 2. Create the Provider component (The "Power Outlet")
export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);
    const navigate = useNavigate();

    useEffect(() => {
        const userInfo = JSON.parse(localStorage.getItem('userInfo'));
        if (userInfo && userInfo.token && userInfo.role === 'admin') {
            setUser(userInfo);
        }
        setLoading(false);
    }, []);

    const login = async (email, password) => {
        try {
            const { data } = await api.post('/auth/login', { email, password });
            if (data.role !== 'admin') {
                alert('Access Denied: Only admins can log in here.');
                return;
            }
            localStorage.setItem('userInfo', JSON.stringify(data));
            setUser(data);
            navigate('/dashboard');
        } catch (error) {
            console.error('Login failed', error);
            alert('Login failed: Invalid credentials.');
        }
    };

    const logout = () => {
        localStorage.removeItem('userInfo');
        setUser(null);
        navigate('/login');
    };

    const value = { user, login, logout, isAuthenticated: !!user, loading };

    // Don't render children until the initial auth check is complete
    return (
        <AuthContext.Provider value={value}>
            {!loading && children}
        </AuthContext.Provider>
    );
};