// controllers/teacher.controller.js

const Otp = require('../models/otp.model');
const Attendance = require('../models/attendance.model'); // <-- Add this require

// ... (keep the existing generateOtp function) ...
exports.generateOtp = async (req, res) => {
    // ... your existing code for this function is fine
    const { period } = req.body;
    
    if (!period) {
        return res.status(400).json({ message: 'Period is required to generate an OTP.' });
    }

    try {
        const teacherId = req.user._id;
        const otpCode = Math.floor(100000 + Math.random() * 900000).toString();

        await Otp.create({
            otpCode,
            teacherId,
            period
        });

        console.log(`Generated OTP for teacher ${teacherId} for period "${period}": ${otpCode}`);
        res.status(201).json({ otp: otpCode, period: period });

    } catch (error) {
        console.error('Error generating OTP:', error);
        res.status(500).json({ message: 'Server Error: ' + error.message });
    }
};


// @desc    Get attendance report for a specific period
// @route   GET /api/teacher/attendance/report?date=YYYY-MM-DD&period=...
// @access  Private (Teacher)
// controllers/teacher.controller.js

// ... (keep generateOtp as is)

// @desc    Get attendance report for a specific period
// @route   GET /api/teacher/attendance/report?date=YYYY-MM-DD&period=...
exports.getAttendanceReport = async (req, res) => {
    try {
        const teacherId = req.user._id;
        const { date, period } = req.query;

        if (!date || !period) {
            return res.status(400).json({ message: 'Date and period are required query parameters.' });
        }
        
        // --- NEW, CORRECTED QUERY LOGIC ---
        // Create a date for the start of the requested day (in UTC)
        const startDate = new Date(date + 'T00:00:00.000Z');

        // Create a date for the start of the NEXT day (in UTC)
        const endDate = new Date(startDate);
        endDate.setDate(startDate.getDate() + 1);

        console.log(`[Teacher Report] Searching for records for teacher ${teacherId} between ${startDate.toISOString()} and ${endDate.toISOString()}`);

        const records = await Attendance.find({
            teacherId,
            period, // Keep the period filter
            date: {
                $gte: startDate, // Greater than or equal to the start of the day
                $lt: endDate      // Less than the start of the next day
            }
        }).populate('studentId', 'name rollNumber');

        // --- The rest of the function remains the same ---
        const formattedStudents = records.map(rec => ({
            name: rec.studentId?.name || 'Unknown Student',
            rollNumber: rec.studentId?.rollNumber || 'N/A',
        }));

        res.json(formattedStudents);

    } catch (error) {
        console.error('Error fetching attendance report:', error);
        res.status(500).json({ message: 'Server Error: ' + error.message });
    }
};