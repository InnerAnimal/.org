const GITHUB_TOKEN = import.meta.env.VITE_GITHUB_TOKEN;

/**
 * Fetch repositories from GitHub API
 * @param {string} org - Organization name
 * @returns {Promise<Array>}
 */
export async function fetchRepositories(org = 'meauxbility') {
  if (!GITHUB_TOKEN) {
    console.warn('GitHub token not configured. Using mock data.');
    return [];
  }

  try {
    const response = await fetch(`https://api.github.com/orgs/${org}/repos`, {
      headers: {
        'Authorization': `token ${GITHUB_TOKEN}`,
        'Accept': 'application/vnd.github.v3+json'
      }
    });

    if (!response.ok) {
      throw new Error(`GitHub API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error fetching repositories:', error);
    return [];
  }
}

/**
 * Fetch issues from GitHub API
 * @param {string} owner - Repository owner
 * @param {string} repo - Repository name
 * @returns {Promise<Array>}
 */
export async function fetchIssues(owner = 'meauxbility', repo) {
  if (!GITHUB_TOKEN) {
    console.warn('GitHub token not configured.');
    return [];
  }

  try {
    const response = await fetch(
      `https://api.github.com/repos/${owner}/${repo}/issues?state=open`,
      {
        headers: {
          'Authorization': `token ${GITHUB_TOKEN}`,
          'Accept': 'application/vnd.github.v3+json'
        }
      }
    );

    if (!response.ok) {
      throw new Error(`GitHub API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error fetching issues:', error);
    return [];
  }
}

