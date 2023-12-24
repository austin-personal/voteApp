const express = require('express');
const router = express.Router();

// Example in-memory store for votes
const votes = [];

// Route to handle vote submissions
router.post('/', (req, res) => {
    const { vote } = req.body;

    if (vote) {
        // Store the vote (you can replace this with database storage)
        votes.push(vote);

        // Respond with success message
        res.status(200).json({ message: 'Vote recorded successfully' });
    } else {
        // Respond with an error if vote is not provided
        res.status(400).json({ message: 'Vote value is required' });
    }
});

module.exports = router;
