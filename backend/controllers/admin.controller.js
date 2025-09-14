const User = require('../models/user.model');
const Attendance = require('../models/attendance.model');

// @desc    Create a new user (by admin)
// @route   POST /api/admin/users
exports.createUser = async (req, res) => {
    const { name, email, password, role, classId, assignedTeacher, assignedTeacherEmail } = req.body;

    try {
        const userExists = await User.findOne({ email });
        if (userExists) {
            return res.status(400).json({ message: 'User already exists' });
        }

        let teacherId = null;

        // If frontend sends teacherId directly
        if (assignedTeacher) {
            const teacher = await User.findOne({ _id: assignedTeacher, role: 'teacher' });
            if (teacher) teacherId = teacher._id;
        }

        // If frontend sends teacherEmail
        if (!teacherId && assignedTeacherEmail) {
            const teacher = await User.findOne({ email: assignedTeacherEmail, role: 'teacher' });
            if (teacher) teacherId = teacher._id;
        }

        const user = await User.create({
            name,
            email,
            passwordHash: password, // pre-save hook will hash this
            role,
            classId,
            assignedTeacher: teacherId
        });

        res.status(201).json({
            _id: user._id,
            name: user.name,
            email: user.email,
            role: user.role,
            classId: user.classId,
            assignedTeacher: user.assignedTeacher
        });
    } catch (error) {
        res.status(500).json({ message: 'Server Error: ' + error.message });
    }
};

// @desc    Get all users
// @route   GET /api/admin/users
exports.getUsers = async (req, res) => {
    try {
        const users = await User.find({})
            .select('-passwordHash')
            .populate('assignedTeacher', 'name email'); // populate teacher info

        res.json(users);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Get attendance reports
// @route   GET /api/admin/reports/attendance
exports.getAttendanceReports = async (req, res) => {
    try {
        const attendanceRecords = await Attendance.find({})
            .populate('studentId', 'name email')
            .populate('teacherId', 'name email');
        res.json(attendanceRecords);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};
