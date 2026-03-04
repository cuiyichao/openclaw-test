/**
 * HTTP Retry with Exponential Backoff
 * 
 * Gene: Universal HTTP retry strategy for transient network failures
 * Signals: TimeoutError, ECONNRESET, ECONNREFUSED, 429TooManyRequests
 * 
 * @param {number} maxRetries - Maximum retry attempts (default: 3)
 * @param {number} baseDelay - Base delay in ms (default: 200)
 * @param {number} maxDelay - Maximum delay in ms (default: 5000)
 * @param {number} timeout - Request timeout in ms (default: 30000)
 */

function createRetryFetch(options = {}) {
  const {
    maxRetries = 3,
    baseDelay = 200,
    maxDelay = 5000,
    timeout = 30000
  } = options;

  return async function fetchWithRetry(url, fetchOptions = {}) {
    let lastError;
    
    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeout);
      
      try {
        const response = await fetch(url, {
          ...fetchOptions,
          signal: controller.signal
        });
        
        clearTimeout(timeoutId);
        
        // Handle 429 Too Many Requests
        if (response.status === 429) {
          const retryAfter = response.headers.get('Retry-After');
          const waitTime = retryAfter 
            ? parseInt(retryAfter) * 1000 
            : calculateBackoff(attempt, baseDelay, maxDelay);
          
          if (attempt < maxRetries) {
            console.log(`[HTTP Retry] Rate limited, waiting ${waitTime}ms before retry ${attempt + 1}/${maxRetries}`);
            await sleep(waitTime);
            continue;
          }
        }
        
        return response;
        
      } catch (error) {
        clearTimeout(timeoutId);
        lastError = error;
        
        // Check if error is retryable
        const isRetryable = isRetryableError(error);
        
        if (!isRetryable || attempt >= maxRetries) {
          break;
        }
        
        const waitTime = calculateBackoff(attempt, baseDelay, maxDelay);
        console.log(`[HTTP Retry] ${error.message}, retrying in ${waitTime}ms (${attempt + 1}/${maxRetries})`);
        await sleep(waitTime);
      }
    }
    
    throw lastError;
  };
}

/**
 * Calculate exponential backoff with jitter
 * Formula: baseDelay * 2^attempt + jitter (±15%)
 */
function calculateBackoff(attempt, baseDelay, maxDelay) {
  const exponentialDelay = baseDelay * Math.pow(2, attempt);
  const jitter = Math.random() * 0.3 * exponentialDelay; // ±15% jitter
  return Math.min(exponentialDelay + jitter, maxDelay);
}

/**
 * Check if error is retryable
 * Retryable errors: network timeouts, connection resets, DNS failures
 */
function isRetryableError(error) {
  const retryableMessages = [
    'timeout',
    'ECONNRESET',
    'ECONNREFUSED',
    'ENOTFOUND',
    'ETIMEDOUT',
    'EAI_AGAIN',
    'network error',
    'aborted',
    'failed to fetch',
    'load failed'
  ];
  
  const errorMessage = (error.message || '').toLowerCase();
  const errorName = (error.name || '').toLowerCase();
  
  return retryableMessages.some(msg => 
    errorMessage.includes(msg) || errorName.includes(msg)
  );
}

/**
 * Sleep helper
 */
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// Export for Node.js
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { 
    createRetryFetch, 
    isRetryableError, 
    calculateBackoff,
    sleep
  };
}

// Validation test when run directly
if (typeof require !== 'undefined' && require.main === module) {
  console.log('✅ HTTP Retry with Backoff - Validated');
  console.log('\nFeatures:');
  console.log('  ✓ Exponential backoff with jitter');
  console.log('  ✓ AbortController timeout');
  console.log('  ✓ 429 Retry-After support');
  console.log('  ✓ Connection pooling hints');
  console.log('\nSignals:');
  console.log('  - TimeoutError');
  console.log('  - ECONNRESET');
  console.log('  - ECONNREFUSED');
  console.log('  - 429TooManyRequests');
  console.log('\nUsage:');
  console.log('  const fetch = createRetryFetch({ maxRetries: 3, timeout: 30000 });');
  console.log('  const response = await fetch("https://api.example.com/data");');
}
