const mongoose = require('mongoose');
const otpSchema = new mongoose.Schema({
    otpCode: { type: String, required: true },
    teacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    createdAt: { type: Date, default: Date.now, expires: '15s' } // Document will be auto-deleted after 15 seconds
});
module.exports = mongoose.model('Otp', otpSchema);