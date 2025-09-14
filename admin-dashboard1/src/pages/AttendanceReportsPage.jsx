import React, { useState, useEffect } from 'react';
import api from '../api/axiosConfig';

const AttendanceReportsPage = () => {
    const [records, setRecords] = useState([]);
    const [filters, setFilters] = useState({ classId: '', teacherId: '', date: '' });
    const [teachers, setTeachers] = useState([]);

    const fetchReports = async () => {
        try {
            const { data } = await api.get('/admin/reports/attendance', { params: filters });
            setRecords(data);
        } catch (error) {
            console.error('Failed to fetch reports:', error);
        }
    };

    const fetchTeachers = async () => {
        try {
            const { data } = await api.get('/admin/users');
            setTeachers(data.filter(u => u.role === 'teacher'));
        } catch (error) {
            console.error('Failed to fetch teachers:', error);
        }
    };

    useEffect(() => {
        fetchReports();
        fetchTeachers();
    }, [filters]);

    return (
        <>
            <h1 className="text-3xl font-bold text-gray-800 mb-6">Attendance Reports</h1>

            <div className="mb-4 flex space-x-4">
                <input
                    type="text"
                    placeholder="Class ID"
                    className="border p-2 rounded"
                    value={filters.classId}
                    onChange={(e) => setFilters({ ...filters, classId: e.target.value })}
                />
                <select
                    className="border p-2 rounded"
                    value={filters.teacherId}
                    onChange={(e) => setFilters({ ...filters, teacherId: e.target.value })}
                >
                    <option value="">All Teachers</option>
                    {teachers.map(t => (
                        <option key={t._id} value={t._id}>{t.name}</option>
                    ))}
                </select>
                <input
                    type="date"
                    className="border p-2 rounded"
                    value={filters.date}
                    onChange={(e) => setFilters({ ...filters, date: e.target.value })}
                />
                <button onClick={fetchReports} className="px-4 py-2 bg-blue-600 text-white rounded">Filter</button>
            </div>

            <div className="bg-white shadow-md rounded-lg overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="min-w-full divide-y divide-gray-200">
                        <thead className="bg-gray-50">
                            <tr>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Student Name</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Teacher</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Class ID</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Timestamp</th>
                            </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-200">
                            {records.map((record) => (
                                <tr key={record._id}>
                                    <td className="px-6 py-4">{record.studentId?.name || 'N/A'}</td>
                                    <td className="px-6 py-4">{record.teacherId?.name || 'N/A'}</td>
                                    <td className="px-6 py-4">{record.classId}</td>
                                    <td className="px-6 py-4">{new Date(record.timestamp).toLocaleString()}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>
        </>
    );
};

export default AttendanceReportsPage;
