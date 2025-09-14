const Otp = require('../models/otp.model');

// @desc    Generate a new OTP for the logged-in teacher
// @route   POST /api/teacher/otp/generate
exports.generateOtp = async (req, res) => {
    try {
        const teacherId = req.user._id;

        const now = new Date();
        const hour = now.getHours();
        const minutes = now.getMinutes();

        // Rule: 9 AM to 5 PM (hour 17) and first 10 minutes of any hour
        if (hour < 9 || hour > 17 || minutes > 10) {
            return res.status(400).json({ message: 'OTP can only be generated during the first 10 minutes of a class hour (9 AM - 5 PM).' });
        }

        const otpCode = Math.floor(100000 + Math.random() * 900000).toString();

        await Otp.create({
            otpCode,
            teacherId: teacherId
        });

        res.status(201).json({ otp: otpCode });

    } catch (error) {
        res.status(500).json({ message: 'Server Error: ' + error.message });
    }
};