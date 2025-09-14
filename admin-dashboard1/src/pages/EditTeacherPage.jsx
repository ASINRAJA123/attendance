// pages/EditTeacherPage.jsx

import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import api from '../api/axiosConfig';

const EditTeacherPage = () => {
    const { id } = useParams(); // Get the teacher ID from the URL
    const navigate = useNavigate();
    const [formData, setFormData] = useState({ name: '', email: '' });
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchTeacher = async () => {
            try {
                const { data } = await api.get(`/admin/users/${id}`);
                setFormData({
                    name: data.name,
                    email: data.email,
                });
            } catch (err) {
                setError('Failed to load teacher data.');
            } finally {
                setLoading(false);
            }
        };
        fetchTeacher();
    }, [id]);

    const handleChange = (e) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError('');
        try {
            await api.put(`/admin/users/${id}`, formData);
            navigate('/teachers');
        } catch (err) {
            setError(err.response?.data?.message || 'An unexpected error occurred.');
            setLoading(false);
        }
    };

    if (loading && !formData.name) {
        return <div>Loading teacher details...</div>;
    }

    return (
        <div>
            <h1 className="text-3xl font-bold mb-6">Edit Teacher</h1>
            <form onSubmit={handleSubmit} className="bg-white p-6 rounded-lg shadow-md max-w-lg mx-auto">
                <div className="space-y-4">
                    <div>
                        <label htmlFor="name" className="block text-sm font-medium text-gray-700">Full Name</label>
                        <input
                            id="name"
                            name="name"
                            type="text"
                            value={formData.name}
                            onChange={handleChange}
                            required
                            className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                        />
                    </div>
                    <div>
                        <label htmlFor="email" className="block text-sm font-medium text-gray-700">Email Address</label>
                        <input
                            id="email"
                            name="email"
                            type="email"
                            value={formData.email}
                            onChange={handleChange}
                            required
                            className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                        />
                    </div>
                </div>
                
                <p className="mt-4 text-sm text-gray-500">Password cannot be changed from this panel.</p>

                {error && <p className="mt-4 text-sm text-red-600">{error}</p>}

                <div className="flex justify-end space-x-4 mt-6">
                    <button
                        type="button"
                        onClick={() => navigate('/teachers')}
                        className="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300"
                        disabled={loading}
                    >
                        Cancel
                    </button>
                    <button
                        type="submit"
                        className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:bg-blue-300"
                        disabled={loading}
                    >
                        {loading ? 'Updating...' : 'Update Teacher'}
                    </button>
                </div>
            </form>
        </div>
    );
};

export default EditTeacherPage;