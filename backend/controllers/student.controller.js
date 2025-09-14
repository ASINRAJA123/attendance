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
        if (!student) {
            return res.status(400).json({ message: 'Student not found.' });
        }

        // Find OTP record
        const validOtp = await Otp.findOne({ otpCode: otp }).populate("teacherId", "name");
        if (!validOtp) {
            return res.status(400).json({ message: 'Invalid or expired OTP.' });
        }

        const teacherId = validOtp.teacherId._id;

        // --- Check if student is linked to teacher ---
        if (!student.assignedTeachers || student.assignedTeachers.length === 0) {
            return res.status(400).json({ message: 'You are not assigned to any teacher.' });
        }

        if (!student.assignedTeachers.some(t => t.toString() === teacherId.toString())) {
            return res.status(400).json({ message: 'This OTP is not from your assigned teacher(s).' });
        }

        // --- Prevent duplicate attendance in last 1 hour ---
        const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
        const existingAttendance = await Attendance.findOne({
            studentId,
            teacherId,
            timestamp: { $gte: oneHourAgo }
        });

        if (existingAttendance) {
            return res.status(400).json({ message: 'Attendance already marked for this session.' });
        }

        await Attendance.create({
            studentId,
            teacherId,
            classId: student.classId
        });

        res.status(201).json({ 
            message: 'Attendance marked successfully!',
            teacherName: validOtp.teacherId.name 
        });

    } catch (error) {
        console.error("Mark Attendance Error:", error);
        res.status(500).json({ message: 'Server Error: ' + error.message });
    }
};

// @route   GET /api/student/attendance/history
exports.getMyAttendanceHistory = async (req, res) => {
    try {
        const studentId = req.user._id;
        const records = await Attendance.find({ studentId })
            .populate('teacherId', 'name email')
            .sort({ timestamp: -1 });

        const formatted = records.map(r => ({
            teacherName: r.teacherId?.name || "Unknown",
            teacherEmail: r.teacherId?.email || "",
            classId: r.classId,
            timestamp: r.timestamp,
        }));

        res.json(formatted);
    } catch (error) {
        res.status(500).json({ message: 'Server Error: ' + error.message });
    }
};
