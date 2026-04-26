const express = require('express');
const router = express.Router();
const SupportRequest = require('../models/SupportRequest');

// Submit Contact Form
router.post('/contact', async (req, res) => {
  try {
    const { name, email, subject, message } = req.body;
    const support = new SupportRequest({ name, email, subject, message });
    await support.save();
    res.status(201).json({ message: 'Message sent successfully. We will get back to you soon.' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Admin: Get all support requests
router.get('/all', async (req, res) => {
  try {
    const requests = await SupportRequest.find().sort({ createdAt: -1 });
    res.json(requests);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
