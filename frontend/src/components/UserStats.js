import React, { useState, useEffect } from 'react';
import { fetchUserStats } from '../services/api';

const UserStats = ({ refreshTrigger }) => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const loadStats = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await fetchUserStats();
      setStats(response.data.stats);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadStats();
  }, [refreshTrigger]);

  if (loading) return <div className="stats-loading">Loading statistics...</div>;
  if (error) return <div className="stats-error">Error loading stats: {error}</div>;
  if (!stats) return null;

  return (
    <div className="user-stats-container">
      <h3>User Statistics</h3>
      <div className="stats-grid">
        <div className="stat-card total">
          <div className="stat-icon">👥</div>
          <div className="stat-content">
            <h4>Total Users</h4>
            <p className="stat-number">{stats.totalUsers}</p>
          </div>
        </div>
        
        <div className="stat-card active">
          <div className="stat-icon">✅</div>
          <div className="stat-content">
            <h4>Active Users</h4>
            <p className="stat-number">{stats.activeUsers}</p>
          </div>
        </div>
        
        <div className="stat-card inactive">
          <div className="stat-icon">⏸️</div>
          <div className="stat-content">
            <h4>Inactive Users</h4>
            <p className="stat-number">{stats.inactiveUsers}</p>
          </div>
        </div>
        
        <div className="stat-card average">
          <div className="stat-icon">📊</div>
          <div className="stat-content">
            <h4>Average Age</h4>
            <p className="stat-number">
              {stats.averageAge ? stats.averageAge.toFixed(1) : 'N/A'}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default UserStats;
