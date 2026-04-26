const mongoose = require('mongoose');

const QuestionSchema = new mongoose.Schema({
  type: {
    type: String,
    enum: [
      'true_false', 'puzzle', 'type_answer', 'slider', 
      'audio', 'pin_answer', 'word_cloud', 'poll', 
      'open_ended', 'brainstorm', 'survey', 'feedback', 
      'coding', 'document', 'multiple_choice'
    ],
    default: 'multiple_choice'
  },
  questionText: { type: String, required: true },
  options: [{ type: String }], // Used for multiple choice / A, B, C, D
  correctAnswer: mongoose.Schema.Types.Mixed,
  questionImage: { type: String }, // Stores server URL to the image
  timeLimit: { type: Number, default: 30 },
  points: { type: Number, default: 100 }
});

const QuizSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String },
  hostId: { type: String, required: true }, 
  roomId: { type: String, unique: true, required: true },
  questions: [QuestionSchema],
  visibility: { type: String, enum: ['public', 'private'], default: 'public' },
  participantLimit: { type: Number, default: 500 },
  isExamMode: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Quiz', QuizSchema);
