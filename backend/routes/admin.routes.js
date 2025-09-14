// routes/admin.routes.js

const express = require('express');
const router = express.Router();
const { protect, isAdmin } = require('../middleware/auth.middleware');
const { 
    createUser, 
    getUsers,
    getUserById,    // <-- Import
    updateUser,     // <-- Import
    deleteUser,     // <-- Import
    getStudentAttendanceReport, // <-- Import
    grantOtp        // <-- Import
} = require('../controllers/admin.controller');

router.use(protect, isAdmin);

// User Management Routes
router.route('/users')
    .post(createUser)
    .get(getUsers);

router.route('/users/:id')
    .get(getUserById)
    .put(updateUser)
    .delete(deleteUser);

// Reporting Routes
router.get('/reports/student/:studentId', getStudentAttendanceReport);

// OTP Granting Route
router.post('/otp/grant', grantOtp);

module.exports = router;