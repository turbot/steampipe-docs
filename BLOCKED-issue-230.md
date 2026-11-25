# BLOCKED: issue #230

## Kind: design

The monthly dependencies chore is already on (PR #231, merged). What is left is turning
on `security-audit` and `dependabot-cant-fix`.

A maintainer (e-gineer) decided on the issue after #231 that both stay off. This repo is
public, and the audit would file findings here as public issues. They want the audit held
until it can file without spelling out how to use a finding. "Dependabot can't fix" waits
with it.

Removing `off` from those two entries now would go against that decision, so I changed
nothing. `secret-scan` stays off as the issue says.

Next step: a person re-arms the issue (removes `agent:blocked`) once the audit can file
public findings safely, or closes #230 as done for the dependencies chore only.
