// MongoDB initialization script
// This script runs when the MongoDB container starts for the first time

print('Starting database initialization...');

// Switch to the microservice database
db = db.getSiblingDB('microservice_db');

// Create a user for the application
db.createUser({
  user: 'app_user',
  pwd: 'app_password',
  roles: [
    {
      role: 'readWrite',
      db: 'microservice_db'
    }
  ]
});

// Create collections with validation
db.createCollection('users', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['name', 'email'],
      properties: {
        name: {
          bsonType: 'string',
          minLength: 2,
          maxLength: 50,
          description: 'Name must be a string between 2-50 characters'
        },
        email: {
          bsonType: 'string',
          pattern: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$',
          description: 'Email must be a valid email address'
        },
        age: {
          bsonType: 'int',
          minimum: 0,
          maximum: 150,
          description: 'Age must be a number between 0-150'
        },
        status: {
          enum: ['active', 'inactive'],
          description: 'Status must be either active or inactive'
        }
      }
    }
  }
});

// Create indexes for better performance
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ status: 1 });
db.users.createIndex({ createdAt: -1 });
db.users.createIndex({ name: 'text', email: 'text' });

// Insert sample data
db.users.insertMany([
  {
    name: 'John Doe',
    email: 'john.doe@example.com',
    age: 30,
    status: 'active',
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    name: 'Jane Smith',
    email: 'jane.smith@example.com',
    age: 25,
    status: 'active',
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    name: 'Bob Johnson',
    email: 'bob.johnson@example.com',
    age: 35,
    status: 'inactive',
    createdAt: new Date(),
    updatedAt: new Date()
  }
]);

print('Database initialization completed!');
print('Sample users created: ' + db.users.countDocuments());

// Create audit log collection
db.createCollection('audit_logs');
db.audit_logs.createIndex({ timestamp: -1 });
db.audit_logs.createIndex({ userId: 1 });
db.audit_logs.createIndex({ action: 1 });

print('Collections created: ' + db.getCollectionNames());
print('Database initialization script completed successfully!');
