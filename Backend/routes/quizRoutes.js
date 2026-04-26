const express = require('express');
const router = express.Router();
const Quiz = require('../models/Quiz');
const upload = require('../middleware/uploadMiddleware');

// Create a new quiz draft
router.post('/', async (req, res) => {
  try {
    const { title, description, hostId, visibility } = req.body;
    
    // Generate a simple room ID
    const roomId = Math.random().toString(36).substring(2, 8).toUpperCase();
    
    const newQuiz = new Quiz({
      title,
      description,
      hostId,
      visibility,
      roomId,
      questions: []
    });
    
    await newQuiz.save();
    res.status(201).json(newQuiz);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Add a question to a quiz with image upload
router.post('/:id/questions', upload.single('questionImage'), async (req, res) => {
  try {
    const { id } = req.params;
    const { questionText, options, correctAnswer, timeLimit, points } = req.body;
    
    const quiz = await Quiz.findById(id);
    if (!quiz) return res.status(404).json({ message: 'Quiz not found' });
    
    const imageUrl = req.file ? `/uploads/${req.file.filename}` : null;
    
    const newQuestion = {
      type: 'multiple_choice',
      questionText,
      options: typeof options === 'string' ? JSON.parse(options) : options,
      correctAnswer,
      questionImage: imageUrl,
      timeLimit: parseInt(timeLimit) || 30,
      points: parseInt(points) || 100
    };
    
    quiz.questions.push(newQuestion);
    await quiz.save();
    
    res.status(200).json(quiz);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
