<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator;

interface DeployFileGeneratorConstants
{
    /**
     * @var string
     */
    public const YAML_IMPORTS_KEY = 'imports';

    /**
     * @var string
     */
    public const YAML_PARAMETERS_KEY = 'parameters';

    /**
     * @var string
     */
    public const YAML_SERVICES_KEY = 'services';

    /**
     * @var string
     */
    public const YAML_SERVICE_NULL_VALUE = 'NULL';

    /**
     * @var string
     */
    public const YAML_TEMPLATE_KEY = 'template';

    /**
     * @var string
     */
    public const YAML_IMPORTS_TEMPLATE_KEY_SEPARATOR = '?';
}
