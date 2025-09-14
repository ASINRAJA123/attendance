const express = require('express');
const router = express.Router();
const { protect, isTeacher } = require('../middleware/auth.middleware');
const { generateOtp } = require('../controllers/teacher.controller');

router.use(protect, isTeacher);

router.post('/otp/generate', (req, res, next) => {
    console.log('POST /api/teacher/otp/generate called by user:', req.user?.id);
    next();
}, generateOtp);

module.exports = router;
