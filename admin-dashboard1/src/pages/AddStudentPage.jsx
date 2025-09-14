// pages/AddStudentPage.jsx
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../api/axiosConfig';

const AddStudentPage = () => {
    const [formData, setFormData] = useState({ name: '', rollNumber: '', email: '', password: '', classId: '', role: 'student' });
    const navigate = useNavigate();

    const handleChange = (e) => setFormData({ ...formData, [e.target.name]: e.target.value });

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

    return (
        <div>
            <h1 className="text-3xl font-bold mb-6">Add New Student</h1>
            <form onSubmit={handleSubmit} className="bg-white p-6 rounded-lg shadow-md space-y-4">
                <input name="name" placeholder="Name" onChange={handleChange} required className="w-full border p-2 rounded" />
                <input name="rollNumber" placeholder="Roll Number" onChange={handleChange} required className="w-full border p-2 rounded" />
                <input type="email" name="email" placeholder="Email" onChange={handleChange} required className="w-full border p-2 rounded" />
                <input type="password" name="password" placeholder="Password" onChange={handleChange} required className="w-full border p-2 rounded" />
                <input name="classId" placeholder="Class ID" onChange={handleChange} className="w-full border p-2 rounded" />
                <div className="flex justify-end space-x-2">
                    <button type="button" onClick={() => navigate('/students')} className="px-4 py-2 bg-gray-300 rounded">Cancel</button>
                    <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded">Save Student</button>
                </div>
            </form>
        </div>
    );
};
export default AddStudentPage;