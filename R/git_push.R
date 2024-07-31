#' @name git_push
#' @title git_push
#' @author brian devoe
#'
#' @description
#' commits and pushes all changes to git repo
#'
#' @param repo_path path to the git repository (the repository on your computer)
#' @param commit_message the message to attach to the commit
#' @param username your github username
#' @param password access token generated from github (see: https://github.com/settings/tokens)

git_push <- function(repo_path = NULL, commit_message = NULL, username = NULL, password = NULL){

  # Open the repository
  repo <- git2r::repository(repo_path)

  # Add all changes
  git2r::add(repo, ".")

  # Commit the changes
  git2r::commit(repo, commit_message)

  # Push to the remote repository
  cred <- git2r::cred_user_pass(username, password)
  git2r::push(repo, credentials = cred)

  # print message
  print("Changes pushed to remote repository")
  print(paste("Commit message: ", commit_message))

}






