import React, { useState, useEffect } from 'react';
import './App.css';
import { fetchBackendData, fetchHealthCheck } from './services/api';
import Loading from './components/Loading';
import ErrorMessage from './components/ErrorMessage';
import BackendData from './components/BackendData';
import UserList from './components/UserList';
import UserForm from './components/UserForm';
import UserStats from './components/UserStats';

function App() {
  const [backendData, setBackendData] = useState(null);
  const [healthData, setHealthData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [currentView, setCurrentView] = useState('dashboard');
  const [showUserForm, setShowUserForm] = useState(false);
  const [editingUser, setEditingUser] = useState(null);
  const [refreshTrigger, setRefreshTrigger] = useState(0);

  const loadData = async () => {
    try {
      setLoading(true);
      setError(null);
      const [backendResponse, healthResponse] = await Promise.all([
        fetchBackendData(),
        fetchHealthCheck()
      ]);
      setBackendData(backendResponse);
      setHealthData(healthResponse);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleCreateUser = () => {
    setEditingUser(null);
    setShowUserForm(true);
  };

  const handleEditUser = (user) => {
    setEditingUser(user);
    setShowUserForm(true);
  };

  const handleUserFormSuccess = () => {
    setShowUserForm(false);
    setEditingUser(null);
    setRefreshTrigger(prev => prev + 1);
  };

  const handleUserFormCancel = () => {
    setShowUserForm(false);
    setEditingUser(null);
  };

  const renderContent = () => {
    if (loading) {
      return <Loading message="Connecting to backend service..." />;
    }

    if (error) {
      return <ErrorMessage error={error} onRetry={loadData} />;
    }

    switch (currentView) {
      case 'users':
        return (
          <UserList 
            onEditUser={handleEditUser}
            onCreateUser={handleCreateUser}
            refreshTrigger={refreshTrigger}
          />
        );
      case 'dashboard':
      default:
        return (
          <div className="dashboard">
            {backendData && <BackendData data={backendData} />}
            {healthData && (
              <div className="health-info">
                <h3>System Health</h3>
                <div className="health-details">
                  <p><strong>Status:</strong> {healthData.status}</p>
                  <p><strong>Database:</strong> {healthData.database}</p>
                  <p><strong>Uptime:</strong> {Math.floor(healthData.uptime)} seconds</p>
                  <p><strong>Environment:</strong> {healthData.environment}</p>
                </div>
              </div>
            )}
            <UserStats refreshTrigger={refreshTrigger} />
          </div>
        );
    }
  };

  return (
    <div className="App">
      <nav className="app-nav">
        <div className="nav-brand">
          <h1>Microservice App</h1>
        </div>
        <div className="nav-links">
          <button 
            onClick={() => setCurrentView('dashboard')}
            className={`nav-button ${currentView === 'dashboard' ? 'active' : ''}`}
          >
            📊 Dashboard
          </button>
          <button 
            onClick={() => setCurrentView('users')}
            className={`nav-button ${currentView === 'users' ? 'active' : ''}`}
          >
            👥 Users
          </button>
          <button 
            onClick={loadData}
            className="refresh-nav-button"
            disabled={loading}
          >
            {loading ? '🔄' : '↻'} Refresh
          </button>
        </div>
      </nav>

      <main className="app-main">
        {renderContent()}
      </main>

      {showUserForm && (
        <UserForm 
          user={editingUser}
          onSuccess={handleUserFormSuccess}
          onCancel={handleUserFormCancel}
        />
      )}
    </div>
  );
}

export default App;
