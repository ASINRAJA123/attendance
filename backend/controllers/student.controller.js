const Otp = require('../models/otp.model');
const Attendance = require('../models/attendance.model');
const User = require('../models/user.model');

// @desc    Mark attendance by submitting an OTP
// @route   POST /api/student/attendance/mark
exports.markAttendance = async (req, res) => {
    const { otp } = req.body;
    const studentId = req.user._id;

    if (!otp) {
        return res.status(400).json({ message: 'OTP is required' });
    }

    try {
        const student = await User.findById(studentId);
        if (!student || !student.assignedTeacher) {
            return res.status(400).json({ message: 'You are not assigned to any teacher.' });
        }
        const teacherId = student.assignedTeacher;

        // Check if OTP exists for this teacher
        const validOtp = await Otp.findOne({ otpCode: otp, teacherId: teacherId });
        if (!validOtp) {
            return res.status(400).json({ message: 'Invalid or expired OTP.' });
        }

        // Check if attendance is already marked in last 1 hour
        const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
        const existingAttendance = await Attendance.findOne({
            studentId: studentId,
            teacherId: teacherId,
            timestamp: { $gte: oneHourAgo }
        });

        if (existingAttendance) {
            return res.status(400).json({ message: 'Attendance already marked for this session.' });
        }

        // Create attendance record
        await Attendance.create({
            studentId: studentId,
            teacherId: teacherId,
            classId: student.classId
        });

        console.log(`POST /api/student/attendance/mark called by user: ${studentId}`);
        console.log(`OTP used: ${otp}`);

        res.status(201).json({ message: 'Attendance marked successfully!' });

    } catch (error) {
        console.error('Error marking attendance:', error);
        res.status(500).json({ message: 'Server Error: ' + error.message });
    }
};
