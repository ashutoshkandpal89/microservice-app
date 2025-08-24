const express = require('express');
const router = express.Router();
const {
  getUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser,
  getUserStats
} = require('../controllers/userController');

const {
  validate,
  createUserSchema,
  updateUserSchema,
  validateObjectId,
  validatePagination
} = require('../middleware/validation');

// Routes
// GET /api/users/stats - Get user statistics
router.get('/stats', getUserStats);

// GET /api/users - Get all users with pagination and filtering
router.get('/', validatePagination, getUsers);

// GET /api/users/:id - Get user by ID
router.get('/:id', validateObjectId(), getUserById);

// POST /api/users - Create new user
router.post('/', validate(createUserSchema), createUser);

// PUT /api/users/:id - Update user
router.put('/:id', validateObjectId(), validate(updateUserSchema), updateUser);

// DELETE /api/users/:id - Delete user
router.delete('/:id', validateObjectId(), deleteUser);

module.exports = router;
