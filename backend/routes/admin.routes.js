const express = require('express');
const router = express.Router();
const { protect, isAdmin } = require('../middleware/auth.middleware');
const { 
    createUser, 
    getUsers,
    getAttendanceReports 
} = require('../controllers/admin.controller');

// All routes here are protected and require admin access
router.use(protect, isAdmin);

router.route('/users')
    .post((req, res, next) => {
        console.log('POST /api/admin/users called with body:', req.body);
        next();
    }, createUser)
    .get((req, res, next) => {
        console.log('GET /api/admin/users called');
        next();
    }, getUsers);

router.route('/reports/attendance')
    .get((req, res, next) => {
        console.log('GET /api/admin/reports/attendance called');
        next();
    }, getAttendanceReports);

module.exports = router;
