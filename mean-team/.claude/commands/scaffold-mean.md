# /scaffold-mean

One-time project setup for a MEAN stack application. Initializes the project structure, installs dependencies, and creates base configuration files. Run this ONCE before the first `/el-capitan` invocation.

## Context

$ARGUMENTS

## Instructions

### Purpose

Set up a new MEAN stack project with the standard directory structure, dependencies, and configuration. This is a one-time setup command — NOT a pipeline phase.

### Process

#### 1. Create Project Structure

```
{project-root}/
├── server/
│   ├── config/
│   ├── models/
│   ├── controllers/
│   ├── routes/
│   ├── middleware/
│   ├── utils/
│   ├── __tests__/
│   │   ├── fixtures/
│   │   ├── integration/
│   │   ├── unit/
│   │   └── middleware/
│   ├── server.js
│   └── package.json
├── client/
│   ├── src/
│   │   ├── components/
│   │   │   ├── common/
│   │   │   ├── layout/
│   │   │   └── features/
│   │   ├── pages/
│   │   ├── hooks/
│   │   ├── context/
│   │   ├── services/
│   │   ├── utils/
│   │   ├── constants/
│   │   ├── assets/
│   │   ├── __tests__/
│   │   │   └── mocks/
│   │   ├── App.jsx
│   │   └── main.jsx
│   ├── index.html
│   ├── vite.config.js
│   └── package.json
├── .env.example
├── .gitignore
├── .eslintrc.json
├── .prettierrc
└── README.md
```

#### 2. Initialize Backend (server/)

Create `server/package.json` and install:

**Production dependencies:**
- express, mongoose, bcryptjs, jsonwebtoken, cors, helmet, morgan, compression, express-rate-limit, joi, dotenv

**Dev dependencies:**
- nodemon, jest, supertest, mongodb-memory-server

Add scripts:
```json
{
  "start": "node server.js",
  "dev": "nodemon server.js",
  "test": "NODE_ENV=test jest --detectOpenHandles --forceExit",
  "test:coverage": "NODE_ENV=test jest --coverage --detectOpenHandles --forceExit"
}
```

#### 3. Initialize Frontend (client/)

Create Vite + React project and install:

**Production dependencies:**
- react, react-dom, react-router-dom, axios

**Dev dependencies:**
- vite, @vitejs/plugin-react, jest, @testing-library/react, @testing-library/jest-dom, @testing-library/user-event, msw, jsdom

Configure Vite with proxy to backend:
```javascript
// vite.config.js
export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      '/api': { target: 'http://localhost:5000', changeOrigin: true }
    }
  }
});
```

#### 4. Create Configuration Files

**.env.example:**
```
NODE_ENV=development
PORT=5000
MONGODB_URI=mongodb://localhost:27017/mean-app
JWT_SECRET=your-secret-key-change-in-production
JWT_EXPIRE=7d
JWT_REFRESH_EXPIRE=30d
CLIENT_URL=http://localhost:3000
```

**.gitignore:**
```
node_modules/
.env
dist/
coverage/
*.log
.DS_Store
```

**.eslintrc.json:** — Standard ESLint config for Node.js + React

**.prettierrc:** — Prettier config (single quotes, semicolons, 2-space indent)

#### 5. Report

Output what was created:
```
## Project Scaffolded: MEAN App

### Directories Created: X
### Config Files Created: X
### Dependencies: X production, X dev

### Next Steps:
1. Copy .env.example to .env and configure
2. Start MongoDB: mongod or use MongoDB Atlas
3. Run /el-capitan {your feature request} to build the app
```

### Edge Cases

- If project already has package.json at root: ask whether to set up server/ and client/ as subdirectories or integrate
- If project name is in $ARGUMENTS: use it for package.json name and MongoDB database name
- If MongoDB Atlas URL provided: use it instead of localhost in .env.example
