# Microservice Application

A comprehensive full-stack microservice application with database integration, containerization, CI/CD pipelines, and cloud deployment capabilities.

## 🏗️ Architecture

```
microservice/
├── backend/                 # Node.js/Express API service
│   ├── config/             # Database and app configuration
│   ├── controllers/        # API route handlers
│   ├── middleware/         # Custom middleware
│   ├── models/             # Database models
│   ├── routes/             # API route definitions
│   ├── server.js           # Main server file
│   ├── Dockerfile          # Container configuration
│   └── package.json        # Dependencies and scripts
├── frontend/               # React web application
│   ├── src/
│   │   ├── components/     # Reusable React components
│   │   ├── services/       # API integration layer
│   │   └── App.js          # Main application component
│   ├── public/             # Static assets
│   ├── Dockerfile          # Container configuration
│   └── package.json        # Dependencies and scripts
├── database/               # Database configuration
│   └── init/               # Database initialization scripts
├── deploy/                 # Cloud deployment configurations
│   └── azure/              # Azure-specific deployment files
├── monitoring/             # Monitoring and logging setup
├── scripts/                # Development and deployment scripts
├── .github/workflows/      # CI/CD pipeline configuration
├── docker-compose.yml      # Multi-service orchestration
└── docker-compose.monitoring.yml # Monitoring stack
```

## ✨ Features

### 🗄️ Database Integration
- **MongoDB** with Mongoose ODM
- Database models with validation
- CRUD operations with pagination
- Data seeding and initialization scripts
- Connection pooling and error handling

### 🐳 Containerization
- **Docker** containers for all services
- **Docker Compose** for orchestration
- Multi-stage builds for optimized images
- Health checks and auto-restart policies
- Production-ready container configuration

### 🚀 CI/CD Pipeline
- **GitHub Actions** workflow
- Automated testing (unit, integration)
- Security scanning with Trivy
- Docker image building and publishing
- Multi-environment deployment (staging, production)

### ☁️ Cloud Deployment
- **Azure Container Instances** support
- **Azure Kubernetes Service (AKS)** configuration
- **Azure Cosmos DB** integration
- Infrastructure as Code (IaC)
- Auto-scaling and load balancing

### 📊 Monitoring & Logging
- **Prometheus** metrics collection
- **Grafana** dashboards and visualization
- **Loki** log aggregation
- **AlertManager** for notifications
- Health checks and performance monitoring

### 🔒 Security
- **Helmet.js** for security headers
- **Rate limiting** to prevent abuse
- **CORS** configuration
- **Input validation** with Joi
- **Environment-based secrets** management

### 🎨 Modern Frontend
- **React 18** with hooks
- **Responsive design** for all devices
- **Error boundaries** and loading states
- **Component-based architecture**
- **Real-time data updates**

### 🛠️ Developer Experience
- **Hot reload** for development
- **ESLint** and **Prettier** configuration
- **Comprehensive documentation**
- **Development scripts** for automation
- **Testing setup** with Jest

## Services

### Backend Service (Port 3000)
- **Technology**: Node.js with Express.js
- **Database**: MongoDB with Mongoose
- **Port**: 3000
- **Features**:
  - RESTful API design
  - User management with CRUD operations
  - Input validation and sanitization
  - Rate limiting and security headers
  - Health checks and metrics

### Frontend Service (Port 3001)
- **Technology**: React.js with modern hooks
- **Port**: 3001
- **Features**:
  - User management interface
  - Real-time data updates
  - Responsive design for all devices
  - Error handling and loading states
  - Form validation and user feedback

### Database Service (Port 27017)
- **Technology**: MongoDB
- **Port**: 27017
- **Features**:
  - Document-based storage
  - Automatic indexing
  - Data validation schemas
  - Connection pooling
  - Sample data initialization

## Quick Start

### Option 1: Run Both Services Together

Use the provided script to start both services simultaneously:

```bash
./start-services.sh
```

This will:
- Start the backend service on http://localhost:3000
- Start the frontend service on http://localhost:3001
- Install dependencies if needed
- Handle graceful shutdown with Ctrl+C

### Option 2: Run Services Separately

#### Start Backend
```bash
cd backend
npm install
npm start
```

#### Start Frontend
```bash
cd frontend
npm install
npm start
```

## 📚 API Documentation

### Backend Endpoints

#### Health & System
| Method | Endpoint | Description | Response |
|--------|----------|-------------|----------|
| GET    | `/`      | Basic health check | `{"success": true, "message": "Microservice API is running!", "timestamp": "...", "database": "connected", "version": "1.0.0"}` |
| GET    | `/health`| Detailed health check | `{"status": "OK", "timestamp": "...", "uptime": 123, "database": "connected", "memory": {...}, "environment": "development"}` |

#### User Management
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET    | `/api/users` | Get all users (with pagination) | Query: `?page=1&limit=10&status=active` | `{"success": true, "data": {"users": [...], "pagination": {...}}}` |
| GET    | `/api/users/:id` | Get user by ID | - | `{"success": true, "data": {"user": {...}}}` |
| POST   | `/api/users` | Create new user | `{"name": "John Doe", "email": "john@example.com", "age": 30, "status": "active"}` | `{"success": true, "data": {"user": {...}}}` |
| PUT    | `/api/users/:id` | Update user | `{"name": "Updated Name", "email": "updated@example.com"}` | `{"success": true, "data": {"user": {...}}}` |
| DELETE | `/api/users/:id` | Delete user | - | `{"success": true, "data": {"user": {"id": "...", "email": "..."}}}` |
| GET    | `/api/users/stats` | Get user statistics | - | `{"success": true, "data": {"stats": {"totalUsers": 100, "activeUsers": 80, "inactiveUsers": 20, "averageAge": 28.5}}}` |

### Error Responses

All endpoints return consistent error responses:
```json
{
  "success": false,
  "message": "Error description",
  "errors": [
    {
      "field": "email",
      "message": "Please enter a valid email address"
    }
  ]
}
```

### Frontend Features

- **Dashboard**: Overview of system health and user statistics
- **User Management**: Create, read, update, and delete users
- **Real-time Updates**: Automatic data refresh and state management
- **Form Validation**: Client-side and server-side validation
- **Error Handling**: User-friendly error messages and retry functionality
- **Responsive Design**: Mobile-first design that works on all devices
- **Loading States**: Visual feedback during API operations

## Development

### Backend Development
```bash
cd backend
npm run dev  # Start with auto-reload
```

### Frontend Development
```bash
cd frontend
npm start    # Start development server with hot-reload
```

### Building for Production

#### Backend
```bash
cd backend
npm start  # Production ready
```

#### Frontend
```bash
cd frontend
npm run build  # Creates optimized production build
```

## Configuration

### Backend Configuration
- **Port**: Configurable via `PORT` environment variable (default: 3000)
- **Environment**: Set via `NODE_ENV` (development/production)

### Frontend Configuration
- **API URL**: Configure via `REACT_APP_API_URL` in `.env` file
- **Port**: Configure via `PORT` in `.env` file (default: 3001)

## Environment Variables

### Backend
```env
PORT=3000
NODE_ENV=production
```

### Frontend
```env
REACT_APP_API_URL=http://localhost:3000
PORT=3001
BROWSER=none
```

## Troubleshooting

### Common Issues

1. **Port Already in Use**
   - Change ports in the respective `.env` files
   - Kill existing processes: `lsof -ti:3000 | xargs kill`

2. **API Connection Failed**
   - Ensure backend is running on the correct port
   - Check `REACT_APP_API_URL` in frontend `.env` file
   - Verify CORS settings if needed

3. **Dependencies Issues**
   - Delete `node_modules` and `package-lock.json`
   - Run `npm install` again

### Health Checks

- Backend: http://localhost:3000 (should return JSON response)
- Frontend: http://localhost:3001 (should show React app)

## 🔧 Development Workflows

### Local Development
```bash
# Setup and start all services
./scripts/dev.sh setup
./scripts/dev.sh start

# View logs
./scripts/dev.sh logs
./scripts/dev.sh logs backend  # specific service

# Run tests
./scripts/dev.sh test

# Stop services
./scripts/dev.sh stop

# Clean up
./scripts/dev.sh cleanup
```

### Docker Development
```bash
# Start with Docker Compose
docker-compose up --build

# Start with monitoring
docker-compose -f docker-compose.yml -f docker-compose.monitoring.yml up -d

# View logs
docker-compose logs -f backend

# Scale services
docker-compose up --scale backend=3
```

## 🚀 Deployment

### 🐳 Docker Deployment

1. **Build Images**:
```bash
docker build -t microservice-backend ./backend
docker build -t microservice-frontend ./frontend
```

2. **Run Containers**:
```bash
docker run -d -p 3000:3000 --name backend microservice-backend
docker run -d -p 3001:8080 --name frontend microservice-frontend
```

### ☁️ Azure Deployment

#### Azure Container Instances
```bash
# Deploy to Azure Container Instances
cd deploy/azure
./deploy.sh deploy

# Check deployment status
./deploy.sh status

# Clean up resources
./deploy.sh cleanup
```

#### Azure Kubernetes Service (AKS)
```bash
# Create AKS cluster
az aks create --resource-group microservice-rg --name microservice-aks

# Get credentials
az aks get-credentials --resource-group microservice-rg --name microservice-aks

# Deploy to Kubernetes
kubectl apply -f deploy/azure/k8s-deployment.yml

# Check deployment
kubectl get pods
kubectl get services
```

### 🌐 Production Checklist

- [ ] Environment variables configured
- [ ] Database connection string updated
- [ ] CORS origins configured
- [ ] SSL certificates installed
- [ ] Monitoring and logging enabled
- [ ] Health checks configured
- [ ] Auto-scaling policies set
- [ ] Backup strategy implemented
- [ ] Security scan passed

## 🚀 CI/CD Pipeline

### GitHub Actions Workflow

The CI/CD pipeline automatically:

1. **On Pull Request**:
   - Runs unit tests (backend & frontend)
   - Performs security scanning
   - Builds Docker images
   - Runs integration tests

2. **On Main Branch Push**:
   - All PR checks pass
   - Publishes Docker images to GitHub Container Registry
   - Deploys to staging environment
   - Runs smoke tests
   - **Manual approval required for production deployment**

3. **Production Deployment**:
   - Deploys to production environment
   - Runs final smoke tests
   - Sends deployment notifications

### Pipeline Configuration

```yaml
# .github/workflows/ci-cd.yml
- Backend & Frontend testing
- Security scanning with Trivy
- Docker image building (multi-arch)
- Integration testing
- Staging deployment
- Production deployment (with approval)
```

### Environment Setup

1. **GitHub Secrets**:
   - `GITHUB_TOKEN` (automatically provided)
   - `MONGODB_URI` (production database)
   - `JWT_SECRET` (production JWT secret)
   - `AZURE_CREDENTIALS` (for Azure deployment)

2. **Environment Protection Rules**:
   - Staging: Auto-deploy on main branch
   - Production: Requires manual approval

## 📊 Monitoring

### Local Monitoring Stack

```bash
# Start monitoring services
docker-compose -f docker-compose.monitoring.yml up -d
```

**Access URLs**:
- **Grafana**: http://localhost:3030 (admin/admin)
- **Prometheus**: http://localhost:9090
- **AlertManager**: http://localhost:9093

### Metrics & Dashboards

- **Application metrics**: Request rate, response time, error rate
- **System metrics**: CPU, memory, disk usage
- **Database metrics**: Connection pool, query performance
- **Business metrics**: User registrations, API usage

### Alerting

- **High error rate** (> 5%)
- **Slow response time** (> 500ms)
- **Database connection issues**
- **High memory usage** (> 80%)
- **Service unavailability**

## Testing

### Backend Testing
```bash
cd backend
npm test                    # Run unit tests
npm run test:watch         # Run tests in watch mode
curl http://localhost:3000/health  # Manual health check
```

### Frontend Testing
```bash
cd frontend
npm test                    # Run unit tests
npm test -- --coverage      # Run with coverage
npm run test:e2e           # Run end-to-end tests (if configured)
```

### Integration Testing
```bash
# Using the development script
./scripts/dev.sh test

# Manual API testing
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","age":25}'
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test both services
5. Submit a pull request

## License

ISC License
