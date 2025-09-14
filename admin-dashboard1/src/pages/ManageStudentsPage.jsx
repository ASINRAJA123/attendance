// pages/ManageStudentsPage.jsx
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import api from '../api/axiosConfig';

const ManageStudentsPage = () => {
    const [students, setStudents] = useState([]);

    const fetchStudents = async () => {
        try {
            const { data } = await api.get('/admin/users');
            setStudents(data.filter(u => u.role === 'student'));
        } catch (error) {
            console.error('Failed to fetch students:', error);
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

    return (
        <>
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-3xl font-bold text-gray-800">Manage Students</h1>
                <Link to="/students/add" className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700">
                    Add Student
                </Link>
            </div>

            <div className="bg-white shadow-md rounded-lg overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                    {/* ... Table Head ... */}
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Roll Number</th>
                            <th>Email</th>
                            <th>Class</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                        {students.map((student) => (
                            <tr key={student._id}>
                                <td className="px-6 py-4">{student.name}</td>
                                <td className="px-6 py-4">{student.rollNumber}</td>
                                <td className="px-6 py-4">{student.email}</td>
                                <td className="px-6 py-4">{student.classId || 'N/A'}</td>
                                <td className="px-6 py-4 space-x-2">
                                    <Link to={`/students/report/${student._id}`} className="text-green-600 hover:underline">View</Link>
                                    <Link to={`/students/edit/${student._id}`} className="text-indigo-600 hover:underline">Edit</Link>
                                    <button onClick={() => handleDelete(student._id)} className="text-red-600 hover:underline">Delete</button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </>
    );
};
export default ManageStudentsPage;