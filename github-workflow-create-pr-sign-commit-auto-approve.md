
```
# This reusable workflow
#   - creates a PR with the change
#   - signs the commit using the GH API
#   - enables PR auto merge
#   - approves the PR using another GH token then the one it creates the PR

name: Reusable_Workflow_Image_Version_Change
on:
  workflow_call:
    inputs:
      image_name:
        required: true
        type: string
      image_tag:
        required: true
        type: string
    secrets:
      token_approve_pr:
        required: true

jobs:
  create_merge_pr:
    runs-on: ubuntu-latest
    steps:
      # I know this is not pretty (debug information) but I want this info
      - name: Dump github context
        env: 
          JOB_CONTEXT: ${{ toJson(github) }}
        run: |
          echo 'The triggering workflow passed'
          echo "${JOB_CONTEXT}"
  # https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#using-data-from-the-triggering-workflow
      - name: Checkout
        uses: actions/checkout@master
    # Use the REST API to commit changes, so we get automatic commit signing
      - name: Create PR and sign commits using Github API
        id: cpr
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          FILE_TO_COMMIT: ${{ inputs.path_to_docker_versions_json }}
        run: |
          set -eou pipefail

          pwd
          ls -la
          echo "INFO Set values for DESTINATION_BRANCH"
          random_str() {
            tr -dc A-Za-z0-9 </dev/urandom | head -c 5 ; echo '';
          }
          DESTINATION_BRANCH="automated-pr-${IMAGE_NAME}-${IMAGE_TAG}-$(random_str)"

          echo "INFO Create new branch and push it to the repo"
          git checkout -b "${DESTINATION_BRANCH}"
          git push --set-upstream origin "${DESTINATION_BRANCH}"

          echo "INFO set values required to commit and sign via GH API"
          TODAY=$(date -u '+%Y-%m-%d')
          MESSAGE="updating ${FILE_TO_COMMIT} for ${TODAY}"
          SHA=$(git rev-parse "${DESTINATION_BRANCH}":"${FILE_TO_COMMIT}")
          CONTENT=$(base64 -i ${FILE_TO_COMMIT})

          echo "INFO commit and sign the commits with the GH API"
          gh api --method PUT /repos/{owner}/{repo}/contents/"${FILE_TO_COMMIT}" \
                 --field message="${MESSAGE}" \
                 --field content="${CONTENT}" \
                 --field encoding="base64" \
                 --field branch="${DESTINATION_BRANCH}" \
                 --field sha="${SHA}"

          echo "INFO create the PR"
          PR_BODY="This PR was auto-generated on $(date +%d-%m-%Y)"
          pr_create_out=$(gh pr create \
                             --title "${DESTINATION_BRANCH}" \
                             --body "${PR_BODY}")
          echo "${pr_create_out}"
          PR_NR=$(sed -E 's#(.*\/)([0-9]+)#\2#g' <<< "${pr_create_out}")

          echo "INFO enable pull request auto merge"
          gh pr merge --auto --merge "${PR_NR}"
          echo "pr_nr=${PR_NR}" >> "${GITHUB_OUTPUT}"

# The github token approving the PR needs to be different from the one it creates it
      - name: Approve the PR
        env:
          GITHUB_TOKEN: ${{ secrets.token_approve_pr }}
          PR_NR: ${{ steps.cpr.outputs.pr_nr }}
        run: |
          set -eou pipefail

          pwd
          ls -la
          cd "${REPO}"
          pwd
          ls -la
          echo "INFO the github token approving the PR needs to be different from the one it creates it"
          gh pr review --approve "${PR_NR}"
```
