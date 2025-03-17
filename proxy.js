const http = require('http');
const https = require('https');
const url = require('url');

const PORT = 8003;
const TARGET_HOST = 'localhost';
const TARGET_PORT = 8080;

// Create a server
const server = http.createServer((req, res) => {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', '*');
  
  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }
  
  // Parse the request URL
  const parsedUrl = url.parse(req.url);
  
  // Create options for the proxy request
  const options = {
    hostname: TARGET_HOST,
    port: TARGET_PORT,
    path: parsedUrl.path,
    method: req.method,
    headers: {
      ...req.headers,
      host: TARGET_HOST
    }
  };
  
  // Create the proxy request
  const proxyReq = http.request(options, (proxyRes) => {
    // Set the status code and headers
    res.writeHead(proxyRes.statusCode, proxyRes.headers);
    
    // Pipe the response data
    proxyRes.pipe(res);
  });
  
  // Handle errors
  proxyReq.on('error', (error) => {
    console.error('Proxy request error:', error);
    res.writeHead(500);
    res.end('Proxy error: ' + error.message);
  });
  
  // Pipe the request data
  req.pipe(proxyReq);
});

// Start the server
server.listen(PORT, () => {
  console.log(`Proxy server running at http://localhost:${PORT}/`);
  console.log(`Forwarding requests to http://${TARGET_HOST}:${TARGET_PORT}/`);
}); 