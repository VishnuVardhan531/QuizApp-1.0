const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const { createClient } = require('redis');
const path = require('path');

dotenv.config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: "*", methods: ["GET", "POST"] }
});

// Middleware
app.use(cors());
app.use(express.json());

// Mock fallbacks for Demo Mode
const redisMock = {
  connect: async () => console.log('Redis Cache: Running in Mock Mode'),
  sAdd: async () => {}, sCard: async () => 42, sMembers: async () => ['Vara', 'John', 'Alex'],
  zIncrBy: async () => {}, zRangeWithScores: async () => [{ value: 'Vara', score: 1200 }, { value: 'John', score: 850 }]
};

const redisClient = process.env.REDIS_URL ? createClient({ url: process.env.REDIS_URL }) : redisMock;
if (redisClient.on) redisClient.on('error', (err) => console.log('Redis Client Error', err));

// MongoDB Connection with Fallback
mongoose.connect(process.env.MONGODB_URI, { serverSelectionTimeoutMS: 2000 })
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => {
    console.log('MongoDB: Running in Mock Mode (No local DB found)');
  });

// Routes
const Quiz = require('./models/Quiz');
const User = require('./models/User'); // NEW: User model
const authRoutes = require('./routes/authRoutes'); // NEW: Auth routes
const quizRoutes = require('./routes/quizRoutes');
const supportRoutes = require('./routes/supportRoutes');

app.use('/api/auth', authRoutes); // NEW: Auth endpoints
app.use('/api/quizzes', quizRoutes);
app.use('/api/support', supportRoutes);

// Static uploads folder
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Active Rooms Memory Tracker for Participant Limits
const activeRooms = new Map();

io.on('connection', (socket) => {
  console.log('New client connected:', socket.id);

  // Host a new quiz lobby
  socket.on('host_quiz', ({ quizId, limit, hostName }) => {
    const pin = Math.floor(100000 + Math.random() * 900000).toString();
    
    activeRooms.set(pin, {
      quizId,
      limit,
      hostSocketId: socket.id,
      participants: []
    });

    socket.join(pin);
    socket.emit('room_created', { pin });
    console.log(`[Host] ${hostName || 'User'} created room ${pin} with limit ${limit}`);
  });

  // Close Lobby Early
  socket.on('close_room', ({ roomId }) => {
    if (activeRooms.has(roomId)) {
      io.to(roomId).emit('room_closed', { reason: 'Host aborted the session.' });
      activeRooms.delete(roomId);
      console.log(`Room ${roomId} forcefully closed by Host`);
      io.in(roomId).socketsLeave(roomId);
    }
  });

  // Joining a room
  socket.on('join_room', async ({ roomId, userName }) => {
    const roomInfo = activeRooms.get(roomId);
    
    // Prevent joining if limit is reached
    if (roomInfo) {
      if (roomInfo.participants.length >= roomInfo.limit) {
        socket.emit('join_rejected', { reason: 'Room is full! Participant limit reached.' });
        return;
      }
      roomInfo.participants.push(userName);
    }

    socket.join(roomId);
    
    // Add participant to Redis room list
    await redisClient.sAdd(`room:${roomId}:participants`, userName);
    const count = roomInfo ? roomInfo.participants.length : await redisClient.sCard(`room:${roomId}:participants`);

    // Broadcast update to host
    const allParticipants = roomInfo ? roomInfo.participants : await redisClient.sMembers(`room:${roomId}:participants`);
    io.to(roomId).emit('participant_update', { count, participants: allParticipants });
    console.log(`${userName} joined room ${roomId}`);
  });

  // Submit Answer (Blazing fast update via Redis)
  socket.on('submit_answer', async ({ roomId, userName, score, responseTime }) => {
    // Increment score in Redis (ZSET for leaderboard)
    await redisClient.zIncrBy(`room:${roomId}:leaderboard`, score, userName);
    
    // Notify host for real-time dashboard
    const leaderBoard = await redisClient.zRangeWithScores(`room:${roomId}:leaderboard`, 0, -1, { REV: true });
    io.to(roomId).emit('leaderboard_update', leaderBoard);
  });

  // Exam Mode: App State Detection
  socket.on('exam_mode_exit', ({ roomId, userName }) => {
    console.log(`Alert: ${userName} left the app during Exam Mode!`);
    io.to(roomId).emit('force_submit', { userName });
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected');
  });
});

// Basic Routes
app.get('/health', (req, res) => res.send('Quiz Server OK'));

const PORT = process.env.PORT || 5000;
server.listen(PORT, async () => {
  await redisClient.connect();
  console.log(`Server running on port ${PORT}`);
});
