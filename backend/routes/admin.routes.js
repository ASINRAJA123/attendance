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

router.route('/users').post(createUser).get(getUsers);
router.route('/reports/attendance').get(getAttendanceReports);

module.exports = router;