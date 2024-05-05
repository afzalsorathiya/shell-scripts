import requests

# Replace 'your_username' and 'your_token' with your GitHub username and personal access token
username = 'afzalsorathiya'
token = 'token-git'

# List of repository names to delete
repositories_to_delete = ['testnana', 'todo-node-app', 'javascript', 'Resume', 'DSA','php_collage','Good_Sentences', 'git-github']

for repo in repositories_to_delete:
    url = f'https://api.github.com/repos/{username}/{repo}'
    headers = {'Authorization': f'token {token}'}
    response = requests.delete(url, headers=headers)
    if response.status_code == 204:
        print(f"Repository '{repo}' deleted successfully.")
    else:
        print(f"Failed to delete repository '{repo}'. Status code: {response.status_code}")
