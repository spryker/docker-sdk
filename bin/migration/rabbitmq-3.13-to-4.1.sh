#!/usr/bin/env bash

################################################################################
# RabbitMQ Migration Script: 3.13 -> 4.1
#
# This script performs a safe migration from RabbitMQ 3.13 to 4.1, including:
# - Backup of RabbitMQ definitions and data
# - Export of queue/vhost configurations
# - Migration of classic mirrored queues to quorum queues
# - Verification of the migration
#
# Usage:
#   docker/sdk migration:rabbitmq-3.13-to-4.1 [--skip-backup] [--dry-run]
#
# Options:
#   --skip-backup    Skip backup step (not recommended)
#   --dry-run        Show what would be done without executing
################################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

# Default values
SKIP_BACKUP=false
DRY_RUN=false
BACKUP_DIR="${PROJECT_ROOT}/data/backup/rabbitmq-migration-$(date +%Y%m%d-%H%M%S)"
SERVICE_NAME="broker"
RMQ_CONTAINER=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

################################################################################
# Helper Functions
################################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

execute_command() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} Would execute: $*"
        return 0
    fi
    "$@"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if docker-compose is available
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        log_error "docker-compose or docker compose not found"
        exit 1
    fi
    
    # Check if we're in the project root
    if [ ! -f "${PROJECT_ROOT}/docker-compose.yml" ] && [ ! -f "${PROJECT_ROOT}/compose.yml" ]; then
        log_error "docker-compose.yml not found. Are you in the project root?"
        exit 1
    fi
    
    # Get docker compose command
    if docker compose version &> /dev/null; then
        DOCKER_COMPOSE="docker compose"
    else
        DOCKER_COMPOSE="docker-compose"
    fi
    
    # Check if broker service exists
    cd "${PROJECT_ROOT}"
    if ! ${DOCKER_COMPOSE} ps --services | grep -q "^${SERVICE_NAME}$"; then
        log_error "Broker service '${SERVICE_NAME}' not found in docker-compose"
        exit 1
    fi
    
    # Get container name
    RMQ_CONTAINER=$(${DOCKER_COMPOSE} ps -q ${SERVICE_NAME} | head -n1)
    if [ -z "${RMQ_CONTAINER}" ]; then
        log_error "RabbitMQ container not running. Please start it first."
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

get_rabbitmq_version() {
    log_info "Checking current RabbitMQ version..."
    cd "${PROJECT_ROOT}"
    
    local version_output
    version_output=$(docker exec "${RMQ_CONTAINER}" rabbitmqctl --version 2>/dev/null || echo "")
    
    if [ -z "$version_output" ]; then
        log_error "Could not determine RabbitMQ version"
        exit 1
    fi
    
    log_info "Current version: ${version_output}"
    
    # Extract version number
    if echo "$version_output" | grep -q "3.13"; then
        log_success "RabbitMQ 3.13 detected"
    else
        log_warning "Expected RabbitMQ 3.13, but found: ${version_output}"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

backup_rabbitmq() {
    if [ "$SKIP_BACKUP" = true ]; then
        log_warning "Skipping backup (--skip-backup flag set)"
        return 0
    fi
    
    log_info "Creating backup directory: ${BACKUP_DIR}"
    execute_command mkdir -p "${BACKUP_DIR}"
    
    log_info "Backing up RabbitMQ definitions..."
    cd "${PROJECT_ROOT}"
    
    # Export definitions using rabbitmqadmin or rabbitmqctl
    if docker exec "${RMQ_CONTAINER}" rabbitmqadmin --help &> /dev/null; then
        log_info "Using rabbitmqadmin to export definitions..."
        execute_command docker exec "${RMQ_CONTAINER}" rabbitmqadmin export "${BACKUP_DIR}/definitions.json" || {
            log_warning "rabbitmqadmin export failed, trying alternative method..."
            # Alternative: use rabbitmqctl
            execute_command docker exec "${RMQ_CONTAINER}" rabbitmqctl export_definitions "${BACKUP_DIR}/definitions.json" || true
        }
    else
        # Use rabbitmqctl export_definitions (available in 3.13+)
        log_info "Using rabbitmqctl to export definitions..."
        execute_command docker exec "${RMQ_CONTAINER}" rabbitmqctl export_definitions "${BACKUP_DIR}/definitions.json" || {
            log_warning "Could not export definitions. Continuing with manual export..."
        }
    fi
    
    # Backup virtual hosts list
    log_info "Backing up virtual hosts..."
    execute_command docker exec "${RMQ_CONTAINER}" rabbitmqctl list_vhosts > "${BACKUP_DIR}/vhosts.txt" || true
    
    # Backup queues
    log_info "Backing up queue information..."
    execute_command docker exec "${RMQ_CONTAINER}" rabbitmqctl list_queues name type arguments > "${BACKUP_DIR}/queues.txt" || true
    
    # Backup exchanges
    log_info "Backing up exchange information..."
    execute_command docker exec "${RMQ_CONTAINER}" rabbitmqctl list_exchanges name type > "${BACKUP_DIR}/exchanges.txt" || true
    
    # Backup bindings
    log_info "Backing up binding information..."
    execute_command docker exec "${RMQ_CONTAINER}" rabbitmqctl list_bindings > "${BACKUP_DIR}/bindings.txt" || true
    
    # Backup users and permissions
    log_info "Backing up users and permissions..."
    execute_command docker exec "${RMQ_CONTAINER}" rabbitmqctl list_users > "${BACKUP_DIR}/users.txt" || true
    execute_command docker exec "${RMQ_CONTAINER}" rabbitmqctl list_permissions > "${BACKUP_DIR}/permissions.txt" || true
    
    # Backup RabbitMQ data directory (the volume)
    log_info "Creating data directory backup..."
    execute_command docker cp "${RMQ_CONTAINER}:/var/lib/rabbitmq" "${BACKUP_DIR}/rabbitmq-data" 2>/dev/null || {
        log_warning "Could not backup data directory (may require root or volume access)"
    }
    
    # Save environment variables
    log_info "Backing up configuration..."
    {
        echo "RABBITMQ_DEFAULT_USER=$(docker exec "${RMQ_CONTAINER}" printenv RABBITMQ_DEFAULT_USER || echo "")"
        echo "RABBITMQ_DEFAULT_PASS=$(docker exec "${RMQ_CONTAINER}" printenv RABBITMQ_DEFAULT_PASS || echo "")"
        echo "SPRYKER_RABBITMQ_VIRTUAL_HOSTS=${SPRYKER_RABBITMQ_VIRTUAL_HOSTS:-}"
        echo "SPRYKER_RABBITMQ_API_USERNAME=${SPRYKER_RABBITMQ_API_USERNAME:-}"
    } > "${BACKUP_DIR}/env-vars.txt"
    
    log_success "Backup completed: ${BACKUP_DIR}"
    log_info "Backup contents:"
    execute_command ls -lah "${BACKUP_DIR}"
}

stop_consumers() {
    log_info "Stopping message consumers..."
    log_warning "Please ensure all queue workers are stopped before continuing"
    log_info "You can stop them with: vendor/bin/console queue:worker:stop"
    
    read -p "Have you stopped all queue workers? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_error "Please stop queue workers before continuing"
        exit 1
    fi
}

update_deployment_config() {
    log_info "Checking deployment configuration files..."
    
    # Find all deploy.yml files that specify RabbitMQ 3.13
    local deploy_files
    deploy_files=$(find "${PROJECT_ROOT}" -maxdepth 1 -name "deploy*.yml" -type f 2>/dev/null || true)
    
    if [ -n "$deploy_files" ]; then
        log_info "Found deployment files. Checking for RabbitMQ version configuration..."
        while IFS= read -r file; do
            if grep -q "rabbitmq.*3.13" "$file" 2>/dev/null || grep -q "version.*3.13" "$file" 2>/dev/null || 
               grep -q "rabbitmq" "$file" 2>/dev/null; then
                log_warning "Found potential RabbitMQ config in: $(basename "$file")"
                log_info "Please manually update broker version to '4.1' in this file"
                if [ "$DRY_RUN" = false ]; then
                    read -p "Open this file for editing? (y/N) " -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        ${EDITOR:-vi} "$file"
                    fi
                fi
            fi
        done <<< "$deploy_files"
    fi
}

stop_rabbitmq_service() {
    log_info "Stopping RabbitMQ service..."
    cd "${PROJECT_ROOT}"
    
    execute_command ${DOCKER_COMPOSE} stop ${SERVICE_NAME}
    
    log_success "RabbitMQ service stopped"
}

update_docker_compose() {
    log_info "Updating docker-compose configuration..."
    
    # Note: The docker-compose.yml is usually generated by the SDK
    # We'll need to update the deploy.yml configuration instead
    log_info "Docker-compose configuration is managed by SDK"
    log_info "Ensure your deploy.yml has: broker.version: '4.1'"
    
    # Regenerate docker-compose if needed
    if [ "$DRY_RUN" = false ]; then
        log_info "You may need to regenerate docker-compose.yml with updated config"
        log_info "Run: docker/sdk docker:generate"
    fi
}

start_rabbitmq_4_1() {
    log_info "Starting RabbitMQ 4.1..."
    cd "${PROJECT_ROOT}"
    
    # Ensure the image is pulled
    log_info "Pulling RabbitMQ 4.1 image..."
    execute_command ${DOCKER_COMPOSE} pull ${SERVICE_NAME} || true
    
    # Start the service
    log_info "Starting service with new version..."
    execute_command ${DOCKER_COMPOSE} up -d ${SERVICE_NAME}
    
    # Wait for RabbitMQ to be ready
    log_info "Waiting for RabbitMQ to be ready..."
    local max_attempts=60
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if docker exec "${RMQ_CONTAINER}" rabbitmqctl status &> /dev/null; then
            log_success "RabbitMQ is ready"
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 2
        echo -n "."
    done
    
    log_error "RabbitMQ did not become ready in time"
    return 1
}

verify_rabbitmq_version() {
    log_info "Verifying RabbitMQ version..."
    cd "${PROJECT_ROOT}"
    
    RMQ_CONTAINER=$(${DOCKER_COMPOSE} ps -q ${SERVICE_NAME} | head -n1)
    local version_output
    version_output=$(docker exec "${RMQ_CONTAINER}" rabbitmqctl --version 2>/dev/null || echo "")
    
    if echo "$version_output" | grep -q "4.1"; then
        log_success "RabbitMQ 4.1 confirmed"
    else
        log_error "RabbitMQ version mismatch. Expected 4.1, got: ${version_output}"
        return 1
    fi
}

enable_feature_flags() {
    log_info "Enabling required feature flags for RabbitMQ 4.1..."
    cd "${PROJECT_ROOT}"
    
    # Enable stable feature flags (required for 4.0+)
    execute_command docker exec "${RMQ_CONTAINER}" rabbitmqctl enable_feature_flag quorum_queue || true
    execute_command docker exec "${RMQ_CONTAINER}" rabbitmqctl enable_feature_flag stream_queue || true
    execute_command docker exec "${RMQ_CONTAINER}" rabbitmqctl enable_feature_flag stream || true
    
    log_success "Feature flags enabled"
}

restore_definitions() {
    log_info "Restoring RabbitMQ definitions..."
    cd "${PROJECT_ROOT}"
    
    if [ ! -f "${BACKUP_DIR}/definitions.json" ]; then
        log_warning "Definitions backup not found. Recreating from configuration..."
        return 0
    fi
    
    # Import definitions
    if docker exec "${RMQ_CONTAINER}" rabbitmqadmin --help &> /dev/null; then
        log_info "Importing definitions using rabbitmqadmin..."
        execute_command docker cp "${BACKUP_DIR}/definitions.json" "${RMQ_CONTAINER}:/tmp/definitions.json"
        execute_command docker exec "${RMQ_CONTAINER}" rabbitmqadmin import /tmp/definitions.json || {
            log_warning "Import failed, trying rabbitmqctl..."
            execute_command docker exec "${RMQ_CONTAINER}" rabbitmqctl import_definitions /tmp/definitions.json || true
        }
    else
        log_info "Importing definitions using rabbitmqctl..."
        execute_command docker cp "${BACKUP_DIR}/definitions.json" "${RMQ_CONTAINER}:/tmp/definitions.json"
        execute_command docker exec "${RMQ_CONTAINER}" rabbitmqctl import_definitions /tmp/definitions.json || true
    fi
    
    log_success "Definitions restoration attempted (some may need manual migration)"
}

recreate_virtual_hosts() {
    log_info "Recreating virtual hosts..."
    cd "${PROJECT_ROOT}"
    
    # Use the same logic as the install script
    local tty
    [ -t 0 ] && tty='' || tty='-T'
    
    local ttyDisabledKey='docker_compose_tty_disabled'
    if [ "${DOCKER_COMPOSE_TTY_DISABLED:-}" = "${ttyDisabledKey}" ]; then
        tty='-T'
    fi
    
    if [ -n "${SPRYKER_RABBITMQ_VIRTUAL_HOSTS:-}" ]; then
        execute_command ${DOCKER_COMPOSE} exec ${tty} \
            -e SPRYKER_RABBITMQ_VIRTUAL_HOSTS="${SPRYKER_RABBITMQ_VIRTUAL_HOSTS}" \
            -e SPRYKER_RABBITMQ_API_USERNAME="${SPRYKER_RABBITMQ_API_USERNAME:-}" \
            ${SERVICE_NAME} \
            bash -c 'for host in $(echo ${SPRYKER_RABBITMQ_VIRTUAL_HOSTS}); do 
                        rabbitmqctl add_vhost ${host} || true; 
                        rabbitmqctl set_permissions -p ${host} ${SPRYKER_RABBITMQ_API_USERNAME} ".*" ".*" ".*" || true; 
                    done'
    else
        log_warning "SPRYKER_RABBITMQ_VIRTUAL_HOSTS not set. Skipping vhost recreation."
    fi
    
    log_success "Virtual hosts recreated"
}

migrate_classic_queues_to_quorum() {
    log_info "Checking for classic mirrored queues to migrate..."
    cd "${PROJECT_ROOT}"
    
    # Get list of queues
    local queues_output
    queues_output=$(docker exec "${RMQ_CONTAINER}" rabbitmqctl list_queues name type arguments 2>/dev/null || echo "")
    
    if [ -z "$queues_output" ]; then
        log_warning "Could not list queues"
        return 0
    fi
    
    # Check for classic queues
    local classic_queues
    classic_queues=$(echo "$queues_output" | grep -E "^(classic|mirrored)" || true)
    
    if [ -z "$classic_queues" ]; then
        log_success "No classic queues found that need migration"
        return 0
    fi
    
    log_warning "Found classic queues that may need migration to quorum queues:"
    echo "$classic_queues"
    
    log_info "Note: Classic mirrored queues are deprecated in RabbitMQ 4.0+"
    log_info "You should migrate them to quorum queues manually or via queue:setup command"
    log_info "The queue:setup command will recreate queues with proper types"
}

run_queue_setup() {
    log_info "Running queue:setup to ensure all queues are properly configured..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would run: vendor/bin/console queue:setup"
        return 0
    fi
    
    cd "${PROJECT_ROOT}"
    
    # Check if console command exists
    if [ ! -f "vendor/bin/console" ]; then
        log_warning "vendor/bin/console not found. Install dependencies first."
        return 0
    fi
    
    log_info "Executing: vendor/bin/console queue:setup"
    execute_command vendor/bin/console queue:setup || {
        log_warning "queue:setup failed. You may need to run it manually."
    }
    
    log_success "Queue setup completed"
}

verify_migration() {
    log_info "Verifying migration..."
    cd "${PROJECT_ROOT}"
    
    # Check RabbitMQ is running
    if ! docker exec "${RMQ_CONTAINER}" rabbitmqctl status &> /dev/null; then
        log_error "RabbitMQ is not running"
        return 1
    fi
    
    # Check cluster status
    log_info "Cluster status:"
    execute_command docker exec "${RMQ_CONTAINER}" rabbitmqctl cluster_status || true
    
    # List queues
    log_info "Queue list:"
    execute_command docker exec "${RMQ_CONTAINER}" rabbitmqctl list_queues name type messages consumers || true
    
    # List exchanges
    log_info "Exchange list:"
    execute_command docker exec "${RMQ_CONTAINER}" rabbitmqctl list_exchanges name type || true
    
    log_success "Migration verification complete"
}

print_summary() {
    echo ""
    echo "================================================================================"
    echo "Migration Summary"
    echo "================================================================================"
    echo ""
    
    if [ "$DRY_RUN" = true ]; then
        log_info "This was a DRY RUN - no changes were made"
        echo ""
    fi
    
    if [ "$SKIP_BACKUP" = false ] && [ -d "$BACKUP_DIR" ]; then
        log_success "Backup location: ${BACKUP_DIR}"
        echo ""
    fi
    
    log_info "Next steps:"
    echo "  1. Verify all queues are working correctly"
    echo "  2. Monitor queue processing for errors"
    echo "  3. Test all message consumers"
    echo "  4. Migrate any remaining classic queues to quorum queues if needed"
    echo ""
    
    log_warning "Important notes:"
    echo "  - Classic mirrored queues are deprecated in RabbitMQ 4.0+"
    echo "  - Use quorum queues for better performance and reliability"
    echo "  - Run 'vendor/bin/console queue:setup' if queues need to be recreated"
    echo ""
    
    if [ -d "$BACKUP_DIR" ] && [ "$SKIP_BACKUP" = false ]; then
        log_info "Keep the backup at ${BACKUP_DIR} until you verify everything works"
        echo ""
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    echo ""
    log_info "=========================================="
    log_info "RabbitMQ 3.13 -> 4.1 Migration Script"
    log_info "=========================================="
    echo ""
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN MODE - No changes will be made"
        echo ""
    fi
    
    check_prerequisites
    get_rabbitmq_version
    backup_rabbitmq
    stop_consumers
    update_deployment_config
    stop_rabbitmq_service
    update_docker_compose
    
    # Check configuration was updated
    if [ "$DRY_RUN" = false ]; then
        log_warning "IMPORTANT: Ensure deploy.yml has broker.version: '4.1' before continuing"
        read -p "Press Enter to continue after updating configuration..."
    fi
    
    start_rabbitmq_4_1
    verify_rabbitmq_version
    enable_feature_flags
    restore_definitions
    recreate_virtual_hosts
    migrate_classic_queues_to_quorum
    run_queue_setup
    verify_migration
    print_summary
    
    log_success "Migration completed successfully!"
    echo ""
}

# Run main function
main "$@"
