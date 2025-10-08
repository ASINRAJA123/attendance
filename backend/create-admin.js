const mongoose = require('mongoose');
const dotenv = require('dotenv');
const prompt = require('prompt-sync')();
const User = require('./models/user.model');

dotenv.config();

const createAdmin = async () => {
    console.log('--- Create Initial Admin User ---');

    try {
        // Connect to the database
        await mongoose.connect(process.env.MONGO_URI, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });
        console.log('MongoDB connected...');

        // Get admin details from user input
        const name = prompt('Enter admin full name: ');
        const email = prompt('Enter admin email: ');
        const password = prompt.hide('Enter admin password: ');
        const role = prompt('Enter role: ');
        const rollNo = prompt('Enter roll number: ');

        if (!name || !email || !password) {
            console.error('All fields are required.');
            process.exit(1);
        }

        // Check if admin already exists
        const existingAdmin = await User.findOne({ email });
        if (existingAdmin) {
            console.error('An admin with this email already exists.');
            process.exit(1);
        }

        // Create the new admin user
        const admin = new User({
            name,
            email,
            passwordHash: password, // The pre-save hook in your model will hash this automatically!
            role: role,
            rollNumber: rollNo,
        });

        await admin.save();
        console.log(`Admin user '${admin.name}' created successfully!`);

    } catch (error) {
        console.error('Error creating admin user:', error.message);
    } finally {
        // Disconnect from the database
        await mongoose.disconnect();
        console.log('MongoDB disconnected.');
        process.exit(0);
    }
};

createAdmin();