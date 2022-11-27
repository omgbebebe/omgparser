Just a parser for some strings. Under the hood it uses Megaparsec.

# Usage
Build and run via `nix` command
```sh
❯ nix run .# -- kubectl get -o json pod web,haproxy
"running with input: kubectl get -o json pod web,haproxy"
Parser command is:
Kubectl (K {action = (Get,Pod {podName = Just "web,haproxy"}), output = Just Json})

❯ nix run .# -- kubectl get pods
"running with input: kubectl get pods"
Parser command is:
Kubectl (K {action = (Get,Pod {podName = Nothing}), output = Nothing})

❯ nix run .# -- kubectl get pods -o json
"running with input: kubectl get pods -o json"
Parser command is:
Kubectl (K {action = (Get,Pod {podName = Nothing}), output = Just Json})

❯ nix run .# -- kubectl get -o yaml pod web,srv1
"running with input: kubectl get -o yaml pod web,srv1"
Parser command is:
Kubectl (K {action = (Get,Pod {podName = Just "web,srv1"}), output = Just Yaml})

❯ nix run .# -- omg this is an another command
"running with input: omg this is an another command"
Parser command is:
Omg
```

# DevEnv
To fire up a development environmetn use `nix develop` and then `cabal repl`.
