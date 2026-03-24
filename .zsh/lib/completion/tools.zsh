# Completion tools registry
#
# Maps binary names to the command that generates their zsh completion.
# Only list tools that generate completions dynamically (e.g. Cobra-based CLIs).
# Tools that ship static completion files via package managers (apt, brew, etc.)
# are picked up automatically via fpath and do NOT need to be listed here.
#
# Format:  COMPLETION_TOOLS[binary_name]="command to generate zsh completion"
#
# The generator will skip any binary that is not found in $PATH.

typeset -gA COMPLETION_TOOLS=(
  [kubectl]="kubectl completion zsh"
  [minikube]="minikube completion zsh"
  [helm]="helm completion zsh"
  [flux]="flux completion zsh"
  [argocd]="argocd completion zsh"
  [kind]="kind completion zsh"
  [k3d]="k3d completion zsh"
  [stern]="stern --completion zsh"
  [gh]="gh completion -s zsh"
  [hugo]="hugo completion zsh"
  [cobra-cli]="cobra-cli completion zsh"
  [cilium]="cilium completion zsh"
  [talosctl]="talosctl completion zsh"
  [nerdctl]="nerdctl completion zsh"
)
