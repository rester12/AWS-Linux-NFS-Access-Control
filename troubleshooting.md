# Troubleshooting Notes

## Service management failed in CloudShell

**Symptom:** `systemctl` did not behave as expected.

**Cause:** AWS CloudShell is an administrative shell and is not the target EC2 operating system.

**Resolution:** Connect to the EC2 instance through SSH or an approved management path before managing instance services.

## SSH timed out

Validate the full connection path:

1. Confirm that the instance is running and both status checks pass.
2. Confirm that the connection address is current.
3. Verify the security-group source restriction for TCP port 22.
4. Inspect the subnet route table and gateway state.
5. Confirm that the network ACL permits the required traffic.

## Route was in a blackhole state

An existing route is not necessarily a working route. Inspect its state and target. Replace or remove stale targets, then test the connection again.

Use placeholders in public documentation instead of publishing account-specific route-table or gateway identifiers.

## NFS client could not mount the share

1. Confirm that `nfs-server` is active on the server.
2. Review `exportfs -v` and the export configuration.
3. Restrict and verify security-group access to TCP port 2049.
4. Confirm private routing and name resolution between the instances.
5. Test the export with a temporary mount before editing `/etc/fstab`.
6. Use `_netdev` and `nofail` for a network-dependent persistent mount.

## ACL appeared correct but access was denied

Check every parent directory with `namei -l <path>`. A file-level ACL cannot grant access when the user cannot traverse a parent directory.

## Environment required reconstruction

Verify the EC2 instance identity, attached EBS volumes, mount points, and filesystem state before assigning a cause. Use the runbook and onboarding script to reproduce the intended configuration after the infrastructure issue is understood.

