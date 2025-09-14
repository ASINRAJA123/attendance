import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './hooks/useAuth';
import AdminLayout from './components/AdminLayout';
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import UserManagementPage from './pages/UserManagementPage';
import AttendanceReportsPage from './pages/AttendanceReportsPage';

const PrivateRoutes = () => {
    const { isAuthenticated } = useAuth();
    // If authenticated, render the layout which contains the <Outlet /> for child routes.
    // Otherwise, navigate to the login page.
    return isAuthenticated ? <AdminLayout /> : <Navigate to="/login" replace />;
};

function App() {
    return (
        <Routes>
            <Route path="/login" element={<LoginPage />} />

            {/* All routes inside here are protected */}
            <Route element={<PrivateRoutes />}>
                <Route path="/dashboard" element={<DashboardPage />} />
                <Route path="/users" element={<UserManagementPage />} />
                <Route path="/reports" element={<AttendanceReportsPage />} />
            </Route>
            
            {/* Redirect any other path to the dashboard */}
            <Route path="*" element={<Navigate to="/dashboard" />} />
        </Routes>
    );
}

export default App;