import React, { useState, useEffect } from 'react';
import { createUser, updateUser } from '../services/api';

const UserForm = ({ user, onSuccess, onCancel }) => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    age: '',
    status: 'active'
  });
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState({});
  const [submitError, setSubmitError] = useState('');

  const isEditMode = Boolean(user);

  useEffect(() => {
    if (user) {
      setFormData({
        name: user.name || '',
        email: user.email || '',
        age: user.age || '',
        status: user.status || 'active'
      });
    }
  }, [user]);

  const validateForm = () => {
    const newErrors = {};

    if (!formData.name.trim()) {
      newErrors.name = 'Name is required';
    } else if (formData.name.trim().length < 2) {
      newErrors.name = 'Name must be at least 2 characters';
    } else if (formData.name.trim().length > 50) {
      newErrors.name = 'Name cannot be longer than 50 characters';
    }

    if (!formData.email.trim()) {
      newErrors.email = 'Email is required';
    } else if (!/^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$/.test(formData.email)) {
      newErrors.email = 'Please enter a valid email address';
    }

    if (formData.age && (isNaN(formData.age) || formData.age < 0 || formData.age > 150)) {
      newErrors.age = 'Age must be a number between 0 and 150';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    
    // Clear specific error when user starts typing
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }

    setLoading(true);
    setSubmitError('');

    try {
      const userData = {
        ...formData,
        age: formData.age ? parseInt(formData.age) : undefined
      };

      if (isEditMode) {
        await updateUser(user._id, userData);
      } else {
        await createUser(userData);
      }

      onSuccess();
    } catch (err) {
      setSubmitError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className=\"user-form-overlay\">
      <div className=\"user-form-container\">
        <div className=\"user-form-header\">
          <h2>{isEditMode ? 'Edit User' : 'Create New User'}</h2>
          <button onClick={onCancel} className=\"close-button\">×</button>
        </div>

        <form onSubmit={handleSubmit} className=\"user-form\">
          <div className=\"form-group\">
            <label htmlFor=\"name\">Name *</label>
            <input
              type=\"text\"
              id=\"name\"
              name=\"name\"
              value={formData.name}
              onChange={handleInputChange}
              className={errors.name ? 'error' : ''}
              placeholder=\"Enter full name\"
              disabled={loading}
            />
            {errors.name && <span className=\"error-text\">{errors.name}</span>}
          </div>

          <div className=\"form-group\">
            <label htmlFor=\"email\">Email *</label>
            <input
              type=\"email\"
              id=\"email\"
              name=\"email\"
              value={formData.email}
              onChange={handleInputChange}
              className={errors.email ? 'error' : ''}
              placeholder=\"Enter email address\"
              disabled={loading}
            />
            {errors.email && <span className=\"error-text\">{errors.email}</span>}
          </div>

          <div className=\"form-group\">
            <label htmlFor=\"age\">Age</label>
            <input
              type=\"number\"
              id=\"age\"
              name=\"age\"
              value={formData.age}
              onChange={handleInputChange}
              className={errors.age ? 'error' : ''}
              placeholder=\"Enter age (optional)\"
              min=\"0\"
              max=\"150\"
              disabled={loading}
            />
            {errors.age && <span className=\"error-text\">{errors.age}</span>}
          </div>

          <div className=\"form-group\">
            <label htmlFor=\"status\">Status</label>
            <select
              id=\"status\"
              name=\"status\"
              value={formData.status}
              onChange={handleInputChange}
              disabled={loading}
            >
              <option value=\"active\">Active</option>
              <option value=\"inactive\">Inactive</option>
            </select>
          </div>

          {submitError && (
            <div className=\"submit-error\">
              {submitError}
            </div>
          )}

          <div className=\"form-actions\">
            <button 
              type=\"button\" 
              onClick={onCancel}
              className=\"cancel-button\"
              disabled={loading}
            >
              Cancel
            </button>
            <button 
              type=\"submit\"
              className=\"submit-button\"
              disabled={loading}
            >
              {loading ? (isEditMode ? 'Updating...' : 'Creating...') : (isEditMode ? 'Update User' : 'Create User')}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default UserForm;
