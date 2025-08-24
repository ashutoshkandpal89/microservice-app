# Frontend Service

A React-based frontend service that communicates with the microservice backend.

## Features

- Modern React application with hooks
- API service layer for backend communication
- Error handling and loading states
- Responsive design
- Clean, modular component structure

## Getting Started

### Prerequisites

- Node.js (version 14 or higher)
- npm or yarn
- Backend service running on port 3000

### Installation

1. Install dependencies:
```bash
npm install
```

2. Start the development server:
```bash
npm start
```

The app will open at [http://localhost:3001](http://localhost:3001)

### Environment Configuration

The app uses environment variables for configuration. Create a `.env` file in the root directory:

```env
REACT_APP_API_URL=http://localhost:3000
PORT=3001
```

## Available Scripts

- `npm start` - Runs the app in development mode
- `npm build` - Builds the app for production
- `npm test` - Launches the test runner
- `npm run eject` - Ejects from Create React App

## Project Structure

```
src/
├── components/          # Reusable React components
│   ├── Loading.js      # Loading spinner component
│   ├── ErrorMessage.js # Error display component
│   └── BackendData.js  # Backend data display component
├── services/           # API and service layer
│   └── api.js         # Backend API communication
├── App.js             # Main application component
├── App.css           # Application styles
├── index.js          # React app entry point
└── index.css         # Global styles
```

## API Integration

The frontend communicates with the backend API using axios. The API service layer (`src/services/api.js`) handles:

- HTTP requests to the backend
- Error handling and retry logic
- Request/response interceptors
- Configuration management

## Styling

The application uses CSS with modern features:

- CSS Grid and Flexbox for layout
- CSS custom properties (variables)
- Responsive design for mobile devices
- Loading animations and transitions

## Development

To add new features:

1. Create new components in the `src/components/` directory
2. Add API endpoints to `src/services/api.js`
3. Update the main App component to integrate new features
4. Add corresponding styles to maintain visual consistency
