const axios = require('axios');
const dotenv = require('dotenv');

dotenv.config();

class GeminiService {
  constructor() {
    this.apiKey = process.env.GEMINI_API_KEY;
    this.apiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${this.apiKey}`;
  }

  async generateQuizFromSource(sourceType, sourceContent) {
    const prompt = `
      You are an expert quiz creator. Generate a comprehensive quiz in JSON format based on the following ${sourceType}:
      "${sourceContent}"

      Requirements:
      1. Include at least 5 questions.
      2. Use a variety of question types: true_false, puzzle, type_answer, slider, word_cloud.
      3. For each question, provide:
         - questionText
         - type
         - options (if applicable)
         - correctAnswer
         - timeLimit (seconds)
      4. Ensure the output is strictly valid JSON.

      JSON Structure:
      {
        "title": "Quiz Title",
        "description": "Short description",
        "questions": [
          {
            "type": "type_answer",
            "questionText": "What is...?",
            "correctAnswer": "Answer",
            "timeLimit": 30
          }
        ]
      }
    `;

    try {
      const response = await axios.post(this.apiUrl, {
        contents: [{ parts: [{ text: prompt }] }]
      });

      const rawText = response.data.candidates[0].content.parts[0].text;
      // Clean up markdown markers if present
      const jsonText = rawText.replace(/```json|```/g, '').trim();
      return JSON.parse(jsonText);
    } catch (error) {
      console.error('Gemini API Error:', error);
      throw new Error('Failed to generate quiz via AI');
    }
  }
}

module.exports = new GeminiService();
