const User = require('../models/user.model');
const Attendance = require('../models/attendance.model');
const Otp = require('../models/otp.model'); // <-- Add Otp model

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

exports.getUserById = async (req, res) => {
    try {
        const user = await User.findById(req.params.id)
            .select('-passwordHash')
            .populate('assignedTeachers', 'name email');
        
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.json(user);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Update a user
// @route   PUT /api/admin/users/:id
exports.updateUser = async (req, res) => {
    const { name, rollNumber, email, classId, assignedTeachers, allTeachers } = req.body;
    try {
        const user = await User.findById(req.params.id);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        user.name = name || user.name;
        user.email = email || user.email;
        if (user.role === 'student') {
            user.rollNumber = rollNumber || user.rollNumber;
            user.classId = classId || user.classId;
            user.allTeachers = allTeachers;
            user.assignedTeachers = assignedTeachers || [];
        }

        const updatedUser = await user.save();
        res.json(updatedUser);
    } catch (error) {
        res.status(500).json({ message: 'Server Error: ' + error.message });
    }
};

// @desc    Delete a user
// @route   DELETE /api/admin/users/:id
exports.deleteUser = async (req, res) => {
    try {
        const user = await User.findById(req.params.id);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        await user.deleteOne(); // Mongoose v6+
        res.json({ message: 'User removed successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Get full attendance history for a specific student
// @route   GET /api/admin/reports/student/:studentId
exports.getStudentAttendanceReport = async (req, res) => {
    try {
        const { studentId } = req.params;
        const records = await Attendance.find({ studentId })
            .populate('teacherId', 'name')
            .sort({ timestamp: -1 });

        res.json(records);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Admin grants an OTP on behalf of a teacher
// @route   POST /api/admin/otp/grant
exports.grantOtp = async (req, res) => {
    const { teacherId, period } = req.body;
    if (!teacherId || !period) {
        return res.status(400).json({ message: 'Teacher ID and period are required.' });
    }

    try {
        const teacher = await User.findById(teacherId);
        if (!teacher || teacher.role !== 'teacher') {
            return res.status(404).json({ message: 'Teacher not found.' });
        }

        const otpCode = Math.floor(100000 + Math.random() * 900000).toString();

        await Otp.create({
            otpCode,
            teacherId,
            period
        });

        res.status(201).json({ 
            otp: otpCode, 
            message: `OTP generated for ${teacher.name} for period ${period}`
        });

    } catch (error) {
        res.status(500).json({ message: 'Server Error: ' + error.message });
    }
};