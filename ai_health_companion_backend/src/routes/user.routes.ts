import { Router } from 'express';
import {
    createUser,
    getAllUsers,
    getUserById,
    updateUser,
    deleteUser,
    resetUserPassword,
    getCurrentUser,
    updateCurrentUser,
    changePassword
} from '../controllers/user.controller';
import { authenticate, authorize } from '../middleware/auth';
import { UserRole } from '../models/User';

const router = Router();

// All routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/v1/users/me
 * @desc    Get current user profile
 * @access  Private
 */
router.get('/me', getCurrentUser);

/**
 * @route   PUT /api/v1/users/me
 * @desc    Update current user profile
 * @access  Private
 */
router.put('/me', updateCurrentUser);

/**
 * @route   POST /api/v1/users/me/change-password
 * @desc    Change current user password
 * @access  Private
 */
router.post('/me/change-password', changePassword);

// Admin-only routes
/**
 * @route   POST /api/v1/users
 * @desc    Create new user (Admin only)
 * @access  Private (Admin)
 */
router.post('/', authorize(UserRole.ADMIN), createUser);

/**
 * @route   GET /api/v1/users
 * @desc    Get all users with filters (Admin only)
 * @access  Private (Admin)
 */
router.get('/', authorize(UserRole.ADMIN), getAllUsers);

/**
 * @route   GET /api/v1/users/:id
 * @desc    Get user by ID (Admin only)
 * @access  Private (Admin)
 */
router.get('/:id', authorize(UserRole.ADMIN), getUserById);

/**
 * @route   PUT /api/v1/users/:id
 * @desc    Update user (Admin only)
 * @access  Private (Admin)
 */
router.put('/:id', authorize(UserRole.ADMIN), updateUser);

/**
 * @route   DELETE /api/v1/users/:id
 * @desc    Delete user (Admin only)
 * @access  Private (Admin)
 */
router.delete('/:id', authorize(UserRole.ADMIN), deleteUser);

/**
 * @route   POST /api/v1/users/:id/reset-password
 * @desc    Reset user password (Admin only)
 * @access  Private (Admin)
 */
router.post('/:id/reset-password', authorize(UserRole.ADMIN), resetUserPassword);

export default router;
