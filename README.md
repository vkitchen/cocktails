# Tophat

## Building

First dependencies under Fedora 25.

`# dnf install @development-tools perl-CPAN perl-App-cpanminus perl-Test-Simple perl-Test perl-Test-Pod perl-Digest-MD5 perl-Crypt-Blowfish perl-Crypt-Eksblowfish perl-Digest-SHA1 perl-Digest-MD4 perl-Test-Warn`

And then the pure Perl dependencies.

`# cpanm Test::More Mojolicious Mojolicious::Plugin::Authentication Crypt::CBC Authen::Passphrase::BlowfishCrypt Text::CSV Mojolicious::Plugin::Proxy`
