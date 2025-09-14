const Otp = require('../models/otp.model');

// @desc    Generate a new OTP for the logged-in teacher
// @route   POST /api/teacher/otp/generate
exports.generateOtp = async (req, res) => {
    try {
        const teacherId = req.user._id;

        // Generate a 6-digit OTP
        const otpCode = Math.floor(100000 + Math.random() * 900000).toString();

        await Otp.create({
            otpCode,
            teacherId: teacherId
        });

        console.log(`POST /api/teacher/otp/generate called by user: ${teacherId}`);
        console.log(`Generated OTP: ${otpCode}`);

        res.status(201).json({ otp: otpCode });

    } catch (error) {
        console.error('Error generating OTP:', error);
        res.status(500).json({ message: 'Server Error: ' + error.message });
    }
};
