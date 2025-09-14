const User = require('../models/user.model');
const Attendance = require('../models/attendance.model');

// @desc    Create a new user (by admin)
// @route   POST /api/admin/users
exports.createUser = async (req, res) => {
    // ADDED rollNumber
    const { name, rollNumber, email, password, role, classId, allTeachers, assignedTeachers, assignedTeacherEmail } = req.body;

    try {
        const emailExists = await User.findOne({ email });
        if (emailExists) {
            return res.status(400).json({ message: 'User with this email already exists' });
        }

        if (role === 'student') {
            const rollNumberExists = await User.findOne({ rollNumber });
            if (rollNumberExists) {
                return res.status(400).json({ message: 'User with this roll number already exists' });
            }
        }

        let teacherIds = [];
        if (role === 'student') {
            if (allTeachers) {
                teacherIds = [];
            } else {
                if (assignedTeachers && Array.isArray(assignedTeachers)) {
                    const teachers = await User.find({ _id: { $in: assignedTeachers }, role: 'teacher' });
                    teacherIds = teachers.map(t => t._id);
                }
                if (assignedTeacherEmail) {
                    const teacher = await User.findOne({ email: assignedTeacherEmail, role: 'teacher' });
                    if (teacher) teacherIds.push(teacher._id);
                }
            }
        }

        const user = await User.create({
            name,
            rollNumber: role === 'student' ? rollNumber : null, // Store rollNumber only for students
            email,
            passwordHash: password,
            role,
            classId,
            allTeachers: role === 'student' ? allTeachers || false : false,
            assignedTeachers: role === 'student' ? teacherIds : []
        });

        res.status(201).json({
            _id: user._id,
            name: user.name,
            rollNumber: user.rollNumber,
            email: user.email,
            role: user.role,
            classId: user.classId,
            allTeachers: user.allTeachers,
            assignedTeachers: user.assignedTeachers
        });
    } catch (error) {
        console.error("Create user error:", error);
        res.status(500).json({ message: 'Server Error: ' + error.message });
    }
};

// @desc    Get all users
// @route   GET /api/admin/users
exports.getUsers = async (req, res) => {
    try {
        const users = await User.find({})
            .select('-passwordHash')
            .populate('assignedTeachers', 'name email');

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
            .populate('studentId', 'name email rollNumber') // ADDED rollNumber
            .populate('teacherId', 'name email');
        res.json(attendanceRecords);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};