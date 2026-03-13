/**
 * Unit Tests for WebSocket Server
 *
 * Tests for web/server.js - Task Scheduler Dashboard WebSocket Server
 *
 * Run with: node server.test.js
 */

const assert = require('assert');
const http = require('http');
const fs = require('fs');
const path = require('path');
const { TaskSchedulerServer, WebSocketServer } = require('./server.js');

const TEST_PORT = 18080;
const TEST_STATE_FILE = '/tmp/test-scheduler-state.json';

// Helper to create test state file
function createTestState(data = {}) {
  const defaultState = {
    status: 'running',
    start_time: new Date().toISOString(),
    team_name: 'test-team',
    tasks: [
      { id: '1', subject: 'Task 1', status: 'completed', owner: 'worker-1' },
      { id: '2', subject: 'Task 2', status: 'in_progress', owner: 'worker-2' },
      { id: '3', subject: 'Task 3', status: 'pending' }
    ],
    max_concurrency: 4
  };
  fs.writeFileSync(TEST_STATE_FILE, JSON.stringify({ ...defaultState, ...data }));
}

// Helper to make HTTP request
function makeRequest(options, body = null) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        resolve({
          statusCode: res.statusCode,
          headers: res.headers,
          body: data
        });
      });
    });
    req.on('error', reject);
    req.setTimeout(5000, () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });
    if (body) {
      req.write(body);
    }
    req.end();
  });
}

// Test suite
async function runTests() {
  let passed = 0;
  let failed = 0;
  let server = null;

  console.log('=== WebSocket Server Unit Tests ===\n');

  // Test 1: Server starts and stops correctly
  try {
    createTestState();
    server = new TaskSchedulerServer({
      port: TEST_PORT,
      stateFile: TEST_STATE_FILE
    });
    server.start();

    // Give server time to start
    await new Promise(resolve => setTimeout(resolve, 100));

    assert.ok(server.httpServer, 'Should have httpServer');
    assert.ok(server.wsServer, 'Should have wsServer');
    assert.ok(server.watcher, 'Should have file watcher');

    server.stop();
    console.log('✓ Test 1: Server starts and stops correctly');
    passed++;
  } catch (err) {
    console.log(`✗ Test 1 failed: ${err.message}`);
    failed++;
    if (server) {
      try { server.stop(); } catch (e) { /* ignore */ }
    }
  }

  // Test 2: HTTP GET /api/state returns state
  try {
    createTestState({ status: 'running' });
    server = new TaskSchedulerServer({
      port: TEST_PORT + 1,
      stateFile: TEST_STATE_FILE
    });
    server.start();
    await new Promise(resolve => setTimeout(resolve, 100));

    const response = await makeRequest({
      hostname: 'localhost',
      port: TEST_PORT + 1,
      path: '/api/state',
      method: 'GET'
    });

    assert.strictEqual(response.statusCode, 200, 'Should return 200');
    const body = JSON.parse(response.body);
    assert.strictEqual(body.status, 'running', 'Should return status');

    server.stop();
    console.log('✓ Test 2: HTTP GET /api/state returns state');
    passed++;
  } catch (err) {
    console.log(`✗ Test 2 failed: ${err.message}`);
    failed++;
    if (server) try { server.stop(); } catch (e) {}
  }

  // Test 3: HTTP GET /api/state returns empty state for missing file
  try {
    const missingFile = '/tmp/nonexistent-state-' + Date.now() + '.json';
    server = new TaskSchedulerServer({
      port: TEST_PORT + 2,
      stateFile: missingFile
    });
    server.start();
    await new Promise(resolve => setTimeout(resolve, 100));

    const response = await makeRequest({
      hostname: 'localhost',
      port: TEST_PORT + 2,
      path: '/api/state',
      method: 'GET'
    });

    assert.strictEqual(response.statusCode, 200, 'Should return 200');
    const body = JSON.parse(response.body);
    assert.strictEqual(body.status, 'stopped', 'Should return stopped status');
    assert.ok(Array.isArray(body.tasks), 'Should have tasks array');

    server.stop();
    console.log('✓ Test 3: HTTP GET /api/state returns empty state for missing file');
    passed++;
  } catch (err) {
    console.log(`✗ Test 3 failed: ${err.message}`);
    failed++;
    if (server) try { server.stop(); } catch (e) {}
  }

  // Test 4: CORS headers are set
  try {
    createTestState();
    server = new TaskSchedulerServer({
      port: TEST_PORT + 3,
      stateFile: TEST_STATE_FILE
    });
    server.start();
    await new Promise(resolve => setTimeout(resolve, 100));

    const response = await makeRequest({
      hostname: 'localhost',
      port: TEST_PORT + 3,
      path: '/api/state',
      method: 'GET'
    });

    assert.strictEqual(response.headers['access-control-allow-origin'], '*', 'Should have CORS header');

    server.stop();
    console.log('✓ Test 4: CORS headers are set');
    passed++;
  } catch (err) {
    console.log(`✗ Test 4 failed: ${err.message}`);
    failed++;
    if (server) try { server.stop(); } catch (e) {}
  }

  // Test 5: OPTIONS request returns 200
  try {
    createTestState();
    server = new TaskSchedulerServer({
      port: TEST_PORT + 4,
      stateFile: TEST_STATE_FILE
    });
    server.start();
    await new Promise(resolve => setTimeout(resolve, 100));

    const response = await makeRequest({
      hostname: 'localhost',
      port: TEST_PORT + 4,
      path: '/api/state',
      method: 'OPTIONS'
    });

    assert.strictEqual(response.statusCode, 200, 'OPTIONS should return 200');

    server.stop();
    console.log('✓ Test 5: OPTIONS request returns 200');
    passed++;
  } catch (err) {
    console.log(`✗ Test 5 failed: ${err.message}`);
    failed++;
    if (server) try { server.stop(); } catch (e) {}
  }

  // Test 6: 404 for non-existent file path
  try {
    createTestState();
    server = new TaskSchedulerServer({
      port: TEST_PORT + 5,
      stateFile: TEST_STATE_FILE
    });
    server.start();
    await new Promise(resolve => setTimeout(resolve, 100));

    const response = await makeRequest({
      hostname: 'localhost',
      port: TEST_PORT + 5,
      path: '/nonexistent-path-12345',
      method: 'GET'
    });

    assert.strictEqual(response.statusCode, 404, 'Should return 404');

    server.stop();
    console.log('✓ Test 6: 404 for non-existent file path');
    passed++;
  } catch (err) {
    console.log(`✗ Test 6 failed: ${err.message}`);
    failed++;
    if (server) try { server.stop(); } catch (e) {}
  }

  // Test 7: WebSocketServer generateAcceptHash
  try {
    const mockHttpServer = new http.Server();
    const wsServer = new WebSocketServer(mockHttpServer);

    const key = 'dGhlIHNhbXBsZSBub25jZQ==';
    const hash = wsServer.generateAcceptHash(key);

    // Known test vector from RFC 6455
    assert.strictEqual(hash, 's3pPLMBiTxaQ9kYGzzhZRbK+xOo=', 'Should match RFC 6455 test vector');

    console.log('✓ Test 7: WebSocketServer generateAcceptHash correct');
    passed++;
  } catch (err) {
    console.log(`✗ Test 7 failed: ${err.message}`);
    failed++;
  }

  // Test 8: WebSocketServer createFrame for small messages
  try {
    const mockHttpServer = new http.Server();
    const wsServer = new WebSocketServer(mockHttpServer);

    const message = 'Hello, WebSocket!';
    const frame = wsServer.createFrame(message);

    assert.ok(Buffer.isBuffer(frame), 'Should return a Buffer');
    assert.strictEqual(frame[0], 0x81, 'First byte should be FIN + Text frame');

    // Check payload length (small frame: length in second byte)
    const payload = Buffer.from(message);
    assert.strictEqual(frame[1], payload.length, 'Second byte should be payload length');

    console.log('✓ Test 8: WebSocketServer createFrame for small messages');
    passed++;
  } catch (err) {
    console.log(`✗ Test 8 failed: ${err.message}`);
    failed++;
  }

  // Test 9: WebSocketServer createFrame for medium messages (126-65535 bytes)
  try {
    const mockHttpServer = new http.Server();
    const wsServer = new WebSocketServer(mockHttpServer);

    // Create a message > 125 bytes
    const message = 'A'.repeat(200);
    const frame = wsServer.createFrame(message);

    assert.strictEqual(frame[0], 0x81, 'First byte should be FIN + Text frame');
    assert.strictEqual(frame[1], 126, 'Second byte should be 126 for medium payload');

    // Extended payload length is in bytes 2-3
    const payloadLength = frame.readUInt16BE(2);
    assert.strictEqual(payloadLength, 200, 'Extended length should be 200');

    console.log('✓ Test 9: WebSocketServer createFrame for medium messages');
    passed++;
  } catch (err) {
    console.log(`✗ Test 9 failed: ${err.message}`);
    failed++;
  }

  // Test 10: WebSocketServer broadcast to clients
  try {
    const mockHttpServer = new http.Server();
    const wsServer = new WebSocketServer(mockHttpServer);

    // Create mock clients
    let receivedData = null;
    const mockSocket = {
      write: (data) => { receivedData = data; }
    };
    const mockClient = { socket: mockSocket, readyState: 1 };
    wsServer.clients.add(mockClient);

    const testData = { type: 'test', message: 'Hello' };
    wsServer.broadcast(testData);

    assert.ok(receivedData, 'Should have received data');
    // Verify frame structure
    assert.ok(Buffer.isBuffer(receivedData), 'Should be a buffer');
    assert.strictEqual(receivedData[0], 0x81, 'Should be text frame');

    // Parse the message from frame
    const payload = receivedData.slice(2).toString();
    const parsed = JSON.parse(payload);
    assert.deepStrictEqual(parsed, testData, 'Should broadcast correct data');

    console.log('✓ Test 10: WebSocketServer broadcast to clients');
    passed++;
  } catch (err) {
    console.log(`✗ Test 10 failed: ${err.message}`);
    failed++;
  }

  // Test 11: Directory traversal prevention
  try {
    createTestState();
    server = new TaskSchedulerServer({
      port: TEST_PORT + 6,
      stateFile: TEST_STATE_FILE
    });
    server.start();
    await new Promise(resolve => setTimeout(resolve, 100));

    const response = await makeRequest({
      hostname: 'localhost',
      port: TEST_PORT + 6,
      path: '/../../../etc/passwd',
      method: 'GET'
    });

    assert.strictEqual(response.statusCode, 403, 'Should return 403 Forbidden');

    server.stop();
    console.log('✓ Test 11: Directory traversal prevention');
    passed++;
  } catch (err) {
    console.log(`✗ Test 11 failed: ${err.message}`);
    failed++;
    if (server) try { server.stop(); } catch (e) {}
  }

  // Test 12: WebSocketServer clients management
  try {
    const mockHttpServer = new http.Server();
    const wsServer = new WebSocketServer(mockHttpServer);

    assert.strictEqual(wsServer.clients.size, 0, 'Should start with no clients');

    // Add mock client
    const mockClient = { socket: {}, readyState: 1 };
    wsServer.clients.add(mockClient);
    assert.strictEqual(wsServer.clients.size, 1, 'Should have 1 client');

    // Remove mock client
    wsServer.clients.delete(mockClient);
    assert.strictEqual(wsServer.clients.size, 0, 'Should have 0 clients after removal');

    console.log('✓ Test 12: WebSocketServer clients management');
    passed++;
  } catch (err) {
    console.log(`✗ Test 12 failed: ${err.message}`);
    failed++;
  }

  // Cleanup
  try {
    fs.unlinkSync(TEST_STATE_FILE);
  } catch (e) { /* ignore */ }

  // Summary
  console.log(`\n=== Test Summary ===`);
  console.log(`Passed: ${passed}`);
  console.log(`Failed: ${failed}`);
  console.log(`Total:  ${passed + failed}`);

  return failed === 0;
}

// Run tests
runTests().then(success => {
  process.exit(success ? 0 : 1);
}).catch(err => {
  console.error('Test runner error:', err);
  process.exit(1);
});