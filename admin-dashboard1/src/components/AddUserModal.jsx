import React, { useState } from 'react';

const AddUserModal = ({ open, handleClose, handleSubmit }) => {
    const [formData, setFormData] = useState({
        name: '',
        email: '',
        password: '',
        role: 'student',
        classId: '',
    });

    if (!open) return null;

    const handleChange = (e) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
    };

    const onFormSubmit = (e) => {
        e.preventDefault();
        handleSubmit(formData);
    };

    return (
        <div 
            className="fixed inset-0 bg-black bg-opacity-50 z-50 flex justify-center items-center"
            onClick={handleClose}
        >
            <div 
                className="bg-white p-8 rounded-lg shadow-xl w-full max-w-md"
                onClick={e => e.stopPropagation()} // Prevent closing modal when clicking inside
            >
                <h2 className="text-2xl font-bold mb-6">Add New User</h2>
                <form onSubmit={onFormSubmit} className="space-y-4">
                    <input type="text" name="name" placeholder="Full Name" required value={formData.name} onChange={handleChange} className="w-full p-2 border rounded-md" />
                    <input type="email" name="email" placeholder="Email" required value={formData.email} onChange={handleChange} className="w-full p-2 border rounded-md" />
                    <input type="password" name="password" placeholder="Password" required value={formData.password} onChange={handleChange} className="w-full p-2 border rounded-md" />
                    <select name="role" value={formData.role} onChange={handleChange} className="w-full p-2 border rounded-md">
                        <option value="student">Student</option>
                        <option value="teacher">Teacher</option>
                        <option value="admin">Admin</option>
                    </select>
                    {formData.role === 'student' && (
                        <input type="text" name="classId" placeholder="Class ID" value={formData.classId} onChange={handleChange} className="w-full p-2 border rounded-md" />
                    )}
                    <div className="flex justify-end space-x-4 mt-6">
                        <button type="button" onClick={handleClose} className="px-4 py-2 bg-gray-300 rounded-md hover:bg-gray-400">Cancel</button>
                        <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">Create User</button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default AddUserModal;