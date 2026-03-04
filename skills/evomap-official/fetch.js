const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// Load node ID
const nodeConfigPath = path.join(__dirname, 'node-id.json');
const { nodeId } = JSON.parse(fs.readFileSync(nodeConfigPath, 'utf8'));

// Generate message ID
const msgId = 'msg_' + Date.now() + '_' + crypto.randomBytes(4).toString('hex');
const timestamp = new Date().toISOString();

// Fetch payload
const fetchPayload = {
  protocol: 'gep-a2a',
  protocol_version: '1.0.0',
  message_type: 'fetch',
  message_id: msgId,
  sender_id: nodeId,
  timestamp: timestamp,
  payload: {
    asset_type: 'Capsule',
    include_tasks: true
  }
};

console.log('=== EvoMap Fetch ===\n');
console.log('Node ID:', nodeId);
console.log('Fetching promoted capsules and tasks...\n');

fetch('https://evomap.ai/a2a/fetch', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(fetchPayload)
})
.then(res => res.json())
.then(data => {
  console.log('=== Fetch Response ===\n');
  
  if (data.payload && data.payload.assets) {
    console.log(`📦 Retrieved ${data.payload.assets.length} capsules:\n`);
    
    data.payload.assets.forEach((asset, index) => {
      console.log(`${index + 1}. ${asset.summary?.substring(0, 100)}...`);
      console.log(`   Type: ${asset.type}`);
      console.log(`   GDI Score: ${asset.gdi_score || 'N/A'}`);
      console.log(`   Triggers: ${asset.triggers?.join(', ') || asset.signals_match?.join(', ') || 'N/A'}`);
      console.log(`   Asset ID: ${asset.asset_id?.substring(0, 20)}...`);
      console.log('');
    });
    
    // Save capsules to file
    const capsulesPath = path.join(__dirname, 'fetched-capsules.json');
    fs.writeFileSync(capsulesPath, JSON.stringify(data.payload.assets, null, 2));
    console.log(`💾 Capsules saved to: ${capsulesPath}\n`);
  }
  
  if (data.payload && data.payload.tasks) {
    console.log(`🏆 Available ${data.payload.tasks.length} tasks:\n`);
    
    data.payload.tasks.forEach((task, index) => {
      console.log(`${index + 1}. ${task.title}`);
      console.log(`   Task ID: ${task.task_id}`);
      console.log(`   Signals: ${task.signals?.substring(0, 80) || 'N/A'}`);
      console.log(`   Min Reputation: ${task.min_reputation}`);
      console.log(`   Expires: ${task.expires_at}`);
      console.log('');
    });
  }
  
  // Save full response
  const responsePath = path.join(__dirname, 'fetch-response.json');
  fs.writeFileSync(responsePath, JSON.stringify(data, null, 2));
  console.log(`📄 Full response saved to: ${responsePath}`);
})
.catch(err => {
  console.error('❌ Fetch failed:', err.message);
  process.exit(1);
});
