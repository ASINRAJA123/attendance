// pages/GrantOtpPage.jsx

import React, { useState, useEffect } from 'react';
import api from '../api/axiosConfig';

const GrantOtpPage = () => {
    // State to hold the list of all teachers
    const [teachers, setTeachers] = useState([]);
    
    // State for the form inputs
    const [selectedTeacherId, setSelectedTeacherId] = useState('');
    const [period, setPeriod] = useState('');

    // State for the API response and UI control
    const [generatedOtp, setGeneratedOtp] = useState(null);
    const [successMessage, setSuccessMessage] = useState('');
    const [loading, setLoading] = useState(true);
    const [isGenerating, setIsGenerating] = useState(false);
    const [error, setError] = useState('');

    // Fetch all users with the role 'teacher' when the component mounts
    useEffect(() => {
        const fetchTeachers = async () => {
            try {
                const { data } = await api.get('/admin/users');
                const teacherList = data.filter(user => user.role === 'teacher');
                setTeachers(teacherList);
            } catch (err) {
                setError('Failed to load the list of teachers.');
            } finally {
                setLoading(false);
            }
        };
        fetchTeachers();
    }, []);

    // Handle the form submission to generate the OTP
    const handleSubmit = async (e) => {
        e.preventDefault();
        // Basic validation
        if (!selectedTeacherId || !period) {
            setError('Please select a teacher and enter a period.');
            return;
        }

        setIsGenerating(true);
        setError('');
        setGeneratedOtp(null);

        try {
            const { data } = await api.post('/admin/otp/grant', {
                teacherId: selectedTeacherId,
                period,
            });

            setGeneratedOtp(data.otp);
            setSuccessMessage(data.message);
            
            // Clear the form for the next use
            setSelectedTeacherId('');
            setPeriod('');

            // Automatically hide the OTP after 60 seconds for security
            setTimeout(() => {
                setGeneratedOtp(null);
                setSuccessMessage('');
            }, 60000); // 60 seconds

        } catch (err) {
            setError(err.response?.data?.message || 'An unexpected error occurred.');
        } finally {
            setIsGenerating(false);
        }
    };
    
    // UI to display after OTP is generated
    if (generatedOtp) {
        return (
            <div className="text-center max-w-md mx-auto">
                <h1 className="text-3xl font-bold mb-4">OTP Generated Successfully</h1>
                <div className="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 rounded-lg shadow-md">
                    <p className="font-semibold mb-4">{successMessage}</p>
                    <p className="text-5xl font-bold tracking-widest my-4">{generatedOtp}</p>
                    <p className="text-sm">This OTP is valid for the next 10 minutes.</p>
                </div>
                <button
                    onClick={() => setGeneratedOtp(null)}
                    className="mt-6 bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700"
                >
                    Grant Another OTP
                </button>
            </div>
        );
    }
    
    // The main form UI
    return (
        <div>
            <h1 className="text-3xl font-bold mb-6">Grant OTP for Teacher</h1>
            <form onSubmit={handleSubmit} className="bg-white p-6 rounded-lg shadow-md max-w-lg mx-auto">
                {loading ? (
                    <p>Loading teachers...</p>
                ) : (
                    <div className="space-y-6">
                        <div>
                            <label htmlFor="teacherId" className="block text-sm font-medium text-gray-700">Select Teacher</label>
                            <select
                                id="teacherId"
                                value={selectedTeacherId}
                                onChange={(e) => setSelectedTeacherId(e.target.value)}
                                required
                                className="mt-1 block w-full px-3 py-2 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                            >
                                <option value="" disabled>-- Select a teacher --</option>
                                {teachers.map(teacher => (
                                    <option key={teacher._id} value={teacher._id}>
                                        {teacher.name} ({teacher.email})
                                    </option>
                                ))}
                            </select>
                        </div>
                        <div>
                            <label htmlFor="period" className="block text-sm font-medium text-gray-700">Class Period</label>
                            <input
                                id="period"
                                name="period"
                                type="text"
                                value={period}
                                onChange={(e) => setPeriod(e.target.value)}
                                required
                                placeholder="e.g., 10:00 AM - 11:00 AM"
                                className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                            />
                        </div>
                    </div>
                )}
                
                {error && <p className="mt-4 text-sm text-red-600">{error}</p>}

                <div className="flex justify-end mt-6">
                    <button
                        type="submit"
                        className="px-6 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:bg-indigo-300"
                        disabled={loading || isGenerating}
                    >
                        {isGenerating ? 'Generating...' : 'Generate OTP'}
                    </button>
                </div>
            </form>
        </div>
    );
};

export default GrantOtpPage;