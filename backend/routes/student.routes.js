const express = require('express');
const router = express.Router();
const { protect, isStudent } = require('../middleware/auth.middleware');
const { markAttendance } = require('../controllers/student.controller');

router.use(protect, isStudent);

router.post('/attendance/mark', markAttendance);

module.exports = router;