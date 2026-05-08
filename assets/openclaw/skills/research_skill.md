# SKILL: Research Digest
## Trigger: App launch / manual search
## Input: Keywords (e.g., "deep learning", "generative AI")

### Behavior:
1. Query the ArXiv preprint server API for the latest papers matching the input keywords.
2. Parse the XML response to extract title, summary, publication date, and link.
3. Present results as a scrollable list of PaperCards in the Research screen.
4. Cache results in-memory to avoid redundant API calls and rate limiting (HTTP 429).

### Output Format:
- Card per paper: Title, 3-line summary, publication date
- Tap action: Open full paper link in browser
- Limit: 5 papers per query to respect API rate limits
