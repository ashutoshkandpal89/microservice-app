import React from 'react';

const BackendData = ({ data }) => {
  return (
    <div className="backend-data-container">
      <div className="data-header">
        <h3>✅ Backend Connected Successfully</h3>
        <div className="connection-status">
          <span className="status-indicator online"></span>
          <span>Online</span>
        </div>
      </div>
      
      <div className="data-content">
        <h4>API Response:</h4>
        <pre className="json-display">
          {JSON.stringify(data, null, 2)}
        </pre>
      </div>
      
      <div className="data-meta">
        <small>Last updated: {new Date().toLocaleTimeString()}</small>
      </div>
    </div>
  );
};

export default BackendData;
