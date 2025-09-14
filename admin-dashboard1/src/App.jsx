// App.jsx

import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';

// --- CORRECTED IMPORTS ---
// 1. Import AuthProvider from its correct location in the context folder.
import { AuthProvider } from './context/AuthContext';
// 2. Import the useAuth hook from its file.
import { useAuth } from './hooks/useAuth';

// --- COMPONENT & PAGE IMPORTS ---
// Assuming AdminLayout is in a 'layouts' or 'components' folder
import AdminLayout from './components/AdminLayout'; 
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import ManageStudentsPage from './pages/ManageStudentsPage';
import ManageTeachersPage from './pages/ManageTeachersPage';
import AddStudentPage from './pages/AddStudentPage';
import AddTeacherPage from './pages/AddTeacherPage';
import EditStudentPage from './pages/EditStudentPage';
import EditTeacherPage from './pages/EditTeacherPage';
import StudentReportPage from './pages/StudentReportPage';
import GrantOtpPage from './pages/GrantOtpPage';

// --- IMPROVED PRIVATE ROUTE ---
// This component now handles the initial loading state to prevent flickering.
const PrivateRoute = ({ children }) => {
    const { isAuthenticated, loading } = useAuth();

    // While the AuthProvider is checking localStorage, show a loading indicator.
    if (loading) {
        return (
            <div className="flex h-screen items-center justify-center">
                <div>Loading...</div>
            </div>
        );
    }

    // After loading, if the user is authenticated, show the page. Otherwise, redirect to login.
    return isAuthenticated ? children : <Navigate to="/login" replace />;
};

function App() {
    return (
        // The Router should be the outermost component.
        <Router>
            {/* AuthProvider wraps all routes so the useAuth hook can be used anywhere. */}
            <AuthProvider>
                <Routes>
                    <Route path="/login" element={<LoginPage />} />
                    
                    {/* All protected admin routes are nested inside this parent route */}
                    <Route 
                        path="/" 
                        element={<PrivateRoute><AdminLayout /></PrivateRoute>}
                    >
                        {/* Redirects the base "/" path to the dashboard */}
                        <Route index element={<Navigate to="/dashboard" replace />} />
                        
                        {/* Dashboard */}
                        <Route path="dashboard" element={<DashboardPage />} />
                        
                        {/* Student Routes */}
                        <Route path="students" element={<ManageStudentsPage />} />
                        <Route path="students/add" element={<AddStudentPage />} />
                        <Route path="students/edit/:id" element={<EditStudentPage />} />
                        <Route path="students/report/:id" element={<StudentReportPage />} />
                        
                        {/* Teacher Routes */}
                        <Route path="teachers" element={<ManageTeachersPage />} />
                        <Route path="teachers/add" element={<AddTeacherPage />} />
                        <Route path="teachers/edit/:id" element={<EditTeacherPage />} />

                        {/* Other Admin Routes */}
                        <Route path="grant-otp" element={<GrantOtpPage />} />

                        {/* A fallback for any unknown routes within the admin panel */}
                        <Route path="*" element={<Navigate to="/dashboard" replace />} />
                    </Route>
                </Routes>
            </AuthProvider>
        </Router>
    );
}

export default App;