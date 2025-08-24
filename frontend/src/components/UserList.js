import React, { useState, useEffect } from 'react';
import { fetchUsers, deleteUser } from '../services/api';
import Loading from './Loading';
import ErrorMessage from './ErrorMessage';

const UserList = ({ onEditUser, onCreateUser, refreshTrigger }) => {
  const [users, setUsers] = useState([]);
  const [pagination, setPagination] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [statusFilter, setStatusFilter] = useState('');

  const loadUsers = async (page = 1, status = '') => {
    try {
      setLoading(true);
      setError(null);
      const params = { page, limit: 10 };
      if (status) params.status = status;
      
      const response = await fetchUsers(params);
      setUsers(response.data.users);
      setPagination(response.data.pagination);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadUsers(currentPage, statusFilter);
  }, [currentPage, statusFilter, refreshTrigger]);

  const handleDeleteUser = async (userId, userName) => {
    if (!window.confirm(`Are you sure you want to delete user "${userName}"?`)) {
      return;
    }

    try {
      await deleteUser(userId);
      loadUsers(currentPage, statusFilter);
    } catch (err) {
      setError(err.message);
    }
  };

  const handlePageChange = (newPage) => {
    setCurrentPage(newPage);
  };

  const handleStatusFilter = (status) => {
    setStatusFilter(status);
    setCurrentPage(1);
  };

  if (loading) return <Loading message="Loading users..." />;
  if (error) return <ErrorMessage error={error} onRetry={() => loadUsers(currentPage, statusFilter)} />;

  return (
    <div className="user-list-container">
      <div className="user-list-header">
        <h2>User Management</h2>
        <button onClick={onCreateUser} className="create-user-button">
          + Add New User
        </button>
      </div>

      <div className="filters">
        <button 
          onClick={() => handleStatusFilter('')}
          className={`filter-button ${statusFilter === '' ? 'active' : ''}`}
        >
          All Users
        </button>
        <button 
          onClick={() => handleStatusFilter('active')}
          className={`filter-button ${statusFilter === 'active' ? 'active' : ''}`}
        >
          Active
        </button>
        <button 
          onClick={() => handleStatusFilter('inactive')}
          className={`filter-button ${statusFilter === 'inactive' ? 'active' : ''}`}
        >
          Inactive
        </button>
      </div>

      {users.length === 0 ? (
        <div className="no-users">
          <p>No users found.</p>
          <button onClick={onCreateUser} className="create-user-button">
            Create First User
          </button>
        </div>
      ) : (
        <>
          <div className="users-grid">
            {users.map(user => (
              <div key={user._id} className="user-card">
                <div className="user-info">
                  <h3>{user.name}</h3>
                  <p className="user-email">{user.email}</p>
                  {user.age && <p className="user-age">Age: {user.age}</p>}
                  <span className={`status-badge ${user.status}`}>
                    {user.status}
                  </span>
                </div>
                <div className="user-actions">
                  <button 
                    onClick={() => onEditUser(user)}
                    className="edit-button"
                  >
                    Edit
                  </button>
                  <button 
                    onClick={() => handleDeleteUser(user._id, user.name)}
                    className="delete-button"
                  >
                    Delete
                  </button>
                </div>
                <div className="user-dates">
                  <small>Created: {new Date(user.createdAt).toLocaleDateString()}</small>
                </div>
              </div>
            ))}
          </div>

          {pagination && pagination.totalPages > 1 && (
            <div className="pagination">
              <button 
                onClick={() => handlePageChange(currentPage - 1)}
                disabled={!pagination.hasPrevPage}
                className="pagination-button"
              >
                Previous
              </button>
              
              <span className="pagination-info">
                Page {pagination.currentPage} of {pagination.totalPages} 
                ({pagination.totalUsers} total users)
              </span>
              
              <button 
                onClick={() => handlePageChange(currentPage + 1)}
                disabled={!pagination.hasNextPage}
                className="pagination-button"
              >
                Next
              </button>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default UserList;
