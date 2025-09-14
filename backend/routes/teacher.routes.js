const express = require('express');
const router = express.Router();
const { protect, isTeacher } = require('../middleware/auth.middleware');
const { generateOtp } = require('../controllers/teacher.controller');

router.use(protect, isTeacher);

router.post('/otp/generate', generateOtp);

module.exports = router;