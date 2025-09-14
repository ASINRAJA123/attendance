// pages/ManageStudentsPage.jsx

import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import api from '../api/axiosConfig';

const ManageStudentsPage = () => {
    const [students, setStudents] = useState([]);
    const [loading, setLoading] = useState(true);
    // --- NEW: State for the search term ---
    const [searchTerm, setSearchTerm] = useState('');

    const fetchStudents = async () => {
        setLoading(true);
        try {
            const { data } = await api.get('/admin/users');
            setStudents(data.filter(u => u.role === 'student'));
        } catch (error) {
            console.error('Failed to fetch students:', error);
            alert('Could not load students.');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchStudents();
    }, []);

    const handleDelete = async (studentId) => {
        if (window.confirm('Are you sure you want to delete this student?')) {
            try {
                await api.delete(`/admin/users/${studentId}`);
                fetchStudents(); // Refresh the list
            } catch (error) {
                console.error('Failed to delete student:', error);
                alert('Failed to delete student.');
            }
        }
    };

    // --- NEW: Filter students based on the search term ---
    const filteredStudents = students.filter(student =>
        student.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (student.rollNumber && student.rollNumber.toLowerCase().includes(searchTerm.toLowerCase())) ||
        student.email.toLowerCase().includes(searchTerm.toLowerCase())
    );

    if (loading) {
        return <div>Loading students...</div>;
    }

    return (
        <>
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-3xl font-bold text-gray-800">Manage Students</h1>
                <Link to="/students/add" className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700">
                    Add Student
                </Link>
            </div>

            {/* --- NEW: Search Bar UI --- */}
            <div className="mb-4">
                <input
                    type="text"
                    placeholder="Search by name, roll no, or email..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="w-full max-w-md p-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                />
            </div>
            {/* --- End of Search Bar --- */}

            <div className="bg-white shadow-md rounded-lg overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                        <tr>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Roll Number</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Class</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                        {/* --- MODIFIED: Map over the filtered list --- */}
                        {filteredStudents.length > 0 ? (
                            filteredStudents.map((student) => (
                                <tr key={student._id}>
                                    <td className="px-6 py-4">{student.name}</td>
                                    <td className="px-6 py-4">{student.rollNumber}</td>
                                    <td className="px-6 py-4">{student.email}</td>
                                    <td className="px-6 py-4">{student.classId || 'N/A'}</td>
                                    <td className="px-6 py-4 space-x-2 whitespace-nowrap">
                                        <Link to={`/students/report/${student._id}`} className="text-green-600 hover:underline">View</Link>
                                        <Link to={`/students/edit/${student._id}`} className="text-indigo-600 hover:underline">Edit</Link>
                                        <button onClick={() => handleDelete(student._id)} className="text-red-600 hover:underline">Delete</button>
                                    </td>
                                </tr>
                            ))
                        ) : (
                            <tr>
                                <td colSpan="5" className="px-6 py-4 text-center text-gray-500">
                                    No students found matching your search.
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>
        </>
    );
};
export default ManageStudentsPage;