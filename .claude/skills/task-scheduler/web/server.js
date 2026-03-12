#!/usr/bin/env node
/**
 * Task Scheduler WebSocket Server
 *
 * This server provides real-time updates to the Task Scheduler Dashboard.
 * It watches the scheduler-state.json file and pushes updates to all connected
 * WebSocket clients whenever the file changes.
 *
 * Usage:
 *   node server.js [options]
 *
 * Options:
 *   --port, -p     Server port (default: 8080)
 *   --file, -f     Path to scheduler-state.json (default: ../../docs/tasks/scheduler-state.json)
 *   --help, -h     Show help
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

// WebSocket implementation (simple RFC 6455 compliant server)
class WebSocketServer {
  constructor(httpServer) {
    this.clients = new Set();
    this.httpServer = httpServer;

    httpServer.on('upgrade', (request, socket, head) => {
      if (request.headers['upgrade'] !== 'websocket') {
        socket.destroy();
        return;
      }

      this.handleUpgrade(request, socket, head);
    });
  }

  handleUpgrade(request, socket, head) {
    const acceptKey = request.headers['sec-websocket-key'];
    const hash = this.generateAcceptHash(acceptKey);

    const responseHeaders = [
      'HTTP/1.1 101 Switching Protocols',
      'Upgrade: websocket',
      'Connection: Upgrade',
      `Sec-WebSocket-Accept: ${hash}`
    ];

    socket.write(responseHeaders.join('\r\n') + '\r\n\r\n');

    const client = { socket, readyState: 1 };
    this.clients.add(client);

    socket.on('data', (data) => {
      // Handle incoming messages if needed (ping/pong, close frames, etc.)
      this.handleMessage(client, data);
    });

    socket.on('close', () => {
      this.clients.delete(client);
      console.log(`Client disconnected. Total clients: ${this.clients.size}`);
    });

    socket.on('error', (err) => {
      console.error('Socket error:', err.message);
      this.clients.delete(client);
    });

    console.log(`New WebSocket client connected. Total clients: ${this.clients.size}`);
  }

  generateAcceptHash(key) {
    const crypto = require('crypto');
    const magic = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';
    return crypto.createHash('sha1').update(key + magic).digest('base64');
  }

  handleMessage(client, data) {
    // Parse WebSocket frame
    if (data.length < 2) return;

    const opcode = data[0] & 0x0f;

    // Handle close frame
    if (opcode === 0x08) {
      client.socket.end();
      this.clients.delete(client);
    }
  }

  broadcast(data) {
    const message = JSON.stringify(data);
    const frame = this.createFrame(message);

    for (const client of this.clients) {
      try {
        client.socket.write(frame);
      } catch (err) {
        console.error('Error broadcasting to client:', err.message);
        this.clients.delete(client);
      }
    }
  }

  createFrame(message) {
    const payload = Buffer.from(message);
    const payloadLength = payload.length;

    let frame;
    if (payloadLength <= 125) {
      frame = Buffer.alloc(2 + payloadLength);
      frame[0] = 0x81; // FIN + Text frame
      frame[1] = payloadLength;
      payload.copy(frame, 2);
    } else if (payloadLength <= 65535) {
      frame = Buffer.alloc(4 + payloadLength);
      frame[0] = 0x81;
      frame[1] = 126;
      frame.writeUInt16BE(payloadLength, 2);
      payload.copy(frame, 4);
    } else {
      frame = Buffer.alloc(10 + payloadLength);
      frame[0] = 0x81;
      frame[1] = 127;
      frame.writeBigUInt64BE(BigInt(payloadLength), 2);
      payload.copy(frame, 10);
    }

    return frame;
  }
}

// Main server class
class TaskSchedulerServer {
  constructor(options = {}) {
    this.port = options.port || 8099;
    this.stateFile = path.resolve(options.stateFile || path.join(__dirname, '../../../../docs/tasks/scheduler-state.json'));
    this.webDir = options.webDir || __dirname;
    this.lastData = null;
    this.wsServer = null;
    this.httpServer = null;
    this.watcher = null;
  }

  start() {
    // Create HTTP server
    this.httpServer = http.createServer((req, res) => {
      this.handleHttpRequest(req, res);
    });

    // Create WebSocket server
    this.wsServer = new WebSocketServer(this.httpServer);

    // Start watching the state file
    this.startWatching();

    // Start the server
    this.httpServer.listen(this.port, () => {
      console.log(`Task Scheduler Dashboard Server running at http://localhost:${this.port}`);
      console.log(`WebSocket endpoint: ws://localhost:${this.port}/ws`);
      console.log(`Watching state file: ${this.stateFile}`);
    });
  }

  handleHttpRequest(req, res) {
    const parsedUrl = url.parse(req.url, true);
    const pathname = parsedUrl.pathname;

    // CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
      res.writeHead(200);
      res.end();
      return;
    }

    // API endpoint to get current state
    if (pathname === '/api/state') {
      this.serveStateFile(res);
      return;
    }

    // WebSocket upgrade is handled by WebSocketServer
    if (pathname === '/ws') {
      return; // Will be handled by upgrade event
    }

    // Serve static files
    this.serveStaticFile(pathname, res);
  }

  serveStaticFile(pathname, res) {
    let filePath = pathname === '/' ? '/index.html' : pathname;
    filePath = path.join(this.webDir, filePath);

    // Security: prevent directory traversal
    if (!filePath.startsWith(this.webDir)) {
      res.writeHead(403);
      res.end('Forbidden');
      return;
    }

    fs.readFile(filePath, (err, data) => {
      if (err) {
        if (err.code === 'ENOENT') {
          res.writeHead(404);
          res.end('Not Found');
        } else {
          res.writeHead(500);
          res.end('Internal Server Error');
        }
        return;
      }

      const ext = path.extname(filePath);
      const contentTypes = {
        '.html': 'text/html',
        '.css': 'text/css',
        '.js': 'application/javascript',
        '.json': 'application/json',
        '.png': 'image/png',
        '.jpg': 'image/jpeg',
        '.svg': 'image/svg+xml'
      };

      res.setHeader('Content-Type', contentTypes[ext] || 'application/octet-stream');
      res.writeHead(200);
      res.end(data);
    });
  }

  serveStateFile(res) {
    fs.readFile(this.stateFile, 'utf8', (err, data) => {
      if (err) {
        if (err.code === 'ENOENT') {
          // File doesn't exist yet - return empty state
          const emptyState = {
            status: 'stopped',
            start_time: null,
            team_name: null,
            tasks: [],
            max_concurrency: 4
          };
          res.setHeader('Content-Type', 'application/json');
          res.writeHead(200);
          res.end(JSON.stringify(emptyState));
        } else {
          res.writeHead(500);
          res.end('Error reading state file');
        }
        return;
      }

      try {
        const json = JSON.parse(data);
        res.setHeader('Content-Type', 'application/json');
        res.writeHead(200);
        res.end(JSON.stringify(json));
      } catch (parseErr) {
        res.writeHead(500);
        res.end('Invalid JSON in state file');
      }
    });
  }

  startWatching() {
    // Check if file exists
    const dir = path.dirname(this.stateFile);

    // Ensure directory exists
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    // Watch the directory (more reliable than watching the file itself)
    this.watcher = fs.watch(dir, (eventType, filename) => {
      if (filename === path.basename(this.stateFile)) {
        this.onFileChange();
      }
    });

    // Also poll for changes (backup for reliability)
    this.pollInterval = setInterval(() => {
      this.onFileChange();
    }, 1000);

    console.log('Started watching for state file changes');
  }

  onFileChange() {
    fs.readFile(this.stateFile, 'utf8', (err, data) => {
      if (err) {
        if (err.code !== 'ENOENT') {
          console.error('Error reading state file:', err.message);
        }
        return;
      }

      // Only broadcast if data actually changed
      if (data !== this.lastData) {
        this.lastData = data;

        try {
          const json = JSON.parse(data);
          console.log(`State changed - broadcasting to ${this.wsServer.clients.size} clients`);
          this.wsServer.broadcast(json);
        } catch (parseErr) {
          console.error('Error parsing state file:', parseErr.message);
        }
      }
    });
  }

  stop() {
    if (this.watcher) {
      this.watcher.close();
    }
    if (this.pollInterval) {
      clearInterval(this.pollInterval);
    }
    if (this.httpServer) {
      this.httpServer.close();
    }
    console.log('Server stopped');
  }
}

// Parse command line arguments
function parseArgs() {
  const args = process.argv.slice(2);
  const options = {};

  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--port':
      case '-p':
        options.port = parseInt(args[++i], 10);
        break;
      case '--file':
      case '-f':
        options.stateFile = args[++i];
        break;
      case '--help':
      case '-h':
        console.log(`
Task Scheduler WebSocket Server

Usage:
  node server.js [options]

Options:
  --port, -p     Server port (default: 8080)
  --file, -f     Path to scheduler-state.json (default: ../../docs/tasks/scheduler-state.json)
  --help, -h     Show this help

Description:
  This server provides real-time updates to the Task Scheduler Dashboard.
  It serves the dashboard HTML and watches the scheduler-state.json file
  for changes, broadcasting updates to all connected WebSocket clients.
        `);
        process.exit(0);
        break;
    }
  }

  return options;
}

// Start the server
if (require.main === module) {
  const options = parseArgs();
  const server = new TaskSchedulerServer(options);

  // Handle shutdown gracefully
  process.on('SIGINT', () => {
    console.log('\nShutting down...');
    server.stop();
    process.exit(0);
  });

  process.on('SIGTERM', () => {
    server.stop();
    process.exit(0);
  });

  server.start();
}

module.exports = { TaskSchedulerServer, WebSocketServer };