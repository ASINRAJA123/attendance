// pages/AddStudentPage.jsx
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../api/axiosConfig';

const AddStudentPage = () => {
    const [formData, setFormData] = useState({
        name: '',
        rollNumber: '',
        email: '',
        password: '',
        classId: '',
        role: 'student',
        assignedTeachers: [],
        allTeachers: false
    });

    const [allTeachers, setAllTeachers] = useState([]);
    const [loading, setLoading] = useState(true);
    const navigate = useNavigate();

    // Fetch all teachers for assignment
    useEffect(() => {
        const fetchTeachers = async () => {
            try {
                const res = await api.get('/admin/users');
                const teacherList = res.data.filter(user => user.role === 'teacher');
                setAllTeachers(teacherList);
            } catch (err) {
                console.error('Failed to load teachers:', err);
            } finally {
                setLoading(false);
            }
        };
        fetchTeachers();
    }, []);

    const handleChange = (e) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
    };

    const handleCheckboxChange = (e) => {
        setFormData({ ...formData, [e.target.name]: e.target.checked });
    };

    const handleTeacherSelect = (teacherId) => {
        const currentAssigned = formData.assignedTeachers;
        if (currentAssigned.includes(teacherId)) {
            setFormData({ ...formData, assignedTeachers: currentAssigned.filter(id => id !== teacherId) });
        } else {
            setFormData({ ...formData, assignedTeachers: [...currentAssigned, teacherId] });
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            await api.post('/admin/users', formData);
            navigate('/students');
        } catch (error) {
            console.error('Failed to add student:', error);
            alert('Error: ' + (error.response?.data?.message || error.message));
        }
    };

    if (loading) {
        return <div className="text-center p-8">Loading teacher list...</div>;
    }

    return (
        <div>
            <h1 className="text-3xl font-bold mb-6">Add New Student</h1>
            <form onSubmit={handleSubmit} className="bg-white p-6 rounded-lg shadow-md space-y-4">
                <input name="name" placeholder="Name" onChange={handleChange} required className="w-full border p-2 rounded" />
                <input name="rollNumber" placeholder="Roll Number" onChange={handleChange} required className="w-full border p-2 rounded" />
                <input type="email" name="email" placeholder="Email" onChange={handleChange} required className="w-full border p-2 rounded" />
                <input type="password" name="password" placeholder="Password" onChange={handleChange} required className="w-full border p-2 rounded" />
                <input name="classId" placeholder="Class ID" onChange={handleChange} className="w-full border p-2 rounded" />

                {/* Teacher Assignments */}
                <div className="border-t pt-6">
                    <h3 className="text-lg font-medium text-gray-900 mb-4">Teacher Assignments</h3>
                    <div className="flex items-center space-x-3 mb-4">
                        <input
                            id="allTeachers"
                            name="allTeachers"
                            type="checkbox"
                            checked={formData.allTeachers}
                            onChange={handleCheckboxChange}
                            className="h-4 w-4 text-indigo-600 border-gray-300 rounded"
                        />
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

                <div className="flex justify-end space-x-2">
                    <button type="button" onClick={() => navigate('/students')} className="px-4 py-2 bg-gray-300 rounded">Cancel</button>
                    <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded">Save Student</button>
                </div>
            </form>
        </div>
    );
};

export default AddStudentPage;
