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

# GUI with the unix socket interface
You can run the parser in gui mode with a unix socker as an input interface. To do so provide a `--gui` as an only parameter.
```sh
nix run .# -- --gui
```

Then use socat or similar tool to send a message to the socket
```sh
echo "kubectl get pods -o yaml" | socat - /tmp/omgparser.socket
```
 
# DevEnv
To fire up a development environmetn use `nix develop` and then `cabal repl`.
