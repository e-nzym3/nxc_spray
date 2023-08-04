# cme_spray.sh

Bash script used for password spraying CrackMapExec-supported protocols.

**NOTE: I have not tested spraying SSH, MSSQL, or WINRM. CME supports those protocol via the same syntax as SMB and LDAP, so it should work as intended. Your mileage may vary.**

# Prerequisites

Install CrackMapExec. Instructions on how-to can be found here: https://github.com/Porchetta-Industries/CrackMapExec/wiki/Installation.

# Usage

All arguments are positional and they go in the following order:
1. Protocol to spray (**smb**, **ldap**, ssh, mssql, winrm)
2. Number of passwords to spray per cycle.
3. Time to wait between cycles.
4. Location of the file with users to be sprayed.
5. Location of the file with passwords to be sprayed.
6. Target to authenticate against (DC or any domain-bound host)
7. DEBUG MODE (Y/N). If "Y" then it will simply print the debug messages without actually running CME. Since debug will include the command to be run, you can easily test out the tool to ensure it's running as expected.

Internal domain against which the users are authenticated against can be controlled via two methods:
1. Specify it within your username list by prefixing the `DOMAIN\` or `@DOMAIN` to your usernames.
2. Leave out the above modification and let CME use the domain for which the target device is configured for. (I.e. if you're spraying against `DC01.ACME.COM` or `EXCH.ACME.COM` then all users will be tested against `ACME.COM`).

```
cme_spray.sh {protocol (smb,ldap,mssql,ssh,winrm)} {# of passwords per spray} {time to wait between sprays} {user file} {password file} {target} {test run? prints debug only (y/n)}
```

I highly recommend supplementing this command with `| tee -a cme_spray.out` so that you don't hit bash line limits and lose output. Plus it creates a nice log to be reviewed once all sprays are done.


## Sample usage

```
./cme_spray.sh smb 4 30 creds/users.txt creds/passw.txt 10.0.0.1 n | tee -a cme_spray.out
```
This will spray `4` passwords every `30` minutes against the usernames within `creds/users.txt` using passwords from `creds/passw.txt` against host `10.0.0.1` with `no` debug (because we want it to run). The output of the whole run is saved to `cme_spray.out` due to the `| tee -a cme_spray.out` (however, this is optional, you can also redirect all output to file if you wish with `>> cme_spray.out`).

## TO DOs

 - Some more error handling would be nice.
