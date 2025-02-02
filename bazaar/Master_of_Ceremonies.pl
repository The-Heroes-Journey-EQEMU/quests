use Digest::SHA qw(sha256_hex);

my %hashed_passcodes = (
    '8f9786c9897bb75ff03adccf837b73afb30b1032ad2376f4a6a64ac9a0a13dee' => 99001,
    '3d9ce4b85b2d28c5123c9cd2b5e58da2b0b10d86683e59da5bdc660420def7ff' => 99002,
    '41968ec695bbe00de0b1d562e41d4752de246217d10aedff3d30be4702fbe6d2' => 99003,
    '4d7ff3fc1a2a71e60d58ea1d5bf9a0c63d6c47ae1b753eba525922d9925d1985' => 99004,
    'a0a6e1ac76aa399cb7744f44335f8cc9050358659a652afbae7b0744a5c62dcf' => 99005,
    '1055020fed91b63be2c89187a9e438517bbddb87e9a0790c4260c9bb5e7917bf' => 99006,
    '3606e6b1a933f7065e51ebd47aa54b6ed4717a1dde40d94a9e05f01f1d471b60' => 99007,
    'c2304ca667168f96db5db3dec161fe005d8f1f34012cb28fc3bba37b79ef5649' => 99008,
    'd5012e1730ea9777bb369313717be8940077430ff6c8f2248fe15092d8eecbcd' => 99009,
    '9ce8d8f1bd6dea4ab4171867f6e97dc5962c37d6e7518fa08b5f54943ceaa8e0' => 99010,
    '60a742fb399c045d7c463caf1d943eb4dc958a68ef9e969aeeb263643433378e' => 99011,
    '2ba6c5f4655771fa3bc28b2ce6c1aa45b05f805201765c6e6f1a248b790edfb8' => 99012,
    'ab0173285e75181c392237c545620474a4ea130a5b8806b1fc1c572cb0b27872' => 99013,
    'cf5acf41ebc53479bb3f57706976ef582c92137338b1b4d4429dd592fc9144c0' => 99014,
    '83e5df3a55a53578a5e494c9d279b8eb17a4cae74df6f6ffbbf764daf3aef3ad' => 99015,
);

sub EVENT_SAY {
    if ($text =~ /hail/i) {
        plugin::NPCTell("Hail, $name. I preside over this Arena whenever there is an exhibition or spectacle to be viewed. However, if you have a secret passcode, I may have special rewards for you.");
    } else {
        handle_passcodes($text);
    }
}

sub handle_passcodes {
    my $input = shift;
    my $hash = sha256_hex($input);

    if ($hashed_passcodes{$hash}) {
        plugin::NPCTell("Wow! I never thought anyone would get that password. Here, take this...");
        plugin::AddTitleFlag($hashed_passcodes{$hash})
    }
}