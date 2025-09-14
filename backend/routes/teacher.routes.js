// routes/teacher.routes.js

const express = require('express');
const router = express.Router();
const { protect, isTeacher } = require('../middleware/auth.middleware');
// <-- Import the new controller function
const { generateOtp, getAttendanceReport } = require('../controllers/teacher.controller');

router.use(protect, isTeacher);

// Existing route for generating OTP
router.post('/otp/generate', generateOtp);

// NEW route for getting attendance reports
router.get('/attendance/report', getAttendanceReport);

module.exports = router;