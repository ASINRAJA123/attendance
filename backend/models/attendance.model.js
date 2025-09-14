const mongoose = require('mongoose');

const attendanceSchema = new mongoose.Schema({
    studentId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    teacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    classId: { type: String, required: true },
    // ADDED: The specific period for the attendance
    period: { type: String, required: true },
    // ADDED: To easily query by date
    date: { type: Date, required: true },
    // ADDED: To store the status, defaults to 'Present' on creation
    status: {
        type: String,
        enum: ['Present', 'Absent', 'Withheld'],
        default: 'Present'
    },
    timestamp: { type: Date, default: Date.now, required: true }
});

// Create a compound index to prevent duplicate attendance for the same student, period, and date
attendanceSchema.index({ studentId: 1, period: 1, date: 1 }, { unique: true });


module.exports = mongoose.model('Attendance', attendanceSchema);