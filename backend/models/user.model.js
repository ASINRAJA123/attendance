const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
    name: { type: String, required: true },
    // ADDED rollNumber as the new primary identifier along with email
    rollNumber: { 
        type: String, 
        trim: true,
        sparse: true, // Allows null values without violating uniqueness
        unique: true 
    },
    email: { type: String, required: true, unique: true, lowercase: true },
    passwordHash: { type: String, required: true },
    role: { type: String, enum: ['admin', 'teacher', 'student'], required: true },
    classId: { type: String, trim: true },
    allTeachers: { type: Boolean, default: false },
    assignedTeachers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }]
}, { timestamps: true });

// Add a pre-save hook to require rollNumber for students
userSchema.pre('save', function(next) {
    if (this.role === 'student' && !this.rollNumber) {
        next(new Error('Roll number is required for students.'));
    } else {
        next();
    }
});

// Compare passwords
userSchema.methods.matchPassword = async function(enteredPassword) {
    return await bcrypt.compare(enteredPassword, this.passwordHash);
};

// Hash password before saving
userSchema.pre('save', async function(next) {
    if (!this.isModified('passwordHash')) {
        return next();
    }
    const salt = await bcrypt.genSalt(10);
    this.passwordHash = await bcrypt.hash(this.passwordHash, salt);
    next();
});

module.exports = mongoose.model('User', userSchema);