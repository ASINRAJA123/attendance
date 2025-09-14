// controllers/student.controller.js

const Otp = require('../models/otp.model');
const Attendance = require('../models/attendance.model');
const User = require('../models/user.model');

// @desc    Mark attendance by submitting an OTP for a specific period
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
            return res.status(404).json({ message: 'Student not found.' });
        }

        const validOtp = await Otp.findOne({ otpCode: otp }).populate("teacherId", "name");
        if (!validOtp) {
            return res.status(400).json({ message: 'Invalid or expired OTP.' });
        }

        const { teacherId, period } = validOtp;

        if (!student.allTeachers && !student.assignedTeachers.some(t => t.toString() === teacherId._id.toString())) {
            return res.status(403).json({ message: 'This OTP is not from your assigned teacher.' });
        }
        
        // --- OLD, INCORRECT CODE ---
        // const today = new Date();
        // today.setHours(0, 0, 0, 0);

        // --- NEW, CORRECTED CODE ---
        // This creates a date object representing midnight UTC of the current day,
        // completely ignoring the server's local timezone.
        const todayUTC = new Date(new Date().toISOString().split('T')[0]);

        console.log(`[Mark Attendance] Saving record with UTC date: ${todayUTC.toISOString()}`);

        // Check for duplicates using the correct UTC date
        const existingAttendance = await Attendance.findOne({
            studentId,
            period,
            date: todayUTC
        });

        if (existingAttendance) {
            return res.status(400).json({ message: `Attendance already marked for the period "${period}" today.` });
        }

        // Create the attendance record using the correct UTC date
        await Attendance.create({
            studentId,
            teacherId: teacherId._id,
            classId: student.classId,
            period,
            date: todayUTC 
        });

        res.status(201).json({
            message: 'Attendance marked successfully!',
            teacherName: teacherId.name,
            period: period
        });

    } catch (error) {
        console.error("Mark Attendance Error:", error);
        if (error.code === 11000) {
            return res.status(400).json({ message: 'Attendance already marked for this period today.' });
        }
        res.status(500).json({ message: 'Server Error: ' + error.message });
    }
};


// --- Your getMyAttendanceHistory function is already correct, leave it as is ---
exports.getMyAttendanceHistory = async (req, res) => {
    // ... This function is now correct from our previous fix. No changes needed here.
    try {
        const studentId = req.user._id;
        const dateStr = req.query.date;

        if (!dateStr) {
            return res.status(400).json({ message: "Date query parameter is required." });
        }

        const startDate = new Date(dateStr + 'T00:00:00.000Z');
        const endDate = new Date(startDate);
        endDate.setDate(startDate.getDate() + 1);

        const records = await Attendance.find({
            studentId,
            date: { $gte: startDate, $lt: endDate }
        })
        .populate('teacherId', 'name')
        .sort({ timestamp: 1 });
        
        const formattedDate = startDate.toISOString().split('T')[0];

        if (!records || records.length === 0) {
            return res.json({ date: formattedDate, attendance: [] });
        }
        
        const formattedAttendance = records.map(r => ({
            period: r.period,
            status: r.status,
            markedBy: r.teacherId?.name || "Unknown Teacher",
        }));

        res.json({ date: formattedDate, attendance: formattedAttendance });

    } catch (error) {
        console.error("Get Attendance History Error:", error);
        res.status(500).json({ message: 'Server Error: ' + error.message });
    }
};