const User = require('../models/user.model');
const Attendance = require('../models/attendance.model');

// @desc    Create a new user (by admin)
// @route   POST /api/admin/users
exports.createUser = async (req, res) => {
    const { name, email, password, role, classId, allTeachers, assignedTeachers, assignedTeacherEmail } = req.body;

    try {
        const userExists = await User.findOne({ email });
        if (userExists) {
            return res.status(400).json({ message: 'User already exists' });
        }

        let teacherIds = [];

        if (role === 'student') {
            // If student is assigned to all teachers
            if (allTeachers) {
                teacherIds = []; // will mean "all teachers allowed"
            } else {
                // If frontend sends teacher IDs
                if (assignedTeachers && Array.isArray(assignedTeachers)) {
                    const teachers = await User.find({ _id: { $in: assignedTeachers }, role: 'teacher' });
                    teacherIds = teachers.map(t => t._id);
                }

                // If frontend sends teacher email
                if (assignedTeacherEmail) {
                    const teacher = await User.findOne({ email: assignedTeacherEmail, role: 'teacher' });
                    if (teacher) teacherIds.push(teacher._id);
                }
            }
        }

        const user = await User.create({
            name,
            email,
            passwordHash: password, // pre-save hook will hash
            role,
            classId,
            allTeachers: role === 'student' ? allTeachers || false : false,
            assignedTeachers: role === 'student' ? teacherIds : []
        });

        res.status(201).json({
            _id: user._id,
            name: user.name,
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
            .populate('assignedTeachers', 'name email'); // now supports multiple

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
