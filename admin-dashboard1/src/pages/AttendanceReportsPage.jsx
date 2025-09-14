import React, { useState, useEffect } from 'react';
import api from '../api/axiosConfig';

const AttendanceReportsPage = () => {
    const [records, setRecords] = useState([]);

    useEffect(() => {
        const fetchReports = async () => {
            try {
                const { data } = await api.get('/admin/reports/attendance');
                setRecords(data);
            } catch (error) {
                console.error('Failed to fetch reports:', error);
            }
        };
        fetchReports();
    }, []);

    return (
        <>
            <h1 className="text-3xl font-bold text-gray-800 mb-6">Attendance Reports</h1>

            <div className="bg-white shadow-md rounded-lg overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="min-w-full divide-y divide-gray-200">
                        <thead className="bg-gray-50">
                            <tr>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Student Name</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Teacher</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Class ID</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Timestamp</th>
                            </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-200">
                            {records.map((record) => (
                                <tr key={record._id}>
                                    <td className="px-6 py-4 whitespace-nowrap">{record.studentId?.name || 'N/A'}</td>
                                    <td className="px-6 py-4 whitespace-nowrap">{record.teacherId?.name || 'N/A'}</td>
                                    <td className="px-6 py-4 whitespace-nowrap">{record.classId}</td>
                                    <td className="px-6 py-4 whitespace-nowrap">{new Date(record.timestamp).toLocaleString()}</td>
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