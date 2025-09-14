// pages/GrantOtpPage.jsx

import React, { useState, useEffect } from 'react';
import api from '../api/axiosConfig';

// --- NEW: Define the predefined time slots ---
const PREDEFINED_PERIODS = [
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '01:00 PM - 02:00 PM',
    '02:00 PM - 03:00 PM',
];

const GrantOtpPage = () => {
    // State to hold the list of all teachers
    const [teachers, setTeachers] = useState([]);
    
    // State for the form inputs
    const [selectedTeacherId, setSelectedTeacherId] = useState('');
    const [selectedPeriod, setSelectedPeriod] = useState(''); // Changed from 'period' for clarity

    // State for the API response and UI control
    const [generatedOtp, setGeneratedOtp] = useState(null);
    const [successMessage, setSuccessMessage] = useState('');
    const [loading, setLoading] = useState(true);
    const [isGenerating, setIsGenerating] = useState(false);
    const [error, setError] = useState('');

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

    const handleSubmit = async (e) => {
        e.preventDefault();
        // Updated validation
        if (!selectedTeacherId || !selectedPeriod) {
            setError('Please select a teacher and a period.');
            return;
        }

        setIsGenerating(true);
        setError('');
        setGeneratedOtp(null);

        try {
            const { data } = await api.post('/admin/otp/grant', {
                teacherId: selectedTeacherId,
                period: selectedPeriod, // Send the selected period
            });

            setGeneratedOtp(data.otp);
            setSuccessMessage(data.message);
            
            // Clear the form for the next use
            setSelectedTeacherId('');
            setSelectedPeriod('');

            // Automatically hide the OTP after 60 seconds
            setTimeout(() => {
                setGeneratedOtp(null);
                setSuccessMessage('');
            }, 60000);

        } catch (err) {
            setError(err.response?.data?.message || 'An unexpected error occurred.');
        } finally {
            setIsGenerating(false);
        }
    };
    
    // UI to display after OTP is generated (No changes here)
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
    
    // The main form UI with the new period selector
    return (
        <div>
            <h1 className="text-3xl font-bold mb-6">Grant OTP for Teacher</h1>
            <form onSubmit={handleSubmit} className="bg-white p-6 rounded-lg shadow-md max-w-2xl mx-auto">
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

                        {/* --- MODIFIED SECTION: Period Selector --- */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">Select a Period</label>
                            <div className="flex flex-wrap gap-2">
                                {PREDEFINED_PERIODS.map((period) => (
                                    <button
                                        key={period}
                                        type="button" // Important: prevents form submission on click
                                        onClick={() => setSelectedPeriod(period)}
                                        className={`
                                            px-3 py-2 border rounded-lg text-sm transition-all duration-150 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500
                                            ${selectedPeriod === period 
                                                ? 'bg-indigo-100 border-indigo-500 text-indigo-800 font-semibold shadow-sm' 
                                                : 'bg-white border-gray-300 text-gray-700 hover:bg-gray-50'
                                            }
                                        `}
                                    >
                                        {selectedPeriod === period && '✓ '}
                                        {period}
                                    </button>
                                ))}
                            </div>
                        </div>
                        {/* --- END MODIFIED SECTION --- */}
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