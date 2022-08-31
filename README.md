# SENG4500 Assignment 1

Run with Ruby 3.1.2

## Windows

Go to the [Ruby Installer for Windows](https://rubyinstaller.org/) website and download Ruby+Devkit 3.1.2-1 (x64).

## Linux/MacOS
To install Ruby on a Unix-like system recommended to install a version manager like [asdf](https://asdf-vm.com/guide/getting-started.html).

After core installation is done, install the [asdf Ruby plugin](https://github.com/asdf-vm/asdf-ruby).
```sh
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
```

When plugin installation is done run:
```sh
asdf install ruby latest
asdf global ruby latest
```

Ruby should now be installed!
```sh
ruby -v
=> ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [x86_64-linux]
```

## Tax Server
```sh
ruby tax_server.rb -p [Port number. Default 3000]
```

## Tax Client
```sh
ruby tax_client.rb
```

Note on Windows, you might have to use `localhost` as the host address if the initial connection is timing out
