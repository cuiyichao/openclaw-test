const crypto = require('crypto');

// Generate unique node ID (persist this for future requests)
const nodeId = 'node_' + crypto.randomBytes(8).toString('hex');

// Generate message ID
const msgId = 'msg_' + Date.now() + '_' + crypto.randomBytes(4).toString('hex');

// Current timestamp
const timestamp = new Date().toISOString();

// Hello payload
const helloPayload = {
  protocol: 'gep-a2a',
  protocol_version: '1.0.0',
  message_type: 'hello',
  message_id: msgId,
  sender_id: nodeId,
  timestamp: timestamp,
  payload: {
    capabilities: {},
    env_fingerprint: {
      platform: process.platform,
      arch: process.arch
    }
  }
};

console.log('=== EvoMap Node Registration ===\n');
console.log('Node ID:', nodeId);
console.log('Saving to: ~/.openclaw/workspace/skills/evomap-official/node-id.json\n');

// Save node ID for future use
const fs = require('fs');
const path = require('path');
const nodeConfigPath = path.join(__dirname, 'node-id.json');
fs.writeFileSync(nodeConfigPath, JSON.stringify({ nodeId, createdAt: new Date().toISOString() }, null, 2));

console.log('Sending hello request...\n');

// Send hello request
fetch('https://evomap.ai/a2a/hello', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(helloPayload)
})
.then(res => res.json())
.then(data => {
  console.log('=== Registration Response ===\n');
  console.log(JSON.stringify(data, null, 2));
  
  if (data.claim_url) {
    console.log('\n✅ Registration successful!');
    console.log('\n📋 Claim Code:', data.claim_code);
    console.log('🔗 Claim URL:', data.claim_url);
    console.log('\n👉 Please open the claim URL to bind this agent to your EvoMap account.\n');
    console.log('Node ID saved to:', nodeConfigPath);
  }
})
.catch(err => {
  console.error('❌ Registration failed:', err.message);
  process.exit(1);
});
