require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const db = require('./db');
const { bucket } = require('./gcs');
const multer = require('multer');


const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 100 * 1024 * 1024 }, // 100 MB file size limit
});



const app = express();
const PORT = process.env.PORT || 8080;

app.use(bodyParser.json());

// Create new post
// Create a new post with an optional image upload
app.post('/posts', upload.single('media'), async (req, res) => {
    try {
        const { title, postbody, user_id } = req.body;  // Replace 'body' with 'postbody'
        let mediaUrl = null;

        // Check for required fields
        if (!title || !postbody || !user_id) {  // Replace 'body' with 'postbody'
            return res.status(400).json({ error: 'Title, postbody, and user_id are required' });
        }

        // Check if a file was uploaded
        if (req.file) {
            const fileName = `${Date.now()}-${req.file.originalname}`;

            const file = bucket.file(fileName);

            console.log('Starting upload to Google Cloud Storage...');
            await new Promise((resolve, reject) => {
                const stream = file.createWriteStream({
                    metadata: {
                        contentType: req.file.mimetype,
                    },
                });

                stream.on('error', (err) => {
                    console.error('Error uploading media:', err);
                    reject(err);
                });

                stream.on('finish', () => {
                    console.log('File upload completed.');
                    resolve();
                });

                stream.end(req.file.buffer);
            });

            // Make the file public and generate the URL
            await file.makePublic();
            mediaUrl = `https://storage.googleapis.com/${bucket.name}/${file.name}`;
            console.log('Media URL:', mediaUrl);
        }

        // Insert the post into the database
        console.log('Inserting post into the database...');
        console.log('Inserting post with mediaUrl:', mediaUrl);

        const result = await db.query(
            'INSERT INTO post (title, postbody, media, user_id) VALUES ($1, $2, $3, $4) RETURNING *',
            [title, postbody, mediaUrl, user_id]  // Replace 'body' with 'postbody'
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error in /posts endpoint:', err);
        res.status(500).json({ error: 'Failed to save post' });
    }
});

// Load a user by user ID
app.get('/users/:userId', async (req, res) => {
    try {
        const { userId } = req.params;
        const result = await db.query('SELECT * FROM users WHERE user_id = $1', [userId]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Load a user by username
app.get('/users/username/:username', async (req, res) => {
    try {
        const { username } = req.params;
        const result = await db.query('SELECT * FROM users WHERE username = $1', [username]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        res.json(result.rows[0]); // Return the user details
    } catch (err) {
        console.error('Error fetching user by username:', err);
        res.status(500).json({ error: 'Server error' });
    }
});


// Create a new user
//Works exact same was as uploading a post does.
app.post('/users', upload.single('profile_picture'), async (req, res) => {
    try {
        const { username, password, bio } = req.body;
        let profilePictureUrl = null;

        // Check if a file was uploaded
        if (req.file) {
            const fileName = `${Date.now()}-${req.file.originalname}`;
            const file = bucket.file(fileName);

            console.log('Starting upload to Google Cloud Storage...');
            await new Promise((resolve, reject) => {
                const stream = file.createWriteStream({
                    metadata: {
                        contentType: req.file.mimetype,
                    },
                });

                stream.on('error', (err) => {
                    console.error('Error uploading profile picture:', err);
                    reject(err);
                });

                stream.on('finish', () => {
                    console.log('File upload completed.');
                    resolve();
                });

                stream.end(req.file.buffer);
            });

            // Make the file public and generate the URL
            await file.makePublic();
            profilePictureUrl = `https://storage.googleapis.com/${bucket.name}/${file.name}`;
            console.log('Profile picture URL:', profilePictureUrl);
        }

        // Insert user into the database
        console.log('Inserting user into the database...');
        const result = await db.query(
            'INSERT INTO users (username, password, bio, profile_picture) VALUES ($1, $2, $3, $4) RETURNING *',
            [username, password, bio, profilePictureUrl]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error in /users endpoint:', err);
        res.status(500).json({ error: 'Failed to save user' });
    }
});


// Get all posts
app.get('/posts', async (req, res) => {
    try {
        const result = await db.query('SELECT * FROM post WHERE is_deleted = FALSE');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Load a post by post ID
app.get('/posts/:postId', async (req, res) => {
    try {
        const { postId } = req.params;
        const result = await db.query('SELECT * FROM post WHERE post_id = $1 AND is_deleted = FALSE', [postId]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Post not found' });
        }
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Load all posts from a given user ID
app.get('/users/:userId/posts', async (req, res) => {
    try {
        const { userId } = req.params;
        const result = await db.query('SELECT * FROM post WHERE user_id = $1 AND is_deleted = FALSE', [userId]);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get the number of likes for a post given the post ID
app.get('/posts/:postId/likes', async (req, res) => {
    try {
        const { postId } = req.params;
        const result = await db.query('SELECT COUNT(*) FROM likes WHERE post_id = $1', [postId]);
        res.json({ likes: result.rows[0].count });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Create a like given post ID and user ID
app.post('/likes', async (req, res) => {
    try {
        const { post_id, user_id } = req.body;
        const result = await db.query(
            'INSERT INTO likes (post_id, user_id) VALUES ($1, $2) RETURNING *',
            [post_id, user_id]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Delete a like given user ID
app.delete('/likes', async (req, res) => {
    try {
        const { user_id } = req.body;
        const result = await db.query('DELETE FROM likes WHERE user_id = $1 RETURNING *', [user_id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Like not found' });
        }
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Create a comment given user ID and post ID
app.post('/comments', async (req, res) => {
    try {
        const { user_id, post_id, body } = req.body;
        const result = await db.query(
            'INSERT INTO comments (user_id, post_id, body) VALUES ($1, $2, $3) RETURNING *',
            [user_id, post_id, body]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Load all comments from a given post ID
app.get('/posts/:postId/comments', async (req, res) => {
    try {
        const { postId } = req.params;
        const result = await db.query('SELECT * FROM comments WHERE post_id = $1', [postId]);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});