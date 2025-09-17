import axios from 'axios';

const api = axios.create({
    baseURL: 'http://10.150.252.73:5001/api', // Your backend API URL
});

// Request interceptor to add the auth token to headers
api.interceptors.request.use((config) => {
    const userInfo = JSON.parse(localStorage.getItem('userInfo'));
    if (userInfo && userInfo.token) {
        config.headers.Authorization = `Bearer ${userInfo.token}`;
    }
    return config;
}, (error) => {
    return Promise.reject(error);
});

export default api;