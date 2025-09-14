const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require('cors');

// --- Route Imports ---
const authRoutes = require('./routes/auth.routes');
const adminRoutes = require('./routes/admin.routes');
const teacherRoutes = require('./routes/teacher.routes'); 
const studentRoutes = require('./routes/student.routes'); 

// Load environment variables
dotenv.config();
console.log('Environment variables loaded:', process.env.MONGO_URI ? 'OK' : 'MONGO_URI not set');

const app = express();

// --- Core Middleware ---
app.use(cors());
app.use(express.json());
console.log('Middleware loaded: CORS + JSON parser');

// --- Mount API Routes ---
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/teacher', teacherRoutes);
app.use('/api/student', studentRoutes);
console.log('API routes mounted: auth, admin, teacher, student');

// --- Database Connection ---
mongoose.connect(process.env.MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
.then(() => console.log('MongoDB connected successfully'))
.catch(err => console.error('MongoDB connection error:', err));

// Simple test route
app.get('/', (req, res) => {
    console.log('Root route hit');
    res.send('Attendance System API is running!');
});

// --- Server Startup ---
const PORT = process.env.PORT || 5001;
app.listen(PORT, () => console.log(`Server is running on port ${PORT}`));
