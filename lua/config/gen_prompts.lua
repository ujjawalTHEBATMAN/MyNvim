-- lua/config/gen_prompts.lua
-- Extracted prompts for Gen.nvim to improve code cleanliness and maintainability

return {
  -- ─────────────────────────────────────────────────────────────────────
  -- 💬 CHAT - Free conversation
  -- ─────────────────────────────────────────────────────────────────────
  Chat = {
    prompt = "$input",
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- 🔧 SMART FIX - Deep analysis then minimal fix
  -- ─────────────────────────────────────────────────────────────────────
  Smart_Fix = {
    prompt = [[STEP 1 - INTERNAL ANALYSIS (do not output this):
- Read the code carefully
- Identify ONLY actual bugs/errors
- Determine minimal changes needed

STEP 2 - OUTPUT:
Apply ONLY these fixes to the code:

```$filetype
$text
```

OUTPUT RULES:
✅ Fix only real issues (syntax errors, logic bugs, null pointer risks)
✅ Add inline comment: // FIXED: description
✅ Preserve ALL original code structure
✅ Preserve ALL original variable names
✅ Preserve ALL original formatting
❌ Do NOT refactor
❌ Do NOT rename variables
❌ Do NOT "improve" working code
❌ Do NOT add features

Output the fixed code only. If no bugs found, output original with: // ✅ No bugs found]],
    replace = true,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- ✨ ENHANCE - Improve while respecting structure
  -- ─────────────────────────────────────────────────────────────────────
  Enhance_Code = {
    prompt = [[ANALYSIS PHASE (internal):
1. Understand the code's purpose
2. Identify enhancement opportunities that don't change behavior
3. Plan minimal, high-impact improvements

ENHANCEMENT PHASE:

```$filetype
$text
```

ALLOWED ENHANCEMENTS:
✅ Add missing error handling (try-catch, null checks)
✅ Add helpful inline comments
✅ Improve variable names for clarity
✅ Apply language-specific best practices

NOT ALLOWED:
❌ Changing the logic/algorithm
❌ Changing the public interface
❌ Adding new functionality
❌ Restructuring the code layout significantly

Output ONLY the enhanced code. Mark changes with: // ENHANCED: reason]],
    replace = true,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- ⚡ OPTIMIZE - Performance focus with complexity tracking
  -- ─────────────────────────────────────────────────────────────────────
  Optimize = {
    prompt = [[COMPLEXITY ANALYSIS (internal):
1. Analyze current time complexity: O(?)
2. Analyze current space complexity: O(?)
3. Identify bottlenecks
4. Plan optimizations

OPTIMIZE THIS CODE:

```$filetype
$text
```

OPTIMIZATION REQUIREMENTS:
✅ Add header comment: // Optimized: O(old) → O(new)
✅ Use efficient data structures
✅ Eliminate redundant operations
✅ Maintain exact same functionality
✅ Mark optimized parts: // OPT: reason

OUTPUT: Only the optimized code with clear comments]],
    replace = true,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- ♻️ REFACTOR - Clean code principles
  -- ─────────────────────────────────────────────────────────────────────
  Refactor = {
    prompt = [[REFACTORING ANALYSIS (internal):
1. Identify code smells
2. Check SOLID principle violations
3. Find DRY violations
4. Plan minimal refactoring

REFACTOR THIS CODE:

```$filetype
$text
```

REFACTORING RULES:
✅ Apply Single Responsibility Principle
✅ Extract repeated code into functions
✅ Use meaningful names
✅ Remove dead code
✅ Mark changes: // REFACTOR: reason

PRESERVE:
- Public interface/API
- Core functionality
- Test compatibility

Output ONLY the refactored code]],
    replace = true,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- 🧩 ADD MISSING - ULTRA SMART: Deep analysis before adding
  -- ─────────────────────────────────────────────────────────────────────
  Add_Missing = {
    prompt = [[=== DEEP CONTEXT ANALYSIS ===

You are inserting code into an existing codebase. You MUST analyze carefully before output.

EXISTING CODE:
```$filetype
$text
```

=== ANALYSIS CHECKLIST (do internally, don't output) ===

□ What imports exist? 
□ What methods exist?
□ What error handling exists?
□ What validation exists?
□ What edge cases are handled?

=== WHAT TO ADD ===

Only add if GENUINELY MISSING:
1. Missing null/undefined checks (if parameters can be null)
2. Missing input validation (if not present)
3. Missing try-catch (if operations can throw)
4. Missing edge cases (empty arrays, zero values, etc.)
5. Missing imports (if referencing undefined classes)

=== OUTPUT RULES ===

✅ MUST add comment for each addition: // ADDED: [reason]
✅ MUST preserve ALL existing code exactly
✅ MUST maintain same indentation style
❌ DO NOT modify existing lines
❌ DO NOT duplicate existing checks
❌ DO NOT add getters/setters unless clearly missing
❌ DO NOT add if the code is already complete

=== OUTPUT ===

If nothing missing: Output original code with one comment at top:
// ✅ Code complete - no additions needed

If additions needed: Output code with ONLY the new parts integrated, each marked with // ADDED: reason]],
    replace = true,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- 🆕 SMART INSERT - Cursor-position aware generation
  -- ─────────────────────────────────────────────────────────────────────
  Smart_Insert = {
    prompt = [[=== CURSOR POSITION CONTEXT ===

The user has selected this code and wants to INSERT something useful.
They are likely looking for code that should go NEAR this selection.

SELECTED CODE (context):
```$filetype
$text
```

=== ANALYZE WHAT'S NEEDED ===

Based on the selected code, determine what the user likely wants:

1. If it's a method → maybe they want tests, docs, or a related helper method
2. If it's a class → maybe they want constructors, toString, equals/hashCode
3. If it's a variable → maybe they want validation or utility code
4. If it's incomplete → maybe they want the implementation

=== USER INPUT ===
$input

=== OUTPUT RULES ===

First, output a ONE-LINE comment explaining what you'll generate:
// 🆕 Generating: [what you're creating]

Then output ONLY the new code to be inserted.
Format it properly with correct indentation.
Make it ready to paste at cursor position.

Do NOT include the original code - only the new insertion.]],
    replace = false,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- 📝 GENERATE DOCS - Clean doc block only
  -- ─────────────────────────────────────────────────────────────────────
  Generate_Docs = {
    prompt = [[=== DOCUMENTATION GENERATION ===

Analyze this code and generate ONLY the documentation block:

```$filetype
$text
```

=== ANALYSIS (internal) ===
1. What does this code do? (purpose)
2. What are the inputs? (parameters)
3. What is the output? (return value)
4. What can go wrong? (exceptions)

=== DOC FORMAT BY LANGUAGE ===

Java → Javadoc:
/**
 * Brief description.
 * 
 * @param name description
 * @return description
 * @throws Exception when...
 */

Python → Google docstring:
"""Brief description.

Args:
    name: description

Returns:
    description

Raises:
    Exception: when...
"""

JavaScript/TypeScript → JSDoc:
/**
 * Brief description.
 * @param {type} name - description
 * @returns {type} description
 * @throws {Error} when...
 */

=== OUTPUT ===

⚠️ OUTPUT ONLY THE DOCUMENTATION BLOCK
⚠️ NO CODE - just the comment/docstring
⚠️ Ready to paste ABOVE the function

The doc block should be copy-paste ready.]],
    replace = false,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- 🧪 GENERATE TESTS - Clean test file content only
  -- ─────────────────────────────────────────────────────────────────────
  Generate_Tests = {
    prompt = [[=== TEST GENERATION ===

Generate unit tests for this code:

```$filetype
$text
```

=== ANALYSIS (internal) ===
1. What is the happy path?
2. What edge cases exist?
3. What errors can occur?
4. What are the boundary values?

=== TEST REQUIREMENTS ===

Coverage:
✅ Happy path (normal usage)
✅ Edge cases (empty, null, zero, max values)
✅ Error cases (invalid inputs)
✅ Boundary values

Format by language:
- Java: JUnit 5 with @Test, @DisplayName, assertions
- Python: pytest with descriptive function names
- JavaScript: Jest with describe/it blocks
- Other: Appropriate framework

=== OUTPUT RULES ===

⚠️ OUTPUT ONLY THE TEST CODE
⚠️ Do NOT include original code
⚠️ Include necessary imports for testing
⚠️ Use descriptive test names
⚠️ Ready to paste into a test file

Start with a comment: // Tests for: <function/class name>]],
    replace = false,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- 🔍 DEEP ANALYZE - Comprehensive but structured
  -- ─────────────────────────────────────────────────────────────────────
  Deep_Analyze = {
    prompt = [[=== DEEP CODE ANALYSIS ===

```$filetype
$text
```

Provide structured analysis:

## 📊 Summary
> One sentence: what this code does

## ✅ Strengths
- Good practices found

## ⚠️ Issues
| Issue | Severity | Fix |
|-------|----------|-----|
| ...   | 🔴/🟡/🟢 | ... |

## ⚡ Performance
- Time: O(?)
- Space: O(?)
- Bottleneck: ...

## 🔒 Security
- Risk level: LOW/MEDIUM/HIGH
- Concern: (if any)

## 🎯 Verdict
One sentence recommendation.

Keep response concise. Focus on actionable insights.]],
    replace = false,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- 👀 CODE REVIEW - Senior engineer perspective
  -- ─────────────────────────────────────────────────────────────────────
  Code_Review = {
    prompt = [[=== CODE REVIEW ===

Reviewing as Senior Engineer:

```$filetype
$text
```

## 📋 Review

### Score: ?/10

### ✅ Approved
- (what's good)

### 🔧 Changes Required
1. **Issue**: description
   ```$filetype
   // Fixed version
   ```

### 💡 Suggestions
- Optional improvements

### 📝 Summary
One sentence verdict: APPROVE / REQUEST CHANGES / REJECT]],
    replace = false,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- 💡 EXPLAIN - Clear educational explanation
  -- ─────────────────────────────────────────────────────────────────────
  Explain_Code = {
    prompt = [[=== CODE EXPLANATION ===

```$filetype
$text
```

## 📖 Explanation

### What It Does
> One clear sentence

### Step by Step
1. First: ...
2. Then: ...
3. Finally: ...

### Key Concepts
- **Concept**: brief explanation

### Example
Input: X → Output: Y

Keep it beginner-friendly but accurate.]],
    replace = false,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- 📋 SUMMARIZE - Ultra concise
  -- ─────────────────────────────────────────────────────────────────────
  Summarize = {
    prompt = [[Summarize in exactly 4 lines:

```$filetype
$text
```

Format:
📋 **Purpose**: (what it does)
📥 **Input**: (what it takes)
📤 **Output**: (what it returns)
⚡ **Complexity**: O(?) time, O(?) space]],
    replace = false,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- ❓ ASK - Contextual question
  -- ─────────────────────────────────────────────────────────────────────
  Ask = {
    prompt = [[Context code:

```$filetype
$text
```

Question: $input

Answer clearly with code examples if helpful.]],
    replace = false,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- 🛡️ SECURITY SCAN
  -- ─────────────────────────────────────────────────────────────────────
  Security_Scan = {
    prompt = [[=== SECURITY AUDIT ===

```$filetype
$text
```

## 🛡️ Security Report

### Risk: 🟢 LOW / 🟡 MEDIUM / 🔴 HIGH

### Vulnerabilities
| # | Issue | CWE | Severity | Fix |
|---|-------|-----|----------|-----|
| 1 | ...   | ... | ...      | ... |

### Secure Version
```$filetype
// Fixed code here
```

### Checklist
- [ ] Input validation
- [ ] Output encoding  
- [ ] Auth checks
- [ ] Error handling (no leaks)

Only report REAL vulnerabilities.]],
    replace = false,
  },

  -- ─────────────────────────────────────────────────────────────────────
  -- ☕ JAVA DEEP DIVE
  -- ─────────────────────────────────────────────────────────────────────
  Java_Deep_Dive = {
    prompt = [[=== JAVA FIRST PRINCIPLES ===

```java
$text
```

## ☕ Deep Dive

### 🔧 JVM Level
- Memory: Stack/Heap usage
- Bytecode: Key operations  
- GC: Impact

### 🏗️ OOP Applied
- Encapsulation: ...
- Inheritance: ...
- Polymorphism: ...

### 📐 Design Pattern
Pattern: ... (or none)

### ⚡ Complexity
- Time: O(?)
- Space: O(?)

### 🎓 Takeaway
Key learning for Java developer.

Format as Obsidian note.]],
    replace = false,
  }
}
