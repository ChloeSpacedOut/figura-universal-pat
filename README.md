# Universal Pat
A pat script for Figura designed to work with most other pat scripts, while being as secure and respecting your and other's consent. Universal pat is opt-in, meaning other players will need to install universal pat (or another pat script) for you to be able to pat them.
# Setup
Simply add `universalPat.lua` to your avatar and universal pat will work!
# Whitelist
You can enable the whitelist to prevent people from patting you unless you explicitly allow them to. To enable the whitelist for yourself, set `doWhitelist` to true in the config. To enable the whitelist for your player head, set `doWhitelistOnSkull` to true.

To add a player to the whitelist, add a new table entry to the `whitelist` table with the key as the player's UUID. You can find a player's UUID by clicking `Copy UUID` in the Figura trust menu, or by searching their username in a site like [nameMC](https://namemc.com/). For example:
```lua
    whitelist = {
        ["8667ba71-b85a-4004-af54-457a9734eed7"] = true, -- Steve
        ["ec561538-f3fd-461d-aff5-086b22154bce"] = true, -- Alex
    },
```
# Blacklist
The blacklist is separate to the whitelist. Players on your blacklist will not be able to pat you, with or without the whitelist enabled. Adding players to the blacklist is identical to adding players to the whitelist. Optionally with `blacklistDisableDistance`, you can disable pats from everyone if a blacklisted player is near by. This is useful if you're concerned about them bypassing the whitelist, or simply don't want anyone patting you when they are around. By setting this to `-1`, blacklisted players will disable pats from any distance, and setting this to `0` will disable the feature.
# Pat Functions
You can modify the provided pat functions inside the config if you want to customise your pats. These functions also provide a basic config if you do not know how to code.
# Compatibility
Universal pat should be compatible with most pat scripts, and is compatible with all pat scripts that follow the pat standard.
## Compatible Pat Scripts
- Auria Pat
- FOX's Patpat
- Pat³
- ComPatPat
- FoxPat (legacy)
- Patpat by Auria (legacy)
- LazyPat (legacy) (one-way support)
- Patpat by Slyme (legacy) (one-way support)

# Security
Universal pat does not use uncrackable UUID auth, and instead relies on context to verify if a pat is valid. Before accepting a pat from others, universal pat checks:
- that this player is the caller of the pat function (if the client has silly plugin installed)
- that this player is whitelisted / not blacklisted
- that the player is not holding an item
- that this player is within 5 blocks of you / your skull
- that this player is looking at you / your skull
- that this player has swung their arm to pat you

These checks do not guarantee that your whitelist / blacklist will not be cracked with UUID spoofing, but make it extremely unplausable. To crack this security, a malicious actor would need:
- a whitelisted player to be within 5 blocks of you
- a whitelisted player to be looking at you
- a whitelisted player to not be holding an item
- a whitelisted player to have punched you within the last 4 ticks.

This is very unlikely to be abused, and if it is, you can just blacklist pats when this bad actor is around.
