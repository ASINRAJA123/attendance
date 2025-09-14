const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require('cors');

// --- Route Imports ---
const authRoutes = require('./routes/auth.routes');
const adminRoutes = require('./routes/admin.routes');
const teacherRoutes = require('./routes/teacher.routes'); // <-- ADDED
const studentRoutes = require('./routes/student.routes'); // <-- ADDED

// Load environment variables
dotenv.config();

const app = express();

// --- Core Middleware ---
app.use(cors()); // Allows cross-origin requests
app.use(express.json()); // Parses incoming JSON requests

// --- Mount API Routes ---
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/teacher', teacherRoutes); // <-- ADDED
app.use('/api/student', studentRoutes); // <-- ADDED

// --- Database Connection ---
mongoose.connect(process.env.MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
.then(() => console.log('MongoDB connected successfully'))
.catch(err => console.error('MongoDB connection error:', err));


// Simple test route for checking if the server is alive
app.get('/', (req, res) => {
    res.send('Attendance System API is running!');
});

// --- Server Startup ---
const PORT = process.env.PORT || 5001;
app.listen(PORT, () => console.log(`Server is running on port ${PORT}`));