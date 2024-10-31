let pkgs = import <nixpkgs> { };
in pkgs.mkShell {
  packages = [
    (pkgs.python3.withPackages (python-pkgs: [
      python-pkgs.numpy
      python-pkgs.networkx
      python-pkgs.matplotlib
      python-pkgs.python-lsp-server
    ]))
  ];
}

