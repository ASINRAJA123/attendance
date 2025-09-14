// pages/EditStudentPage.jsx

import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import api from '../api/axiosConfig';

const EditStudentPage = () => {
    const { id } = useParams(); // Get student ID from URL
    const navigate = useNavigate();

    // State for form data, teachers list, loading, and errors
    const [formData, setFormData] = useState({
        name: '',
        rollNumber: '',
        email: '',
        classId: '',
        assignedTeachers: [], // Will store array of teacher IDs
        allTeachers: false
    });
    const [allTeachers, setAllTeachers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');

    useEffect(() => {
        const fetchData = async () => {
            setLoading(true);
            try {
                // Fetch student details and all users (for teacher list) concurrently
                const [studentRes, usersRes] = await Promise.all([
                    api.get(`/admin/users/${id}`),
                    api.get('/admin/users')
                ]);

                const studentData = studentRes.data;
                const teacherList = usersRes.data.filter(user => user.role === 'teacher');
                
                setAllTeachers(teacherList);
                setFormData({
                    name: studentData.name,
                    rollNumber: studentData.rollNumber || '',
                    email: studentData.email,
                    classId: studentData.classId || '',
                    // The API returns teacher objects, we only need their IDs for the form state
                    assignedTeachers: studentData.assignedTeachers.map(teacher => teacher._id),
                    allTeachers: studentData.allTeachers || false,
                });

            } catch (err) {
                setError('Failed to load student data. Please try again.');
                console.error(err);
            } finally {
                setLoading(false);
            }
        };

        fetchData();
    }, [id]); // Re-run if the ID in the URL changes

    // Handler for standard text inputs
    const handleChange = (e) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
    };

    // Handler for checkboxes
    const handleCheckboxChange = (e) => {
        setFormData({ ...formData, [e.target.name]: e.target.checked });
    };

    // Toggles a teacher's ID in the assignedTeachers array
    const handleTeacherSelect = (teacherId) => {
        const currentAssigned = formData.assignedTeachers;
        if (currentAssigned.includes(teacherId)) {
            // Uncheck: Remove the teacher ID
            setFormData({ ...formData, assignedTeachers: currentAssigned.filter(id => id !== teacherId) });
        } else {
            // Check: Add the teacher ID
            setFormData({ ...formData, assignedTeachers: [...currentAssigned, teacherId] });
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError('');
        try {
            await api.put(`/admin/users/${id}`, formData);
            navigate('/students'); // Redirect to student list on success
        } catch (err) {
            setError(err.response?.data?.message || 'Failed to update student.');
            setLoading(false);
        }
    };

    // Show a loading screen while fetching initial data
    if (loading && !formData.name) {
        return <div className="text-center p-8">Loading student details...</div>;
    }

    return (
        <div>
            <h1 className="text-3xl font-bold mb-6">Edit Student: {formData.name}</h1>

            <form onSubmit={handleSubmit} className="bg-white p-6 rounded-lg shadow-md max-w-2xl mx-auto">
                <div className="space-y-6">
                    {/* Form Fields */}
                    <div>
                        <label htmlFor="name" className="block text-sm font-medium text-gray-700">Full Name</label>
                        <input id="name" name="name" type="text" value={formData.name} onChange={handleChange} required className="mt-1 w-full border p-2 rounded-md shadow-sm" />
                    </div>
                    <div>
                        <label htmlFor="rollNumber" className="block text-sm font-medium text-gray-700">Roll Number</label>
                        <input id="rollNumber" name="rollNumber" type="text" value={formData.rollNumber} onChange={handleChange} required className="mt-1 w-full border p-2 rounded-md shadow-sm" />
                    </div>
                    <div>
                        <label htmlFor="email" className="block text-sm font-medium text-gray-700">Email Address</label>
                        <input id="email" name="email" type="email" value={formData.email} onChange={handleChange} required className="mt-1 w-full border p-2 rounded-md shadow-sm" />
                    </div>
                    <div>
                        <label htmlFor="classId" className="block text-sm font-medium text-gray-700">Class ID</label>
                        <input id="classId" name="classId" type="text" value={formData.classId} onChange={handleChange} className="mt-1 w-full border p-2 rounded-md shadow-sm" />
                    </div>

                    {/* Teacher Assignments */}
                    <div className="border-t pt-6">
                        <h3 className="text-lg font-medium text-gray-900 mb-4">Teacher Assignments</h3>
                        <div className="flex items-center space-x-3 mb-4">
                            <input id="allTeachers" name="allTeachers" type="checkbox" checked={formData.allTeachers} onChange={handleCheckboxChange} className="h-4 w-4 text-indigo-600 border-gray-300 rounded" />
                            <label htmlFor="allTeachers" className="text-sm text-gray-700">Assign to all teachers</label>
                        </div>

                        {!formData.allTeachers && (
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-2">Select specific teachers:</label>
                                <div className="grid grid-cols-2 md:grid-cols-3 gap-4 p-4 border rounded-md max-h-48 overflow-y-auto">
                                    {allTeachers.map(teacher => (
                                        <div key={teacher._id} className="flex items-center">
                                            <input
                                                id={`teacher-${teacher._id}`}
                                                type="checkbox"
                                                checked={formData.assignedTeachers.includes(teacher._id)}
                                                onChange={() => handleTeacherSelect(teacher._id)}
                                                className="h-4 w-4 text-indigo-600 border-gray-300 rounded"
                                            />
                                            <label htmlFor={`teacher-${teacher._id}`} className="ml-2 block text-sm text-gray-900">{teacher.name}</label>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        )}
                    </div>
                </div>

                {error && <p className="mt-4 text-sm text-red-600 text-center">{error}</p>}

                {/* Action Buttons */}
                <div className="flex justify-end space-x-4 mt-8">
                    <button type="button" onClick={() => navigate('/students')} className="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300" disabled={loading}>
                        Cancel
                    </button>
                    <button type="submit" className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:bg-indigo-300" disabled={loading}>
                        {loading ? 'Saving...' : 'Update Student'}
                    </button>
                </div>
            </form>
        </div>
    );
};

export default EditStudentPage;