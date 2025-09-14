const mongoose = require('mongoose');
const attendanceSchema = new mongoose.Schema({
    studentId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    teacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    classId: { type: String, required: true },
    timestamp: { type: Date, default: Date.now, required: true }
});
module.exports = mongoose.model('Attendance', attendanceSchema);