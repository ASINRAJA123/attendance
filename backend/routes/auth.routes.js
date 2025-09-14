const express = require('express');
const router = express.Router();
const { loginUser } = require('../controllers/auth.controller');

router.post('/login', (req, res, next) => {
    console.log('POST /api/auth/login called with body:', req.body);
    next();
}, loginUser);

module.exports = router;
