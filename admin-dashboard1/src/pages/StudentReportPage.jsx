// pages/StudentReportPage.jsx
import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import api from '../api/axiosConfig';
import { format } from 'date-fns';

const StudentReportPage = () => {
    const { id } = useParams();
    const [student, setStudent] = useState(null);
    const [attendance, setAttendance] = useState([]);
    const [filterDate, setFilterDate] = useState('');
    const [loading, setLoading] = useState(true); // Added loading state
    const [error, setError] = useState('');       // Added error state

    useEffect(() => {
        const fetchDetails = async () => {
            setLoading(true);
            setError('');
            try {
                const [userRes, attendanceRes] = await Promise.all([
                    api.get(`/admin/users/${id}`),
                    api.get(`/admin/reports/student/${id}`)
                ]);
                setStudent(userRes.data);
                setAttendance(attendanceRes.data);
            } catch (error) {
                console.error('Failed to fetch student details:', error);
                setError('Could not load student data.');
            } finally {
                setLoading(false);
            }
        };
        fetchDetails();
    }, [id]);

    const filteredAttendance = attendance.filter(record => 
        !filterDate || (record.date && format(new Date(record.date), 'yyyy-MM-dd') === filterDate)
    );

    if (loading) return <div>Loading student report...</div>;
    if (error) return <div className="text-red-500">{error}</div>;
    if (!student) return <div>Student not found.</div>;

    return (
        <div>
            <h1 className="text-3xl font-bold mb-2">Attendance Report for {student.name}</h1>
            <p className="text-gray-600 mb-6">Roll Number: {student.rollNumber}</p>
            
            <div className="mb-4 flex items-center space-x-4">
                <label htmlFor="dateFilter" className="font-medium">Filter by Date:</label>
                <input 
                    id="dateFilter"
                    type="date" 
                    value={filterDate}
                    onChange={(e) => setFilterDate(e.target.value)}
                    className="border p-2 rounded shadow-sm"
                />
                 <button onClick={() => setFilterDate('')} className="text-sm text-blue-600 hover:underline">Clear</button>
            </div>

            <div className="bg-white shadow-md rounded-lg overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                     <thead className="bg-gray-50">
                        <tr>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Period</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Marked By</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                        </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                        {filteredAttendance.length > 0 ? (
                            filteredAttendance.map(record => (
                                <tr key={record._id}>
                                    <td className="px-6 py-4 whitespace-nowrap">
                                        {/* --- THIS IS THE FIX --- */}
                                        {/* Check if record.date exists before formatting */}
                                        {record.date ? format(new Date(record.date), 'dd-MMM-yyyy') : 'Invalid Date'}
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap">{record.period}</td>
                                    <td className="px-6 py-4 whitespace-nowrap">{record.teacherId?.name || 'N/A'}</td>
                                    <td className="px-6 py-4 whitespace-nowrap">{record.status}</td>
                                </tr>
                            ))
                        ) : (
                            <tr>
                                <td colSpan="4" className="text-center py-8 text-gray-500">No attendance records found for this filter.</td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default StudentReportPage;