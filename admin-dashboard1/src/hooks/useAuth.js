// src/hooks/useAuth.js

import { useContext } from 'react';
// Correctly import the context from its new home
import { AuthContext } from '../context/AuthContext';

// This file is now correct. It only exports the hook.
export const useAuth = () => {
    const context = useContext(AuthContext);
    if (context === undefined) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
};