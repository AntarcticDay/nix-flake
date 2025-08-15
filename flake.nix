{
  description = "Minimal flake for FlakeHub publish test";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.hello = with import nixpkgs { system = "x86_64-linux"; }; hello;
  };
}
