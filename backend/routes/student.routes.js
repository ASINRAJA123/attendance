const express = require('express');
const router = express.Router();
const { protect, isStudent } = require('../middleware/auth.middleware');
const { markAttendance, getMyAttendanceHistory } = require('../controllers/student.controller');

router.use(protect, isStudent);

router.post('/attendance/mark', (req, res, next) => {
    console.log('POST /api/student/attendance/mark called by user:', req.user?.id);
    console.log('Request body:', req.body);
    next();
}, markAttendance);

router.get('/attendance/history', getMyAttendanceHistory);

module.exports = router;
