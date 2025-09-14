const mongoose = require('mongoose');

const otpSchema = new mongoose.Schema({
    otpCode: { type: String, required: true },
    teacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    // ADDED: To specify which class period this OTP is for
    period: { type: String, required: true }, 
    // Increased expiry for practical usage
    createdAt: { type: Date, default: Date.now, expires: '10m' } 
});

module.exports = mongoose.model('Otp', otpSchema);