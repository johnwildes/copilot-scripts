import os
import base64
import requests
import json

# === CONFIGURATION ===
# Azure DevOps configuration
AZDO_ORG = "your_organization"              # e.g. "myorg"
AZDO_PROJECT = "your_project"               # e.g. "MyProject"
AZDO_REPO = "your_repository_id_or_name"     # e.g. "MyRepo"
PR_ID = "pull_request_id"                   # e.g. "123"

# Personal Access Token with proper privileges for Azure DevOps REST API
AZDO_PAT = os.environ.get("AZDO_PAT", "your_pat_here")

# Azure OpenAI configuration
AZURE_OPENAI_ENDPOINT = "https://your-openai-resource.openai.azure.com/openai/deployments/your_deployment_id/completions?api-version=2022-12-01"
AZURE_OPENAI_KEY = os.environ.get("AZURE_OPENAI_KEY", "your_openai_key")
OPENAI_MODEL = "your_model_name"  # e.g. "text-davinci-003"

# ======================

def get_auth_header(token):
    credentials = f":{token}"
    encoded = base64.b64encode(credentials.encode("utf-8")).decode("utf-8")
    return {"Authorization": f"Basic {encoded}"}

def get_latest_iteration_id():
    """Fetches the latest iteration id of the pull request."""
    url = f"https://dev.azure.com/{AZDO_ORG}/{AZDO_PROJECT}/_apis/git/repositories/{AZDO_REPO}/pullRequests/{PR_ID}/iterations?api-version=6.0"
    headers = get_auth_header(AZDO_PAT)
    response = requests.get(url, headers=headers)
    response.raise_for_status()

    iterations = response.json().get("value", [])
    if not iterations:
        raise Exception("No iterations found for the pull request.")
    # Assume the iteration with highest id is the latest.
    latest = max(iterations, key=lambda it: it.get("id", 0))
    return latest.get("id")

def get_pr_code_diff(iteration_id):
    """Fetches code changes (diff content) attached to the PR from the latest iteration."""
    url = f"https://dev.azure.com/{AZDO_ORG}/{AZDO_PROJECT}/_apis/git/repositories/{AZDO_REPO}/pullRequests/{PR_ID}/iterations/{iteration_id}/changes?api-version=6.0"
    headers = get_auth_header(AZDO_PAT)
    response = requests.get(url, headers=headers)
    response.raise_for_status()

    changes = response.json().get("changes", [])
    diff_texts = []
    for change in changes:
        # Try to extract new content if available.
        new_content = change.get("newContent", {}).get("content")
        file_path = change.get("item", {}).get("path", "unknown")
        if new_content:
            diff_texts.append(f"File: {file_path}\n{new_content}\n{'-'*40}\n")
    if not diff_texts:
        raise Exception("No code changes with content found in the pull request.")
    return "\n".join(diff_texts)

def assess_security(code_diff):
    """Send the code diff to Azure OpenAI for security assessment."""
    prompt = f"Please assess the security of the following code changes and identify any potential vulnerabilities:\n\n{code_diff}"
    headers = {
        "Content-Type": "application/json",
        "api-key": AZURE_OPENAI_KEY
    }
    payload = {
        "prompt": prompt,
        "max_tokens": 200,
        "temperature": 0.5,
        "model": OPENAI_MODEL
    }
    response = requests.post(AZURE_OPENAI_ENDPOINT, headers=headers, json=payload)
    response.raise_for_status()

    result = response.json()
    # Assuming the completion text is in choices[0]['text']
    choices = result.get("choices")
    if not choices or not choices[0].get("text"):
        raise Exception("No completion text returned from Azure OpenAI.")
    return choices[0]["text"].strip()

def post_pr_comment(comment):
    """Posts a comment to the pull request as a discussion thread."""
    url = f"https://dev.azure.com/{AZDO_ORG}/{AZDO_PROJECT}/_apis/git/repositories/{AZDO_REPO}/pullRequests/{PR_ID}/threads?api-version=6.0"
    headers = get_auth_header(AZDO_PAT)
    headers["Content-Type"] = "application/json"

    body = {
        "comments": [
            {
                "parentCommentId": 0,
                "content": comment,
                "commentType": 1  # Regular comment
            }
        ],
        "status": 1  # Active
    }
    response = requests.post(url, headers=headers, json=body)
    response.raise_for_status()
    return response.json()

def main():
    try:
        print("Fetching latest iteration ID...")
        iteration_id = get_latest_iteration_id()
        print(f"Latest iteration ID: {iteration_id}")

        print("Fetching PR code diff...")
        code_diff = get_pr_code_diff(iteration_id)
        print("Code diff extracted.")

        print("Sending code diff to Azure OpenAI for security assessment...")
        assessment = assess_security(code_diff)
        print("Assessment received from Azure OpenAI:")

        print(assessment)
        print("Posting assessment as a comment to the pull request...")
        comment_response = post_pr_comment(assessment)
        print("Comment posted successfully.")
        print(json.dumps(comment_response, indent=2))

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()