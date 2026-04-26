const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  try {
    const token = req.headers.authorization.split(' ')[1];
    if (!token) {
      return res.status(401).json({ message: 'Auth failed: Token missing' });
    }

    const decodedToken = jwt.verify(token, process.env.JWT_SECRET || 'secret');
    req.userData = { userId: decodedToken.userId, email: decodedToken.email };
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Auth failed: Invalid token' });
  }
};
