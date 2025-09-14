import React, { useState } from 'react';

const AddUserModal = ({ open, handleClose, handleSubmit, teachers }) => {
    const [formData, setFormData] = useState({
        name: '',
        email: '',
        password: '',
        role: 'student',
        classId: '',
        assignedTeachers: [],
        allTeachers: false
    });

    const handleChange = (e) => {
        const { name, value, type, checked } = e.target;
        if (type === 'checkbox') {
            setFormData(prev => ({ ...prev, [name]: checked }));
        } else {
            setFormData(prev => ({ ...prev, [name]: value }));
        }
    };

    const handleTeacherSelect = (teacherId) => {
        setFormData(prev => {
            if (prev.assignedTeachers.includes(teacherId)) {
                return { ...prev, assignedTeachers: prev.assignedTeachers.filter(id => id !== teacherId) };
            } else {
                return { ...prev, assignedTeachers: [...prev.assignedTeachers, teacherId] };
            }
        });
    };

    const onSubmit = (e) => {
        e.preventDefault();
        handleSubmit(formData);
    };

    if (!open) return null;

    return (
        <div className="fixed inset-0 bg-gray-900 bg-opacity-50 flex justify-center items-center">
            <div className="bg-white rounded-lg p-6 w-full max-w-lg">
                <h2 className="text-xl font-bold mb-4">Add User</h2>
                <form onSubmit={onSubmit} className="space-y-4">
                    <input type="text" name="name" placeholder="Name" className="w-full border p-2 rounded" value={formData.name} onChange={handleChange} required />
                    <input type="email" name="email" placeholder="Email" className="w-full border p-2 rounded" value={formData.email} onChange={handleChange} required />
                    <input type="password" name="password" placeholder="Password" className="w-full border p-2 rounded" value={formData.password} onChange={handleChange} required />

                    <select name="role" className="w-full border p-2 rounded" value={formData.role} onChange={handleChange}>
                        <option value="student">Student</option>
                        <option value="teacher">Teacher</option>
                        <option value="admin">Admin</option>
                    </select>

                    {formData.role === 'student' && (
                        <>
                            <input type="text" name="classId" placeholder="Class ID" className="w-full border p-2 rounded" value={formData.classId} onChange={handleChange} />

                            <div className="flex items-center space-x-2">
                                <input type="checkbox" name="allTeachers" checked={formData.allTeachers} onChange={handleChange} />
                                <label>Allow all teachers</label>
                            </div>

                            {!formData.allTeachers && (
                                <div>
                                    <label className="block text-sm font-medium mb-2">Assign Teachers</label>
                                    <div className="grid grid-cols-2 gap-2">
                                        {teachers.map(t => (
                                            <div key={t._id} className="flex items-center space-x-2">
                                                <input
                                                    type="checkbox"
                                                    checked={formData.assignedTeachers.includes(t._id)}
                                                    onChange={() => handleTeacherSelect(t._id)}
                                                />
                                                <span>{t.name}</span>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            )}
                        </>
                    )}

                    <div className="flex justify-end space-x-2">
                        <button type="button" onClick={handleClose} className="px-4 py-2 bg-gray-300 rounded">Cancel</button>
                        <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded">Save</button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default AddUserModal;
