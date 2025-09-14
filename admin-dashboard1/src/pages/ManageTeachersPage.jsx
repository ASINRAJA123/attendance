// pages/ManageTeachersPage.jsx

import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import api from '../api/axiosConfig';

const ManageTeachersPage = () => {
    const [teachers, setTeachers] = useState([]);
    const [loading, setLoading] = useState(true);

    const fetchTeachers = async () => {
        setLoading(true);
        try {
            const { data } = await api.get('/admin/users');
            setTeachers(data.filter(u => u.role === 'teacher'));
        } catch (error) {
            console.error('Failed to fetch teachers:', error);
            alert('Could not load teachers.');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchTeachers();
    }, []);

    const handleDelete = async (teacherId) => {
        if (window.confirm('Are you sure you want to delete this teacher? This may affect student assignments.')) {
            try {
                await api.delete(`/admin/users/${teacherId}`);
                // Refresh the list after deletion
                fetchTeachers();
            } catch (error) {
                console.error('Failed to delete teacher:', error);
                alert('Failed to delete teacher.');
            }
        }
    };

    if (loading) {
        return <div>Loading teachers...</div>;
    }

    return (
        <>
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-3xl font-bold text-gray-800">Manage Teachers</h1>
                <Link to="/teachers/add" className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition-colors">
                    Add Teacher
                </Link>
            </div>

            <div className="bg-white shadow-md rounded-lg overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                        <tr>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                        {teachers.length > 0 ? (
                            teachers.map((teacher) => (
                                <tr key={teacher._id}>
                                    <td className="px-6 py-4 whitespace-nowrap">{teacher.name}</td>
                                    <td className="px-6 py-4 whitespace-nowrap">{teacher.email}</td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-4">
                                        <Link to={`/teachers/edit/${teacher._id}`} className="text-indigo-600 hover:text-indigo-900">Edit</Link>
                                        <button onClick={() => handleDelete(teacher._id)} className="text-red-600 hover:text-red-900">Delete</button>
                                    </td>
                                </tr>
                            ))
                        ) : (
                            <tr>
                                <td colSpan="3" className="px-6 py-4 text-center text-gray-500">No teachers found.</td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>
        </>
    );
};

export default ManageTeachersPage;