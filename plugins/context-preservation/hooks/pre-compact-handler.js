#!/usr/bin/env node

/**
 * PreCompact Hook - Context Preservation
 *
 * Automatically saves important development context before Claude compacts
 * conversation history. Extracts and preserves:
 * - Architecture decisions
 * - Design rationales
 * - Performance optimizations
 * - Debugging insights
 * - Tradeoff discussions
 */

const fs = require('fs');
const path = require('path');

// Read input from stdin
let inputData = '';
process.stdin.on('data', (chunk) => {
  inputData += chunk;
});

process.stdin.on('end', () => {
  try {
    const input = JSON.parse(inputData);
    preserveContext(input);
  } catch (error) {
    console.error('Error processing input:', error.message);
    process.exit(0); // Don't block compaction on error
  }
});

/**
 * Main function to preserve context
 */
function preserveContext(input) {
  const sessionId = input.session_id || 'unknown';
  const messages = input.messages || [];

  if (messages.length === 0) {
    console.error('No messages to preserve');
    process.exit(0);
  }

  // Extract important context
  const importantContext = extractImportantContext(messages);

  if (importantContext.length === 0) {
    console.error('No important context found');
    process.exit(0);
  }

  // Save to file
  const saved = saveContext(sessionId, importantContext);

  if (saved) {
    console.error(`✓ Preserved ${importantContext.length} important context items`);
  }

  process.exit(0);
}

/**
 * Extract important context from conversation messages
 */
function extractImportantContext(messages) {
  const importantPatterns = [
    // Architecture and design decisions
    {
      type: 'architecture',
      patterns: [
        /decided? to (use|choose|implement|adopt)/i,
        /went with .* because/i,
        /designed? .* to (be|have|support)/i,
        /structured .* as/i,
        /architecture.*decision/i,
        /chose .* over .* because/i,
      ]
    },
    // Tradeoffs and rationale
    {
      type: 'tradeoff',
      patterns: [
        /tradeoff between .* and/i,
        /pros?.* and cons?/i,
        /benefit.* but .* drawback/i,
        /advantage.* disadvantage/i,
      ]
    },
    // Performance optimizations
    {
      type: 'optimization',
      patterns: [
        /optimized? .* by/i,
        /improved? .* from .* to/i,
        /performance.* (improved|better|faster)/i,
        /reduced .* from .* to/i,
        /bundle size.* (reduced|decreased)/i,
      ]
    },
    // Bug fixes and debugging
    {
      type: 'debugging',
      patterns: [
        /(fixed|solved|resolved) .* by/i,
        /(bug|issue) was caused by/i,
        /root cause.* (was|is)/i,
        /problem.* (was|is).* because/i,
      ]
    },
    // Implementation details
    {
      type: 'implementation',
      patterns: [
        /implemented .* using/i,
        /approach.* (is|was) to/i,
        /solution.* (is|was) to/i,
        /strategy.* (is|was) to/i,
      ]
    },
    // Requirements and constraints
    {
      type: 'requirements',
      patterns: [
        /requirement.* (is|are|was|were)/i,
        /constraint.* (is|are|was|were)/i,
        /must .* because/i,
        /cannot .* because/i,
      ]
    }
  ];

  const contexts = [];

  messages.forEach((message, index) => {
    const content = message.content || '';
    const role = message.role || 'unknown';

    // Check each pattern category
    importantPatterns.forEach(category => {
      category.patterns.forEach(pattern => {
        if (pattern.test(content)) {
          // Extract the relevant sentence or paragraph
          const extracted = extractRelevantText(content, pattern);

          if (extracted && extracted.length > 20) {
            contexts.push({
              type: category.type,
              content: extracted,
              role: role,
              messageIndex: index,
              timestamp: message.timestamp || new Date().toISOString()
            });
          }
        }
      });
    });
  });

  // Deduplicate similar contexts
  return deduplicateContexts(contexts);
}

/**
 * Extract relevant text around a pattern match
 */
function extractRelevantText(content, pattern) {
  const match = content.match(pattern);
  if (!match) return null;

  const matchIndex = match.index;
  const lines = content.split('\n');

  // Find the line containing the match
  let currentPos = 0;
  let matchLine = null;

  for (let i = 0; i < lines.length; i++) {
    const lineLength = lines[i].length + 1; // +1 for newline
    if (currentPos <= matchIndex && matchIndex < currentPos + lineLength) {
      matchLine = i;
      break;
    }
    currentPos += lineLength;
  }

  if (matchLine === null) return null;

  // Extract the line and adjacent lines for context
  const start = Math.max(0, matchLine - 1);
  const end = Math.min(lines.length, matchLine + 2);
  const relevantText = lines.slice(start, end).join('\n').trim();

  // Limit length
  return relevantText.length > 500
    ? relevantText.substring(0, 500) + '...'
    : relevantText;
}

/**
 * Remove duplicate or very similar contexts
 */
function deduplicateContexts(contexts) {
  const unique = [];
  const seen = new Set();

  contexts.forEach(context => {
    // Create a normalized version for comparison
    const normalized = context.content
      .toLowerCase()
      .replace(/\s+/g, ' ')
      .substring(0, 100);

    if (!seen.has(normalized)) {
      seen.add(normalized);
      unique.push(context);
    }
  });

  return unique;
}

/**
 * Save context to file
 */
function saveContext(sessionId, contexts) {
  try {
    // Create .claude/session-context directory
    const contextDir = path.join(process.cwd(), '.claude', 'session-context');

    if (!fs.existsSync(contextDir)) {
      fs.mkdirSync(contextDir, { recursive: true });
    }

    // Generate filename with timestamp
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const filename = `${sessionId}_${timestamp}.json`;
    const filepath = path.join(contextDir, filename);

    // Prepare data structure
    const data = {
      sessionId: sessionId,
      preservedAt: new Date().toISOString(),
      project: process.cwd(),
      contextCount: contexts.length,
      contexts: contexts.map(ctx => ({
        type: ctx.type,
        content: ctx.content,
        role: ctx.role,
        timestamp: ctx.timestamp
      }))
    };

    // Write to file
    fs.writeFileSync(filepath, JSON.stringify(data, null, 2));

    // Also create/update a summary file
    updateSummaryFile(contextDir, sessionId, contexts.length);

    return true;
  } catch (error) {
    console.error('Error saving context:', error.message);
    return false;
  }
}

/**
 * Update summary file with information about preserved contexts
 */
function updateSummaryFile(contextDir, sessionId, count) {
  try {
    const summaryFile = path.join(contextDir, 'summary.json');

    let summary = { sessions: [] };
    if (fs.existsSync(summaryFile)) {
      summary = JSON.parse(fs.readFileSync(summaryFile, 'utf8'));
    }

    // Add or update session entry
    const existingIndex = summary.sessions.findIndex(s => s.sessionId === sessionId);
    const sessionEntry = {
      sessionId: sessionId,
      lastPreserved: new Date().toISOString(),
      contextCount: count
    };

    if (existingIndex >= 0) {
      summary.sessions[existingIndex] = sessionEntry;
    } else {
      summary.sessions.push(sessionEntry);
    }

    // Keep only last 20 sessions
    if (summary.sessions.length > 20) {
      summary.sessions = summary.sessions.slice(-20);
    }

    fs.writeFileSync(summaryFile, JSON.stringify(summary, null, 2));
  } catch (error) {
    // Don't fail if summary update fails
    console.error('Warning: Could not update summary file:', error.message);
  }
}
