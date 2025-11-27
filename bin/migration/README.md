# RabbitMQ Migration Scripts

## RabbitMQ 3.13 to 4.1 Migration

This directory contains migration scripts for upgrading RabbitMQ versions.

### `rabbitmq-3.13-to-4.1.sh`

A comprehensive migration script to upgrade RabbitMQ from version 3.13 to 4.1.

#### Features

- **Automatic Backup**: Creates a complete backup of RabbitMQ definitions, queues, exchanges, bindings, and configuration
- **Safe Upgrade**: Verifies prerequisites and current version before proceeding
- **Definition Migration**: Exports and imports RabbitMQ definitions
- **Queue Migration**: Identifies classic mirrored queues that need migration to quorum queues
- **Verification**: Comprehensive post-migration verification
- **Dry Run Mode**: Test the migration without making changes

#### Prerequisites

1. Docker and docker-compose (or docker compose) installed
2. RabbitMQ 3.13 running in a container
3. All queue workers stopped (to prevent message loss during migration)
4. Updated `deploy.yml` file with `broker.version: '4.1'`

#### Usage

```bash
# Dry run (recommended first)
./docker/bin/migration/rabbitmq-3.13-to-4.1.sh --dry-run

# Full migration
./docker/bin/migration/rabbitmq-3.13-to-4.1.sh

# Skip backup (not recommended)
./docker/bin/migration/rabbitmq-3.13-to-4.1.sh --skip-backup
```

#### Migration Steps

The script performs the following steps:

1. **Prerequisites Check**: Verifies Docker, container status, and current RabbitMQ version
2. **Backup**: Creates a complete backup of:
   - RabbitMQ definitions (JSON export)
   - Virtual hosts list
   - Queues, exchanges, bindings
   - Users and permissions
   - Environment variables
   - Data directory (if accessible)
3. **Consumer Check**: Prompts to ensure all queue workers are stopped
4. **Configuration Update**: Checks and prompts for deployment configuration updates
5. **Service Stop**: Stops the RabbitMQ 3.13 container
6. **Service Start**: Starts RabbitMQ 4.1 container
7. **Feature Flags**: Enables required feature flags (quorum_queue, stream_queue, etc.)
8. **Definition Restoration**: Imports definitions from backup
9. **Virtual Host Recreation**: Recreates virtual hosts with proper permissions
10. **Queue Migration Check**: Identifies classic queues that need migration
11. **Queue Setup**: Runs `vendor/bin/console queue:setup` to recreate queues properly
12. **Verification**: Verifies cluster status and queue health

#### Breaking Changes in RabbitMQ 4.0+

- **Classic Mirrored Queues Deprecated**: RabbitMQ 4.0+ removes support for classic mirrored queues. Migrate to quorum queues for better performance and reliability.
- **Feature Flags Required**: Some feature flags must be enabled before upgrade
- **Erlang Version**: Ensure Erlang version is compatible with RabbitMQ 4.1

#### Backup Location

Backups are stored in:
```
{project-root}/data/backup/rabbitmq-migration-{timestamp}/
```

#### Important Notes

1. **Stop Queue Workers First**: Ensure all queue workers are stopped before running the migration to prevent message loss or corruption.

2. **Update Configuration**: The script will prompt you to update `deploy.yml` files. Make sure to set:
   ```yaml
   services:
     broker:
       version: '4.1'
   ```

3. **Regenerate Docker Compose**: After updating `deploy.yml`, you may need to regenerate docker-compose.yml:
   ```bash
   docker/sdk docker:generate
   ```

4. **Queue Types**: Classic mirrored queues will need to be migrated to quorum queues. The `queue:setup` command should handle most of this automatically.

5. **Test First**: Always test the migration in a development/staging environment before running in production.

#### Troubleshooting

**Migration fails during backup:**
- Ensure Docker container has permissions to access data directory
- Check disk space for backup location

**Definitions import fails:**
- Manually import using: `rabbitmqctl import_definitions /path/to/backup/definitions.json`
- Or recreate queues using: `vendor/bin/console queue:setup`

**Queues not working after migration:**
- Verify queue types: `rabbitmqctl list_queues name type`
- Migrate classic queues to quorum queues
- Check queue consumers are restarted

**Container won't start:**
- Check logs: `docker-compose logs broker`
- Verify Erlang version compatibility
- Ensure feature flags are enabled

#### Rollback

If you need to rollback:

1. Stop RabbitMQ 4.1: `docker-compose stop broker`
2. Restore backup volume (if you backed it up separately)
3. Update `deploy.yml` back to version 3.13
4. Regenerate docker-compose: `docker/sdk docker:generate`
5. Start service: `docker-compose up -d broker`
6. Restore definitions: `rabbitmqctl import_definitions /path/to/backup/definitions.json`

#### References

- [RabbitMQ Upgrade Guide](https://www.rabbitmq.com/docs/4.0/upgrade)
- [Migration from Classic Mirrored Queues to Quorum Queues](https://www.rabbitmq.com/docs/3.13/migrate-mcq-to-qq)
- [RabbitMQ 4.0 Release Notes](https://www.rabbitmq.com/blog/2024/01/11/3.13-release)

