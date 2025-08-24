const Joi = require('joi');

// User validation schemas
const createUserSchema = Joi.object({
  name: Joi.string()
    .min(2)
    .max(50)
    .trim()
    .required()
    .messages({
      'string.empty': 'Name is required',
      'string.min': 'Name must be at least 2 characters long',
      'string.max': 'Name cannot be longer than 50 characters'
    }),
  
  email: Joi.string()
    .email()
    .lowercase()
    .trim()
    .required()
    .messages({
      'string.empty': 'Email is required',
      'string.email': 'Please enter a valid email address'
    }),
  
  age: Joi.number()
    .integer()
    .min(0)
    .max(150)
    .optional()
    .messages({
      'number.min': 'Age cannot be negative',
      'number.max': 'Age cannot be more than 150',
      'number.integer': 'Age must be a whole number'
    }),
  
  status: Joi.string()
    .valid('active', 'inactive')
    .default('active')
    .optional()
});

const updateUserSchema = Joi.object({
  name: Joi.string()
    .min(2)
    .max(50)
    .trim()
    .optional(),
  
  email: Joi.string()
    .email()
    .lowercase()
    .trim()
    .optional(),
  
  age: Joi.number()
    .integer()
    .min(0)
    .max(150)
    .optional(),
  
  status: Joi.string()
    .valid('active', 'inactive')
    .optional()
}).min(1); // At least one field must be provided

// Generic validation middleware
const validate = (schema) => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true,
      convert: true
    });

    if (error) {
      const errorMessages = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));

      return res.status(400).json({
        success: false,
        message: 'Validation error',
        errors: errorMessages
      });
    }

    req.validatedData = value;
    next();
  };
};

// Parameter validation for MongoDB ObjectId
const validateObjectId = (paramName = 'id') => {
  return (req, res, next) => {
    const id = req.params[paramName];
    
    if (!id || !id.match(/^[0-9a-fA-F]{24}$/)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid ID format'
      });
    }
    
    next();
  };
};

// Query parameter validation for pagination
const validatePagination = (req, res, next) => {
  const { page = 1, limit = 10, sort = '-createdAt', status } = req.query;
  
  const schema = Joi.object({
    page: Joi.number().integer().min(1).default(1),
    limit: Joi.number().integer().min(1).max(100).default(10),
    sort: Joi.string().default('-createdAt'),
    status: Joi.string().valid('active', 'inactive').optional()
  });

  const { error, value } = schema.validate({ page, limit, sort, status });
  
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Invalid query parameters',
      errors: error.details.map(detail => detail.message)
    });
  }

  req.pagination = value;
  next();
};

module.exports = {
  createUserSchema,
  updateUserSchema,
  validate,
  validateObjectId,
  validatePagination
};
